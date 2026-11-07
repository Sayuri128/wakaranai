import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/config_info/download_config/download_config.dart';
import 'package:collection/collection.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_source_resolver.dart';
import 'package:wakaranai/services/downloads/jobs/chapter_job_runner.dart';
import 'package:wakaranai/services/downloads/jobs/chapter_page_writer.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/jobs/episode_job_runner.dart';
import 'package:wakaranai/services/downloads/jobs/novel_chapter_job_runner.dart';
import 'package:wakaranai/services/downloads/queue/download_job_queue.dart';
import 'package:wakaranai/services/downloads/queue/download_job_rebuilder.dart';
import 'package:wakaranai/services/downloads/queue/download_queue_control.dart';
import 'package:wakaranai/services/downloads/runtime/download_network_policy.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime_coordinator.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/services/downloads/storage/download_quality_reader.dart';
import 'package:wakaranai/utils/http_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/services/downloads/download_client_pool.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';

export 'package:wakaranai/services/downloads/runtime/download_runtime_coordinator.dart'
    show DownloadRuntimeStatus;

part 'download_manager_state.dart';

class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit({
    required this.downloadRepository,
    this.extensionRepository,
    DownloadNotificationService? notificationService,
    EpisodeSourceResolver? episodeSourceResolver,
    EpisodeDownloader? episodeDownloader,
    QualityPreferenceReader? readQualityPreference,
    DownloadRuntime? downloadRuntime,
    DownloadNetworkPolicy? networkPolicy,
    DownloadThrottle? throttle,
    DownloadWait? wait,
  })  : notificationService =
            notificationService ?? DownloadNotificationService(),
        _throttle = throttle ?? DownloadThrottle(),
        _delay = wait ?? Future<void>.delayed,
        _injectedSourceResolver = episodeSourceResolver,
        _injectedEpisodeDownloader = episodeDownloader,
        _readQualityPreference = readQualityPreference ??
            PlayerPreferences().getQualityPreference,
        _networkPolicy = networkPolicy ?? DownloadNetworkPolicy.platform(),
        _clients =
            DownloadClientPool(extensionRepository: extensionRepository),
        super(const DownloadManagerState()) {
    _runtime = DownloadRuntimeCoordinator(
      runtime: downloadRuntime ?? createDownloadRuntime(),
      isOwnerClosed: () => isClosed,
      readStatus: () => state.runtimeStatus,
      publishStatus: _setRuntimeStatus,
    );
    _networkPolicyChanges =
        _networkPolicy.changes.listen(_onNetworkPolicyChanged);
  }

  final DownloadRepository downloadRepository;
  final ExtensionRepository? extensionRepository;
  final DownloadNotificationService notificationService;
  final EpisodeSourceResolver? _injectedSourceResolver;
  final EpisodeDownloader? _injectedEpisodeDownloader;
  final QualityPreferenceReader _readQualityPreference;
  late final DownloadRuntimeCoordinator _runtime;
  final DownloadNetworkPolicy _networkPolicy;
  final DownloadClientPool _clients;
  late final StreamSubscription<bool> _networkPolicyChanges;

  static const Duration _jobUnwindTimeout = Duration(seconds: 10);

  final DownloadThrottle _throttle;
  final DownloadWait _delay;
  final DownloadJobQueue _queue = DownloadJobQueue();
  late final DownloadQueueControl _control = DownloadQueueControl(
    downloadRepository: downloadRepository,
    queue: _queue,
    rebuilder: DownloadJobRebuilder(clients: _clients),
    startQueue: startQueue,
    settleEmptiedQueue: _settleEmptiedQueue,
  );
  late final ChapterJobRunner _chapterRunner = ChapterJobRunner(
    downloadRepository: downloadRepository,
    reportProgress: _showJobProgress,
    consumeDeletion: _queue.deletedUids.remove,
    pageWriter: ChapterPageWriter(
      dio: createDio(),
      throttle: _throttle,
      wait: _delay,
    ),
    throttle: _throttle,
    wait: _delay,
  );
  late final NovelChapterJobRunner _novelChapterRunner = NovelChapterJobRunner(
    downloadRepository: downloadRepository,
    reportProgress: _showJobProgress,
    consumeDeletion: _queue.deletedUids.remove,
  );
  late final EpisodeJobRunner _episodeRunner = EpisodeJobRunner(
    downloadRepository: downloadRepository,
    reportProgress: _showJobProgress,
    readQualityPreference: _readQualityPreference,
    sources: _injectedSourceResolver ??
        PooledClientEpisodeSourceResolver(
            loadClient: _clients.animeClientForUid),
    downloader:
        _injectedEpisodeDownloader ?? EpisodeDownloader(throttle: _throttle),
  );
  bool _processing = false;
  bool _permissionRequested = false;
  bool _recovered = false;

  StreamSubscription<List<DownloadDomain>>? _sub;

  void init() {
    _sub?.cancel();
    _sub = downloadRepository.watchAll().listen((List<DownloadDomain> rows) {
      emit(state.copyWith(downloads: rows));
    });

    if (!_recovered) {
      _recovered = true;
      unawaited(_control.recoverInterrupted());
    }
    unawaited(_networkPolicy.start());
  }

  void setWifiOnly(bool value) {
    _networkPolicy.setWifiOnly(value);
  }

  Future<ApiClient> chapterClientForExtension(ExtensionDomain extension) {
    return _clients.chapterClientFor(extension);
  }

  void _scheduleClientsRelease() {
    _clients.scheduleIdleRelease(
      stillIdle: () => !_processing && _queue.waiting.isEmpty,
    );
  }

  bool isDownloaded(String chapterUid) {
    return state.downloads.any((DownloadDomain d) =>
        d.uid == chapterUid && d.status == DownloadStatus.done);
  }

  static bool _isPendingOrDone(DownloadDomain? existing) {
    if (existing == null) {
      return false;
    }
    return existing.status == DownloadStatus.done || existing.isPending;
  }

  Future<void> enqueueChapter({
    required ApiClient client,
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    required String? concreteCover,
    required String chapterUid,
    required String title,
    required Map<String, dynamic>? data,
    bool autoStart = true,
  }) async {
    final DownloadDomain? existing =
        await downloadRepository.getByUid(chapterUid);
    if (_isPendingOrDone(existing)) {
      return;
    }

    final Directory dir =
        await DownloadFiles.chapterDir(extensionUid, concreteUid, chapterUid);

    _queue.deletedUids.remove(chapterUid);

    await downloadRepository.createUpdateBy<$DownloadTableTable, String>(
      DownloadDomain(
        id: 0,
        uid: chapterUid,
        extensionUid: extensionUid,
        concreteUid: concreteUid,
        concreteId: concreteId,
        concreteTitle: concreteTitle,
        concreteCover: concreteCover,
        title: title,
        status: DownloadStatus.queued,
        downloadedPages: 0,
        totalPages: 0,
        dirPath: dir.path,
        data: data != null ? jsonEncode(data) : null,
        kind: chapterDownloadKindFor(client),
        createdAt: DateTime.now(),
      ),
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );
    await downloadRepository.moveToQueueEnd(chapterUid);

    _queue.replace(chapterDownloadJobFor(
      client: client,
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      chapterUid: chapterUid,
      title: title,
      data: data,
    ));

    if (autoStart) {
      startQueue();
    }
  }

  Future<void> enqueueEpisode({
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    required String? concreteCover,
    required AnimeVideo episode,
    bool autoStart = true,
  }) async {
    final DownloadDomain? existing =
        await downloadRepository.getByUid(episode.uid);
    if (_isPendingOrDone(existing)) {
      return;
    }

    final String dirPath =
        await _episodeDirPath(existing, extensionUid, concreteUid, episode);

    _queue.deletedUids.remove(episode.uid);

    await downloadRepository.createUpdateBy<$DownloadTableTable, String>(
      DownloadDomain(
        id: 0,
        uid: episode.uid,
        extensionUid: extensionUid,
        concreteUid: concreteUid,
        concreteId: concreteId,
        concreteTitle: concreteTitle,
        concreteCover: concreteCover,
        title: episode.title,
        status: DownloadStatus.queued,
        downloadedPages: existing?.downloadedPages ?? 0,
        totalPages: existing?.totalPages ?? 0,
        downloadedBytes: existing?.downloadedBytes ?? 0,
        totalBytes: existing?.totalBytes ?? 0,
        dirPath: dirPath,
        data: encodeDownloadedEpisode(episode),
        kind: DownloadKind.episode,
        createdAt: DateTime.now(),
      ),
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );
    await downloadRepository.moveToQueueEnd(episode.uid);

    _queue.replace(EpisodeDownloadJob(
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      episode: episode,
    ));

    if (autoStart) {
      startQueue();
    }
  }

  Future<String> _episodeDirPath(
    DownloadDomain? existing,
    String extensionUid,
    String concreteUid,
    AnimeVideo episode,
  ) async {
    final String? previousDir = existing?.dirPath;
    if (previousDir != null && previousDir.isNotEmpty) {
      return previousDir;
    }
    final Directory dir =
        await DownloadFiles.chapterDir(extensionUid, concreteUid, episode.uid);
    return dir.path;
  }

  Future<void> retryDownload(DownloadDomain download) async {
    if (download.isEpisode) {
      await _retryEpisode(download);
      return;
    }
    await _retryChapter(download);
  }

  Future<void> _retryEpisode(DownloadDomain download) async {
    final AnimeVideo? episode = downloadedEpisodeOf(download);
    if (episode == null) {
      logger.w('Cannot retry ${download.uid}: the episode payload is missing');
      return;
    }
    await enqueueEpisode(
      extensionUid: download.extensionUid,
      concreteUid: download.concreteUid,
      concreteId: download.concreteId,
      concreteTitle: download.concreteTitle,
      concreteCover: download.concreteCover,
      episode: episode,
    );
  }

  Future<void> _retryChapter(DownloadDomain download) async {
    final ExtensionDomain? extension =
        await _clients.installedExtension(download.extensionUid);
    if (extension == null) {
      logger.w('Cannot retry ${download.uid}: extension '
          '${download.extensionUid} is not installed');
      return;
    }
    try {
      final ApiClient client = await chapterClientForExtension(extension);
      await retry(client: client, download: download);
    } catch (e, s) {
      logger.e('Cannot retry ${download.uid}: $e');
      logger.e(s);
      if (!_processing) {
        _scheduleClientsRelease();
      }
    }
  }

  Future<void> retry({
    required ApiClient client,
    required DownloadDomain download,
    Map<String, dynamic>? data,
  }) {
    return enqueueChapter(
      client: client,
      extensionUid: download.extensionUid,
      concreteUid: download.concreteUid,
      concreteId: download.concreteId,
      concreteTitle: download.concreteTitle,
      concreteCover: download.concreteCover,
      chapterUid: download.uid,
      title: download.title,
      data: data ??
          (download.data != null
              ? jsonDecode(download.data!) as Map<String, dynamic>
              : null),
    );
  }

  void startQueue() {
    unawaited(_process());
  }

  Future<void> _ensurePermission() async {
    if (_permissionRequested) {
      return;
    }
    _permissionRequested = true;
    try {
      await notificationService.requestPermission();
    } catch (e, s) {
      logger.w('Failed to request download notification permission: $e');
      logger.w(s);
    }
  }

  Future<void> _process() async {
    if (_processing) {
      return;
    }
    _processing = true;
    _clients.cancelIdleRelease();
    _queue.startBatch();
    try {
      await _ensurePermission();
      await _networkPolicy.start();
      while (_queue.waiting.isNotEmpty) {
        if (!_networkPolicy.allowsDownloads) {
          _setHold(DownloadQueueHold.waitingForWifi);
          break;
        }
        _setHold(DownloadQueueHold.none);
        final DownloadJob job = _queue.waiting.removeFirst();
        if (_queue.deletedUids.remove(job.uid)) {
          continue;
        }
        unawaited(_runtime.setWanted(true));
        _queue.active = job;
        try {
          await _runActiveJob(job);
          await _control.settleStoppedJob(job);
        } finally {
          _queue.active = null;
          job.markUnwound();
        }
      }
    } finally {
      _processing = false;
      _queue.batchIndex = 0;
      final int completed = _queue.completedInBatch;
      _queue.completedInBatch = 0;
      if (_isHeldWithQueuedJobs) {
        await _holdQueueForWifi(completed);
      } else {
        await _finishBatch(completed);
      }
      _scheduleClientsRelease();
    }
  }

  bool get _isHeldWithQueuedJobs =>
      _queue.waiting.isNotEmpty && !_networkPolicy.allowsDownloads;

  Future<void> _holdQueueForWifi(int completed) async {
    _setHold(DownloadQueueHold.waitingForWifi);
    if (completed > 0) {
      await notificationService.showComplete(completed);
    }
    await _runtime.setWanted(true);
    if (_processing || !_isHeldWithQueuedJobs) {
      return;
    }
    await notificationService.showWaitingForWifi();
  }

  Future<void> _finishBatch(int completed) async {
    if (completed > 0) {
      await notificationService.showComplete(completed);
    } else {
      await notificationService.cancelProgress();
    }
    _releaseHoldIfIdle();
    await _stopRuntimeIfIdle();
  }

  Future<void> _settleEmptiedQueue() async {
    if (_processing || !_queue.isIdle) {
      return;
    }
    final bool wasHeld = state.waitingForWifi;
    _releaseHoldIfIdle();
    if (!wasHeld) {
      return;
    }
    await _stopRuntimeIfIdle();
    if (_processing) {
      return;
    }
    await notificationService.cancelProgress();
  }

  void _onNetworkPolicyChanged(bool allowsDownloads) {
    if (isClosed) {
      return;
    }
    if (allowsDownloads) {
      _setHold(DownloadQueueHold.none);
      if (_queue.waiting.isNotEmpty) {
        startQueue();
      }
      return;
    }
    _holdActiveJobForWifi();
    if (!_queue.isIdle) {
      _setHold(DownloadQueueHold.waitingForWifi);
    }
  }

  void _holdActiveJobForWifi() {
    final DownloadJob? job = _queue.active;
    if (job == null || identical(_queue.heldForWifi, job)) {
      return;
    }
    _queue.heldForWifi = job;
    job.cancel('paused');
  }

  void _setHold(DownloadQueueHold hold) {
    if (isClosed || state.hold == hold) {
      return;
    }
    emit(state.copyWith(hold: hold));
  }

  void _releaseHoldIfIdle() {
    if (_queue.isIdle) {
      _setHold(DownloadQueueHold.none);
    }
  }

  Future<void> _stopRuntimeIfIdle() async {
    if (_processing) {
      return;
    }
    await _runtime.setWanted(false);
  }

  void _setRuntimeStatus(DownloadRuntimeStatus status) {
    if (isClosed || state.runtimeStatus == status) {
      return;
    }
    emit(state.copyWith(runtimeStatus: status));
  }

  Future<void> _runActiveJob(DownloadJob job) async {
    _queue.batchIndex++;
    await _applyConfiguredPacing(job.extensionUid);
    if (_queue.batchIndex > 1) {
      await waitIfPositive(_delay, _pauseBefore(job));
    }
    _queue.previousInBatch = job;
    final bool completed = await _runJob(job);
    if (completed) {
      _queue.completedInBatch++;
    }
  }

  Duration _pauseBefore(DownloadJob job) {
    final DownloadJob? previous = _queue.previousInBatch;
    final bool followsEpisodeOfSameExtension = job is EpisodeDownloadJob &&
        previous is EpisodeDownloadJob &&
        previous.extensionUid == job.extensionUid;
    if (followsEpisodeOfSameExtension) {
      return _throttle.episodeDelay(job.extensionUid);
    }
    return _throttle.chapterDelay(job.extensionUid);
  }

  Future<void> _applyConfiguredPacing(String extensionUid) async {
    final ExtensionRepository? extensions = extensionRepository;
    if (extensions == null) {
      return;
    }
    try {
      final ExtensionDomain? extension = await extensions.getByUid(extensionUid);
      final DownloadConfig? pacing = extension?.config.downloadConfig;
      _throttle.configure(
        extensionUid,
        pageDelay: Duration(milliseconds: pacing?.pageDelayMs ?? 0),
        chapterDelay: Duration(milliseconds: pacing?.chapterDelayMs ?? 0),
        episodeDelay: Duration(milliseconds: pacing?.episodeDelayMs ?? 0),
        segmentConcurrency: pacing?.segmentConcurrency,
      );
    } catch (e) {
      logger.w('Could not read download pacing for $extensionUid: $e');
    }
  }

  Future<bool> _runJob(DownloadJob job) {
    switch (job) {
      case ChapterDownloadJob():
        return _chapterRunner.run(job);
      case NovelChapterDownloadJob():
        return _novelChapterRunner.run(job);
      case EpisodeDownloadJob():
        return _episodeRunner.run(job);
    }
  }

  Future<void> _showJobProgress(
    DownloadJob job, {
    required int progress,
    required int max,
  }) {
    return notificationService.showProgress(
      title: job.concreteTitle,
      chapterTitle: job.title,
      progress: progress,
      max: max,
      queueIndex: _queue.batchIndex,
      queueTotal: _queue.batchTotal,
    );
  }

  Future<void> pauseDownload(String uid) => pauseDownloads(<String>[uid]);

  Future<void> resumeDownload(String uid) => resumeDownloads(<String>[uid]);

  Future<void> pauseAll() async {
    await pauseDownloads(
        await _control.pendingUidsWhere(DownloadQueueControl.isPausable));
  }

  Future<void> resumeAll() async {
    await resumeDownloads(
        await _control.pendingUidsWhere(DownloadQueueControl.isPaused));
  }

  Future<void> pauseTitle(String concreteUid) async {
    await pauseDownloads(await _control.pendingUidsWhere(
        (DownloadDomain row) =>
            row.concreteUid == concreteUid &&
            DownloadQueueControl.isPausable(row)));
  }

  Future<void> resumeTitle(String concreteUid) async {
    await resumeDownloads(await _control.pendingUidsWhere(
        (DownloadDomain row) =>
            row.concreteUid == concreteUid &&
            DownloadQueueControl.isPaused(row)));
  }

  Future<void> pauseDownloads(Iterable<String> uids) => _control.pause(uids);

  Future<void> resumeDownloads(Iterable<String> uids) => _control.resume(uids);

  Future<void> reorderQueue(List<String> orderedUids) =>
      _control.reorder(orderedUids);

  Future<void> downloadNext(String uid) => _control.downloadNext(uid);

  Future<void> moveTitleToTop(String concreteUid) =>
      _control.moveTitleToTop(concreteUid);

  Future<void> deleteDownload(DownloadDomain download) async {
    final String uid = download.uid;
    _queue.deletedUids.add(uid);
    _queue.parkedJobs.remove(uid);
    _queue.waiting.removeWhere((DownloadJob j) => j.uid == uid);
    final DownloadJob? activeJob =
        _queue.active?.uid == uid ? _queue.active : null;
    activeJob?.cancel();
    await _settleEmptiedQueue();
    await downloadRepository.deleteByUid(uid);
    final bool unwound = await _waitForUnwind(activeJob);
    await DownloadFiles.deleteDir(download.dirPath);
    if (unwound) {
      _queue.deletedUids.remove(uid);
    }
  }

  Future<bool> _waitForUnwind(DownloadJob? job) async {
    if (job == null) {
      return true;
    }
    try {
      await job.unwound.timeout(_jobUnwindTimeout);
      return true;
    } on TimeoutException {
      logger.w('Download ${job.uid} did not stop before its files were deleted');
      return false;
    }
  }

  Future<void> deleteForConcrete(String concreteUid) async {
    final List<DownloadDomain> rows =
        await downloadRepository.getByConcreteUid(concreteUid);
    for (final DownloadDomain row in rows) {
      await deleteDownload(row);
    }
  }

  Future<void> deleteAll() async {
    final List<DownloadDomain> rows =
        List<DownloadDomain>.from(state.downloads);
    for (final DownloadDomain row in rows) {
      await deleteDownload(row);
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _networkPolicyChanges.cancel();
    await _runtime.stopListening();
    await _runtime.setWanted(false);
    await _networkPolicy.dispose();
    await _runtime.dispose();
    await _clients.dispose();
    return super.close();
  }
}
