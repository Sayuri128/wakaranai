import 'dart:async';
import 'dart:collection';
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
import 'package:wakaranai/utils/serial_call_queue.dart';

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
  late final ChapterJobRunner _chapterRunner = ChapterJobRunner(
    downloadRepository: downloadRepository,
    reportProgress: _showJobProgress,
    consumeDeletion: _cancelled.remove,
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
    consumeDeletion: _cancelled.remove,
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
  final Queue<DownloadJob> _jobs = Queue<DownloadJob>();
  final Set<String> _cancelled = <String>{};
  final Set<String> _pauseRequested = <String>{};
  final Set<DownloadJob> _stoppedByUser = Set<DownloadJob>.identity();
  final Map<String, DownloadJob> _pausedJobs = <String, DownloadJob>{};
  final Object _queueControl = Object();
  DownloadJob? _activeJob;
  DownloadJob? _pausedJob;
  DownloadJob? _previousJobInBatch;
  bool _processing = false;
  int _completedInBatch = 0;
  int _batchIndex = 0;
  bool _permissionRequested = false;
  bool _recovered = false;

  int get _batchTotal => _batchIndex + _jobs.length;

  StreamSubscription<List<DownloadDomain>>? _sub;

  void init() {
    _sub?.cancel();
    _sub = downloadRepository.watchAll().listen((List<DownloadDomain> rows) {
      emit(state.copyWith(downloads: rows));
    });

    if (!_recovered) {
      _recovered = true;
      unawaited(_recoverInterrupted());
    }
    unawaited(_networkPolicy.start());
  }

  void setWifiOnly(bool value) {
    _networkPolicy.setWifiOnly(value);
  }

  Future<void> _recoverInterrupted() async {
    final List<DownloadDomain> rows =
        await downloadRepository.getPendingInQueueOrder();

    bool resumedAny = false;
    for (final DownloadDomain row in rows) {
      if (row.status == DownloadStatus.downloading) {
        await downloadRepository
            .update(row.copyWith(status: DownloadStatus.failed));
        continue;
      }
      if (row.status != DownloadStatus.queued) {
        continue;
      }
      if (await _resumeQueuedRow(row)) {
        resumedAny = true;
      }
    }
    if (resumedAny) {
      await _sortJobsByStoredOrder();
      startQueue();
    }
  }

  Future<bool> _resumeQueuedRow(DownloadDomain row) async {
    if (_hasJobInMemory(row.uid)) {
      return false;
    }
    final DownloadJob? job = await _rebuildJob(row);
    final DownloadDomain? current = await downloadRepository.getByUid(row.uid);
    if (current == null ||
        current.status != DownloadStatus.queued ||
        _cancelled.contains(row.uid) ||
        _hasJobInMemory(row.uid)) {
      return false;
    }
    if (job == null) {
      logger.w('Cannot resume ${row.uid} after a restart, marking it failed');
      await downloadRepository
          .update(current.copyWith(status: DownloadStatus.failed));
      return false;
    }
    _jobs.add(job);
    return true;
  }

  bool _hasJobInMemory(String uid) {
    return _activeJob?.uid == uid ||
        _jobs.any((DownloadJob job) => job.uid == uid);
  }

  Future<DownloadJob?> _rebuildJob(DownloadDomain row) async {
    if (row.isEpisode) {
      final AnimeVideo? episode = downloadedEpisodeOf(row);
      if (episode == null) {
        return null;
      }
      return EpisodeDownloadJob(
        extensionUid: row.extensionUid,
        concreteTitle: row.concreteTitle,
        episode: episode,
      );
    }
    return _rebuildChapterJob(row);
  }

  Future<DownloadJob?> _rebuildChapterJob(DownloadDomain row) async {
    try {
      final ExtensionDomain? extension =
          await _clients.installedExtension(row.extensionUid);
      if (extension == null) {
        return null;
      }
      final ApiClient client = await chapterClientForExtension(extension);
      final String? rawData = row.data;
      return chapterDownloadJobFor(
        client: client,
        extensionUid: row.extensionUid,
        concreteTitle: row.concreteTitle,
        chapterUid: row.uid,
        title: row.title,
        data: rawData == null
            ? null
            : jsonDecode(rawData) as Map<String, dynamic>?,
      );
    } catch (e) {
      logger.w('Cannot rebuild the download of ${row.uid}: $e');
      return null;
    }
  }

  void _addJob(DownloadJob job) {
    _jobs.removeWhere((DownloadJob queued) => queued.uid == job.uid);
    _jobs.add(job);
  }

  Future<ApiClient> chapterClientForExtension(ExtensionDomain extension) {
    return _clients.chapterClientFor(extension);
  }

  void _scheduleClientsRelease() {
    _clients.scheduleIdleRelease(
      stillIdle: () => !_processing && _jobs.isEmpty,
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

    _cancelled.remove(chapterUid);

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

    _addJob(chapterDownloadJobFor(
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

    _cancelled.remove(episode.uid);

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

    _addJob(EpisodeDownloadJob(
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

  void startQueue() {
    unawaited(_process());
  }

  Future<void> _ensurePermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      await notificationService.requestPermission();
    } catch (e, s) {
      logger.w('Failed to request download notification permission: $e');
      logger.w(s);
    }
  }

  Future<void> _process() async {
    if (_processing) return;
    _processing = true;
    _clients.cancelIdleRelease();
    _completedInBatch = 0;
    _batchIndex = 0;
    _previousJobInBatch = null;
    try {
      await _ensurePermission();
      await _networkPolicy.start();
      while (_jobs.isNotEmpty) {
        if (!_networkPolicy.allowsDownloads) {
          _setHold(DownloadQueueHold.waitingForWifi);
          break;
        }
        _setHold(DownloadQueueHold.none);
        final DownloadJob job = _jobs.removeFirst();
        if (_cancelled.contains(job.uid)) {
          _cancelled.remove(job.uid);
          continue;
        }
        unawaited(_runtime.setWanted(true));
        _activeJob = job;
        try {
          await _runActiveJob(job);
          await _settleStoppedJob(job);
        } finally {
          _activeJob = null;
          job.markUnwound();
        }
      }
    } finally {
      _processing = false;
      _batchIndex = 0;
      final int completed = _completedInBatch;
      _completedInBatch = 0;
      if (_isHeldWithQueuedJobs) {
        await _holdQueueForWifi(completed);
      } else {
        await _finishBatch(completed);
      }
      _scheduleClientsRelease();
    }
  }

  bool get _isHeldWithQueuedJobs =>
      _jobs.isNotEmpty && !_networkPolicy.allowsDownloads;

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
    if (_processing || _jobs.isNotEmpty || _activeJob != null) {
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
      if (_jobs.isNotEmpty) {
        startQueue();
      }
      return;
    }
    _pauseActiveJob();
    if (_jobs.isNotEmpty || _activeJob != null) {
      _setHold(DownloadQueueHold.waitingForWifi);
    }
  }

  void _pauseActiveJob() {
    final DownloadJob? job = _activeJob;
    if (job == null || identical(_pausedJob, job)) {
      return;
    }
    _pausedJob = job;
    job.cancel('paused');
  }

  Future<void> _settleStoppedJob(DownloadJob job) async {
    final bool heldForWifi = identical(_pausedJob, job);
    final bool stoppedByUser = _stoppedByUser.remove(job);
    if (heldForWifi) {
      _pausedJob = null;
    }
    if (!heldForWifi && !stoppedByUser) {
      return;
    }
    final DownloadDomain? row = await _unfinishedRowOf(job.uid);
    if (row == null) {
      _pauseRequested.remove(job.uid);
      return;
    }
    if (_pauseRequested.remove(job.uid)) {
      await _parkPausedJob(row, job);
      return;
    }
    await _requeueStoppedJob(row, job);
  }

  Future<DownloadDomain?> _unfinishedRowOf(String uid) async {
    if (_cancelled.contains(uid)) {
      return null;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(uid);
    if (row == null ||
        row.status == DownloadStatus.done ||
        _cancelled.contains(uid)) {
      return null;
    }
    return row;
  }

  Future<void> _parkPausedJob(DownloadDomain row, DownloadJob job) async {
    await downloadRepository
        .update(row.copyWith(status: DownloadStatus.paused));
    _pausedJobs[job.uid] = job.restarted();
    if (_batchIndex > 0) {
      _batchIndex--;
    }
  }

  Future<void> _requeueStoppedJob(DownloadDomain row, DownloadJob job) async {
    await downloadRepository
        .update(row.copyWith(status: DownloadStatus.queued));
    final bool queuedAgain =
        _jobs.any((DownloadJob queued) => queued.uid == job.uid);
    if (_cancelled.contains(job.uid) || queuedAgain) {
      return;
    }
    if (_pauseRequested.remove(job.uid)) {
      await _parkPausedJob(row, job);
      return;
    }
    _jobs.addFirst(job.restarted());
    if (_batchIndex > 0) {
      _batchIndex--;
    }
  }

  void _setHold(DownloadQueueHold hold) {
    if (isClosed || state.hold == hold) {
      return;
    }
    emit(state.copyWith(hold: hold));
  }

  void _releaseHoldIfIdle() {
    if (_jobs.isEmpty && _activeJob == null) {
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
    _batchIndex++;
    await _applyConfiguredPacing(job.extensionUid);
    if (_batchIndex > 1) {
      await waitIfPositive(_delay, _pauseBefore(job));
    }
    _previousJobInBatch = job;
    final bool completed = await _runJob(job);
    if (completed) {
      _completedInBatch++;
    }
  }

  Duration _pauseBefore(DownloadJob job) {
    final DownloadJob? previous = _previousJobInBatch;
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
      queueIndex: _batchIndex,
      queueTotal: _batchTotal,
    );
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

  Future<void> pauseDownload(String uid) => pauseDownloads(<String>[uid]);

  Future<void> resumeDownload(String uid) => resumeDownloads(<String>[uid]);

  Future<void> pauseAll() async {
    await pauseDownloads(await _pendingUidsWhere(_isPausable));
  }

  Future<void> resumeAll() async {
    await resumeDownloads(await _pendingUidsWhere(_isPaused));
  }

  Future<void> pauseTitle(String concreteUid) async {
    await pauseDownloads(await _pendingUidsWhere((DownloadDomain row) =>
        row.concreteUid == concreteUid && _isPausable(row)));
  }

  Future<void> resumeTitle(String concreteUid) async {
    await resumeDownloads(await _pendingUidsWhere((DownloadDomain row) =>
        row.concreteUid == concreteUid && _isPaused(row)));
  }

  Future<void> pauseDownloads(Iterable<String> uids) {
    final List<String> targets = uids.toList();
    return runSerializedOn<void>(_queueControl, () => _pauseAll(targets));
  }

  Future<void> resumeDownloads(Iterable<String> uids) {
    final List<String> targets = uids.toList();
    return runSerializedOn<void>(_queueControl, () => _resumeAll(targets));
  }

  Future<void> reorderQueue(List<String> orderedUids) {
    return runSerializedOn<void>(
      _queueControl,
      () => _applyQueueOrder((List<String> pending) => orderedUids),
    );
  }

  Future<void> downloadNext(String uid) {
    return runSerializedOn<void>(_queueControl, () async {
      await _applyQueueOrder((List<String> pending) => <String>[uid]);
      await _resumeAll(<String>[uid]);
    });
  }

  Future<void> moveTitleToTop(String concreteUid) {
    return runSerializedOn<void>(_queueControl, () async {
      final Set<String> titleUids = (await downloadRepository
              .getByConcreteUid(concreteUid))
          .map((DownloadDomain row) => row.uid)
          .toSet();
      await _applyQueueOrder((List<String> pending) =>
          pending.where(titleUids.contains).toList());
    });
  }

  static bool _isPausable(DownloadDomain row) =>
      row.status == DownloadStatus.queued ||
      row.status == DownloadStatus.downloading;

  static bool _isPaused(DownloadDomain row) =>
      row.status == DownloadStatus.paused;

  Future<List<String>> _pendingUidsWhere(
      bool Function(DownloadDomain row) test) async {
    final List<DownloadDomain> pending =
        await downloadRepository.getPendingInQueueOrder();
    return pending.where(test).map((DownloadDomain row) => row.uid).toList();
  }

  Future<void> _pauseAll(List<String> uids) async {
    _detachWaitingJobs(uids);
    final String? activeUid = _activeJob?.uid;
    for (final String uid in uids) {
      if (uid != activeUid) {
        await _pauseWaiting(uid);
      }
    }
    if (activeUid != null && uids.contains(activeUid)) {
      _pauseActive(activeUid);
    }
    await _settleEmptiedQueue();
  }

  void _detachWaitingJobs(List<String> uids) {
    final Set<String> targets = uids.toSet();
    for (final DownloadJob job in _jobs.toList()) {
      if (targets.contains(job.uid)) {
        _jobs.remove(job);
        _pausedJobs[job.uid] = job;
      }
    }
  }

  void _pauseActive(String uid) {
    final DownloadJob? job = _activeJob;
    if (job == null || job.uid != uid) {
      return;
    }
    _pauseRequested.add(uid);
    _stoppedByUser.add(job);
    job.cancel('paused');
  }

  Future<void> _pauseWaiting(String uid) async {
    if (_activeJob?.uid == uid) {
      _pauseActive(uid);
      return;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(uid);
    if (row == null || !_isPausable(row) || _cancelled.contains(uid)) {
      return;
    }
    await downloadRepository
        .update(row.copyWith(status: DownloadStatus.paused));
  }

  Future<void> _resumeAll(List<String> uids) async {
    bool resumedAny = false;
    for (final String uid in uids) {
      if (await _resumeOne(uid)) {
        resumedAny = true;
      }
    }
    if (!resumedAny) {
      return;
    }
    await _sortJobsByStoredOrder();
    startQueue();
  }

  Future<bool> _resumeOne(String uid) async {
    if (_pauseRequested.remove(uid)) {
      return false;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(uid);
    if (row == null || !_isPaused(row) || _hasJobInMemory(uid)) {
      return false;
    }
    final DownloadJob? job = await _resumableJob(row);
    final DownloadDomain? current = await downloadRepository.getByUid(uid);
    if (current == null ||
        !_isPaused(current) ||
        _cancelled.contains(uid) ||
        _hasJobInMemory(uid)) {
      return false;
    }
    if (job == null) {
      logger.w('Cannot resume $uid, marking it failed');
      _pausedJobs.remove(uid);
      await downloadRepository
          .update(current.copyWith(status: DownloadStatus.failed));
      return false;
    }
    await downloadRepository
        .update(current.copyWith(status: DownloadStatus.queued));
    if (_cancelled.contains(uid) || _hasJobInMemory(uid)) {
      return false;
    }
    _pausedJobs.remove(uid);
    _jobs.add(job);
    return true;
  }

  Future<DownloadJob?> _resumableJob(DownloadDomain row) async {
    final DownloadJob? rebuilt = await _rebuildJob(row);
    if (rebuilt != null) {
      return rebuilt;
    }
    return _pausedJobs[row.uid]?.restarted();
  }

  Future<void> _applyQueueOrder(
    List<String> Function(List<String> pending) pickFirst,
  ) async {
    final List<String> pending = (await downloadRepository
            .getPendingInQueueOrder())
        .map((DownloadDomain row) => row.uid)
        .toList();
    final List<String> order = _queueOrder(pending, pickFirst(pending));
    await downloadRepository.writeQueueOrder(order);
    _sortJobs(order);
  }

  List<String> _queueOrder(List<String> pending, List<String> first) {
    final Set<String> pendingUids = pending.toSet();
    final String? activeUid = _activeJob?.uid;
    final List<String> order = <String>[];
    void place(String uid) {
      if (pendingUids.contains(uid) && !order.contains(uid)) {
        order.add(uid);
      }
    }

    if (activeUid != null) {
      place(activeUid);
    }
    first.forEach(place);
    pending.forEach(place);
    return order;
  }

  Future<void> _sortJobsByStoredOrder() async {
    final List<DownloadDomain> pending =
        await downloadRepository.getPendingInQueueOrder();
    _sortJobs(pending.map((DownloadDomain row) => row.uid).toList());
  }

  void _sortJobs(List<String> order) {
    final Map<String, int> rank = <String, int>{
      for (int index = 0; index < order.length; index++) order[index]: index,
    };
    final List<DownloadJob> waiting = _jobs.toList();
    final Map<DownloadJob, int> arrival = Map<DownloadJob, int>.identity();
    for (int index = 0; index < waiting.length; index++) {
      arrival[waiting[index]] = index;
    }
    int rankOf(DownloadJob job) =>
        rank[job.uid] ?? order.length + arrival[job]!;
    waiting.sort(
        (DownloadJob a, DownloadJob b) => rankOf(a).compareTo(rankOf(b)));
    _jobs
      ..clear()
      ..addAll(waiting);
  }

  Future<void> deleteDownload(DownloadDomain download) async {
    final String uid = download.uid;
    _cancelled.add(uid);
    _pausedJobs.remove(uid);
    _jobs.removeWhere((DownloadJob j) => j.uid == uid);
    final DownloadJob? activeJob = _activeJob?.uid == uid ? _activeJob : null;
    activeJob?.cancel();
    await _settleEmptiedQueue();
    await downloadRepository.deleteByUid(uid);
    final bool unwound = await _waitForUnwind(activeJob);
    await DownloadFiles.deleteDir(download.dirPath);
    if (unwound) {
      _cancelled.remove(uid);
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
