import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/config_info/download_config/download_config.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_source_resolver.dart';
import 'package:wakaranai/services/downloads/runtime/download_network_policy.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';
import 'package:wakaranai/utils/http_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';

part 'download_manager_state.dart';

typedef QualityPreferenceReader = Future<QualityPreference> Function();

sealed class _DownloadJob {
  final String extensionUid;
  final String concreteTitle;
  final CancelToken cancelToken = CancelToken();
  final Completer<void> _unwound = Completer<void>();

  _DownloadJob({
    required this.extensionUid,
    required this.concreteTitle,
  });

  String get uid;

  String get title;

  Future<void> get unwound => _unwound.future;

  bool get isCancelled => cancelToken.isCancelled;

  void markUnwound() {
    if (!_unwound.isCompleted) {
      _unwound.complete();
    }
  }

  void cancel([String reason = 'deleted']) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel(reason);
    }
  }

  _DownloadJob restarted();
}

class _ChapterJob extends _DownloadJob {
  final MangaApiClient client;
  final String chapterUid;
  final String chapterTitle;
  final Map<String, dynamic>? data;

  _ChapterJob({
    required this.client,
    required super.extensionUid,
    required super.concreteTitle,
    required this.chapterUid,
    required this.chapterTitle,
    required this.data,
  });

  @override
  String get uid => chapterUid;

  @override
  String get title => chapterTitle;

  @override
  _ChapterJob restarted() => _ChapterJob(
        client: client,
        extensionUid: extensionUid,
        concreteTitle: concreteTitle,
        chapterUid: chapterUid,
        chapterTitle: chapterTitle,
        data: data,
      );
}

class _EpisodeJob extends _DownloadJob {
  final AnimeVideo episode;

  _EpisodeJob({
    required super.extensionUid,
    required super.concreteTitle,
    required this.episode,
  });

  @override
  String get uid => episode.uid;

  @override
  String get title => episode.title;

  @override
  _EpisodeJob restarted() => _EpisodeJob(
        extensionUid: extensionUid,
        concreteTitle: concreteTitle,
        episode: episode,
      );
}

class _EpisodeProgressRecorder {
  _EpisodeProgressRecorder({required this.interval, required this.publish});

  final Duration interval;
  final Future<void> Function(EpisodeDownloadProgress progress) publish;
  final Stopwatch _sinceLastPublish = Stopwatch();
  Future<void> _publishing = Future<void>.value();
  EpisodeDownloadProgress? _unpublished;

  void record(EpisodeDownloadProgress progress) {
    final bool due = !_sinceLastPublish.isRunning ||
        _sinceLastPublish.elapsed >= interval;
    if (!due) {
      _unpublished = progress;
      return;
    }
    _sinceLastPublish
      ..reset()
      ..start();
    _unpublished = null;
    _enqueue(progress);
  }

  Future<void> flush() {
    final EpisodeDownloadProgress? pending = _unpublished;
    _unpublished = null;
    if (pending != null) {
      _enqueue(pending);
    }
    return _publishing;
  }

  void _enqueue(EpisodeDownloadProgress progress) {
    _publishing = _publishing.then((_) => publish(progress));
  }
}

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
  })  : notificationService =
            notificationService ?? DownloadNotificationService(),
        _injectedSourceResolver = episodeSourceResolver,
        _injectedEpisodeDownloader = episodeDownloader,
        _readQualityPreference = readQualityPreference ??
            PlayerPreferences().getQualityPreference,
        _runtime = downloadRuntime ?? createDownloadRuntime(),
        _networkPolicy = networkPolicy ?? DownloadNetworkPolicy.platform(),
        super(const DownloadManagerState()) {
    _runtimeEvents = _runtime.events.listen(_onRuntimeEvent);
    _networkPolicyChanges =
        _networkPolicy.changes.listen(_onNetworkPolicyChanged);
  }

  final DownloadRepository downloadRepository;
  final ExtensionRepository? extensionRepository;
  final DownloadNotificationService notificationService;
  final EpisodeSourceResolver? _injectedSourceResolver;
  final EpisodeDownloader? _injectedEpisodeDownloader;
  final QualityPreferenceReader _readQualityPreference;
  final DownloadRuntime _runtime;
  final DownloadNetworkPolicy _networkPolicy;
  late final StreamSubscription<DownloadRuntimeEvent> _runtimeEvents;
  late final StreamSubscription<bool> _networkPolicyChanges;

  static const Duration _progressPersistInterval = Duration(milliseconds: 700);
  static const int _pageAttempts = 3;
  static const int _rateLimitAttempts = 6;
  static const int _episodeSourceRefreshes = 2;
  static const Duration _libraryClientsIdleTimeout = Duration(minutes: 2);
  static const Duration _jobUnwindTimeout = Duration(seconds: 10);

  final Dio _dio = createDio();
  final DownloadThrottle _throttle = DownloadThrottle();
  final PreparedClientPool _libraryClients = PreparedClientPool();
  late final EpisodeSourceResolver _episodeSources = _injectedSourceResolver ??
      PooledClientEpisodeSourceResolver(loadClient: _animeClientForUid);
  late final EpisodeDownloader _episodeDownloader =
      _injectedEpisodeDownloader ?? EpisodeDownloader(throttle: _throttle);
  Timer? _libraryClientsIdle;
  final Queue<_DownloadJob> _jobs = Queue<_DownloadJob>();
  final Set<String> _cancelled = <String>{};
  _DownloadJob? _activeJob;
  _DownloadJob? _pausedJob;
  bool _processing = false;
  bool _runtimeWanted = false;
  bool _runtimeRunning = false;
  Future<void> _runtimeSync = Future<void>.value();
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
    final List<DownloadDomain> rows = await downloadRepository.getAll();

    for (final DownloadDomain row in rows) {
      if (row.status != DownloadStatus.queued &&
          row.status != DownloadStatus.downloading) {
        continue;
      }
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.failed));
    }
  }

  Future<MangaApiClient> clientForExtension(ExtensionDomain extension) async {
    final ApiClient client = await _pooledClientFor(extension);
    if (client is! MangaApiClient) {
      throw StateError('${extension.config.name} is not a manga extension');
    }
    return client;
  }

  Future<AnimeApiClient> animeClientForExtension(
      ExtensionDomain extension) async {
    final ApiClient client = await _pooledClientFor(extension);
    if (client is! AnimeApiClient) {
      throw StateError('${extension.config.name} is not an anime extension');
    }
    return client;
  }

  Future<ApiClient> _pooledClientFor(ExtensionDomain extension) {
    _libraryClientsIdle?.cancel();
    return _libraryClients.clientFor(extension);
  }

  Future<AnimeApiClient> _animeClientForUid(String extensionUid) async {
    final ExtensionDomain? extension = await _installedExtension(extensionUid);
    if (extension == null) {
      throw StateError('Extension $extensionUid is not installed');
    }
    return animeClientForExtension(extension);
  }

  Future<ExtensionDomain?> _installedExtension(String extensionUid) async {
    final ExtensionRepository? extensions = extensionRepository;
    if (extensions == null) {
      return null;
    }
    return extensions.getByUid(extensionUid);
  }

  bool isDownloaded(String chapterUid) {
    return state.downloads.any((DownloadDomain d) =>
        d.uid == chapterUid && d.status == DownloadStatus.done);
  }

  static bool _isPendingOrDone(DownloadDomain? existing) {
    if (existing == null) {
      return false;
    }
    return existing.status == DownloadStatus.done ||
        existing.status == DownloadStatus.downloading ||
        existing.status == DownloadStatus.queued;
  }

  Future<void> enqueueChapter({
    required MangaApiClient client,
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
        await _chapterDir(extensionUid, concreteUid, chapterUid);

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
        createdAt: DateTime.now(),
      ),
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );

    _jobs.add(_ChapterJob(
      client: client,
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      chapterUid: chapterUid,
      chapterTitle: title,
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

    _jobs.add(_EpisodeJob(
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
        await _chapterDir(extensionUid, concreteUid, episode.uid);
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
        await _installedExtension(download.extensionUid);
    if (extension == null) {
      logger.w('Cannot retry ${download.uid}: extension '
          '${download.extensionUid} is not installed');
      return;
    }
    try {
      final MangaApiClient client = await clientForExtension(extension);
      await retry(client: client, download: download);
    } catch (e, s) {
      logger.e('Cannot retry ${download.uid}: $e');
      logger.e(s);
      if (!_processing) {
        _scheduleLibraryClientsRelease();
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

  void _scheduleLibraryClientsRelease() {
    _libraryClientsIdle?.cancel();
    if (_libraryClients.isEmpty) {
      return;
    }
    _libraryClientsIdle = Timer(_libraryClientsIdleTimeout, () {
      if (!_processing && _jobs.isEmpty) {
        unawaited(_libraryClients.dispose());
      }
    });
  }

  Future<void> _process() async {
    if (_processing) return;
    _processing = true;
    _libraryClientsIdle?.cancel();
    _completedInBatch = 0;
    _batchIndex = 0;
    try {
      await _ensurePermission();
      await _networkPolicy.start();
      while (_jobs.isNotEmpty) {
        if (!_networkPolicy.allowsDownloads) {
          _setHold(DownloadQueueHold.waitingForWifi);
          break;
        }
        _setHold(DownloadQueueHold.none);
        final _DownloadJob job = _jobs.removeFirst();
        if (_cancelled.contains(job.uid)) {
          _cancelled.remove(job.uid);
          continue;
        }
        unawaited(_setRuntimeWanted(true));
        _activeJob = job;
        try {
          await _runActiveJob(job);
          await _requeueIfPaused(job);
        } finally {
          _activeJob = null;
          job.markUnwound();
        }
      }
    } finally {
      _processing = false;
      _batchIndex = 0;
      if (_completedInBatch > 0) {
        await notificationService.showComplete(_completedInBatch);
      }
      _completedInBatch = 0;
      _releaseHoldIfIdle();
      await _stopRuntimeIfIdle();
      _scheduleLibraryClientsRelease();
    }
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
    final _DownloadJob? job = _activeJob;
    if (job == null || identical(_pausedJob, job)) {
      return;
    }
    _pausedJob = job;
    job.cancel('paused');
  }

  Future<void> _requeueIfPaused(_DownloadJob job) async {
    if (!identical(_pausedJob, job)) {
      return;
    }
    _pausedJob = null;
    if (_cancelled.contains(job.uid)) {
      return;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(job.uid);
    if (row == null ||
        row.status == DownloadStatus.done ||
        _cancelled.contains(job.uid)) {
      return;
    }
    await downloadRepository
        .update(row.copyWith(status: DownloadStatus.queued));
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
    await _setRuntimeWanted(false);
  }

  Future<void> _setRuntimeWanted(bool wanted) {
    _runtimeWanted = wanted;
    return _runtimeSync = _runtimeSync.then((_) => _syncRuntime());
  }

  Future<void> _syncRuntime() async {
    try {
      final bool wanted = _runtimeWanted && !isClosed;
      if (!wanted) {
        await _stopRuntime();
        return;
      }
      if (_runtimeRunning) {
        return;
      }
      _onRuntimeStart(await _runtime.start());
    } catch (e, s) {
      logger.w('Could not update the download service: $e');
      logger.w(s);
    }
  }

  Future<void> _stopRuntime() async {
    if (_runtimeRunning) {
      _runtimeRunning = false;
      await _runtime.stop();
    }
    _setRuntimeStatus(DownloadRuntimeStatus.inactive);
  }

  void _onRuntimeStart(DownloadRuntimeStart outcome) {
    switch (outcome) {
      case DownloadRuntimeStart.started:
      case DownloadRuntimeStart.alreadyRunning:
        _runtimeRunning = true;
        _setRuntimeStatus(DownloadRuntimeStatus.active);
        break;
      case DownloadRuntimeStart.notAllowed:
        logger.w('Downloads could not enter the foreground; they continue '
            'only while the app stays open');
        _markRuntimeRestricted(DownloadRuntimeStatus.startNotAllowed);
        break;
      case DownloadRuntimeStart.unsupported:
        break;
    }
  }

  void _onRuntimeEvent(DownloadRuntimeEvent event) {
    switch (event) {
      case DownloadRuntimeEvent.startNotAllowed:
        logger.w('The download service was refused the foreground; '
            'downloads continue only while the app stays open');
        _markRuntimeRestricted(DownloadRuntimeStatus.startNotAllowed);
        break;
      case DownloadRuntimeEvent.timedOut:
        logger.w('The download service reached its Android time limit; '
            'downloads continue only while the app stays open');
        _markRuntimeRestricted(DownloadRuntimeStatus.timedOut);
        break;
    }
  }

  void _markRuntimeRestricted(DownloadRuntimeStatus status) {
    _runtimeRunning = false;
    if (state.runtimeStatus == DownloadRuntimeStatus.timedOut) {
      return;
    }
    _setRuntimeStatus(status);
  }

  void _setRuntimeStatus(DownloadRuntimeStatus status) {
    if (isClosed || state.runtimeStatus == status) {
      return;
    }
    emit(state.copyWith(runtimeStatus: status));
  }


  Future<void> _runActiveJob(_DownloadJob job) async {
    _batchIndex++;
    await _applyConfiguredPacing(job.extensionUid);
    if (_batchIndex > 1) {
      await _wait(_throttle.chapterDelay(job.extensionUid));
    }
    final bool completed = await _runJob(job);
    if (completed) {
      _completedInBatch++;
    }
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
      );
    } catch (e) {
      logger.w('Could not read download pacing for $extensionUid: $e');
    }
  }

  Future<bool> _runJob(_DownloadJob job) {
    switch (job) {
      case _ChapterJob():
        return _runChapterJob(job);
      case _EpisodeJob():
        return _runEpisodeJob(job);
    }
  }

  Future<void> _showJobProgress(
    _DownloadJob job, {
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

  Future<void> _markFailed(String uid) async {
    final DownloadDomain? current = await downloadRepository.getByUid(uid);
    if (current != null) {
      await downloadRepository
          .update(current.copyWith(status: DownloadStatus.failed));
    }
  }

  Future<bool> _runChapterJob(_ChapterJob job) async {
    if (job.isCancelled) {
      return false;
    }
    DownloadDomain? row = await downloadRepository.getByUid(job.chapterUid);
    if (row == null || job.isCancelled) {
      return false;
    }

    final CancelToken cancelToken = job.cancelToken;

    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await _showJobProgress(job, progress: 0, max: 0);

      final pages =
          await job.client.getPages(uid: job.chapterUid, data: job.data);
      final Map<String, String> headers = await job.client
          .getImageHeaders(uid: pages.chapterUid, data: <String, dynamic>{});
      final String headersJson = jsonEncode(headers);

      final Directory dir = Directory(row.dirPath);
      await dir.create(recursive: true);

      row = row.copyWith(
        totalPages: pages.value.length,
        downloadedPages: 0,
        headers: headersJson,
        status: DownloadStatus.downloading,
      );
      await downloadRepository.update(row);

      DateTime lastPublish = DateTime.fromMillisecondsSinceEpoch(0);

      for (int i = 0; i < pages.value.length; i++) {
        if (_cancelled.contains(job.chapterUid)) {
          _cancelled.remove(job.chapterUid);
          return false;
        }
        if (cancelToken.isCancelled) {
          return false;
        }

        final String url = pages.value[i];
        final File file = File(p.join(dir.path, _pageFileName(i)));

        if (i > 0) {
          await _wait(_throttle.pageDelay(job.extensionUid));
        }
        await _writePage(
          url: url,
          file: file,
          headers: headers,
          extensionUid: job.extensionUid,
          cancelToken: cancelToken,
        );

        row = row!.copyWith(downloadedPages: i + 1);

        final bool last = i == pages.value.length - 1;
        final DateTime now = DateTime.now();
        if (last || now.difference(lastPublish) >= _progressPersistInterval) {
          lastPublish = now;
          await downloadRepository.update(row);
          await _showJobProgress(
            job,
            progress: i + 1,
            max: pages.value.length,
          );
        }
      }

      await downloadRepository.update(row!.copyWith(
        status: DownloadStatus.done,
        downloadedPages: pages.value.length,
        totalPages: pages.value.length,
      ));
      return true;
    } catch (e, s) {
      if (cancelToken.isCancelled ||
          (e is DioException && CancelToken.isCancel(e))) {
        return false;
      }
      logger.e('Download failed for ${job.chapterUid}: $e');
      logger.e(s);
      await _markFailed(job.chapterUid);
      return false;
    }
  }

  Future<bool> _runEpisodeJob(_EpisodeJob job) async {
    if (job.isCancelled) {
      return false;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(job.uid);
    if (row == null || job.isCancelled) {
      return false;
    }

    final CancelToken cancelToken = job.cancelToken;
    final _EpisodeProgressRecorder recorder = _EpisodeProgressRecorder(
      interval: _progressPersistInterval,
      publish: (EpisodeDownloadProgress progress) =>
          _publishEpisodeProgress(job, cancelToken, progress),
    );

    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await _showJobProgress(job, progress: 0, max: 0);

      final EpisodeDownloadManifest manifest = await _downloadEpisode(
        job: job,
        dir: Directory(row.dirPath),
        cancelToken: cancelToken,
        recorder: recorder,
      );
      await recorder.flush();
      return await _completeEpisode(job, manifest);
    } catch (e, s) {
      await recorder.flush();
      if (cancelToken.isCancelled ||
          (e is DioException && CancelToken.isCancel(e))) {
        return false;
      }
      logger.e('Episode download failed for ${job.uid}: $e');
      logger.e(s);
      await _markFailed(job.uid);
      return false;
    }
  }

  Future<EpisodeDownloadManifest> _downloadEpisode({
    required _EpisodeJob job,
    required Directory dir,
    required CancelToken cancelToken,
    required _EpisodeProgressRecorder recorder,
  }) async {
    final QualityPreference quality = await _readQualityPreference();
    int refreshes = 0;
    while (true) {
      final PlayableVideo video = await _episodeSources.resolve(
        extensionUid: job.extensionUid,
        episode: job.episode,
      );
      _throwIfCancelled(cancelToken);
      try {
        return await _episodeDownloader.download(
          video: video,
          quality: quality,
          dir: dir,
          throttleKey: job.extensionUid,
          cancelToken: cancelToken,
          onProgress: recorder.record,
        );
      } on EpisodeSourceExpired catch (e) {
        if (refreshes >= _episodeSourceRefreshes) {
          rethrow;
        }
        refreshes++;
        logger.w('Sources of ${job.uid} expired ($e), resolving them again');
      }
    }
  }

  void _throwIfCancelled(CancelToken cancelToken) {
    final DioException? cancelError = cancelToken.cancelError;
    if (cancelError != null) {
      throw cancelError;
    }
  }

  Future<bool> _completeEpisode(
    _EpisodeJob job,
    EpisodeDownloadManifest manifest,
  ) async {
    if (job.isCancelled) {
      return false;
    }
    final DownloadDomain? current = await downloadRepository.getByUid(job.uid);
    if (current == null || job.isCancelled) {
      return false;
    }
    await downloadRepository.update(current.copyWith(
      status: DownloadStatus.done,
      playback: manifest.encode(),
    ));
    return true;
  }

  Future<void> _publishEpisodeProgress(
    _EpisodeJob job,
    CancelToken cancelToken,
    EpisodeDownloadProgress progress,
  ) async {
    if (cancelToken.isCancelled) {
      return;
    }
    try {
      final DownloadDomain? current =
          await downloadRepository.getByUid(job.uid);
      if (current == null || cancelToken.isCancelled) {
        return;
      }
      await downloadRepository.update(current.copyWith(
        downloadedPages: progress.completedSegments,
        totalPages: progress.totalSegments,
        downloadedBytes: progress.downloadedBytes,
        totalBytes: progress.totalBytes,
      ));
      final (int done, int max) = _episodeNotificationProgress(progress);
      await _showJobProgress(job, progress: done, max: max);
    } catch (e) {
      logger.w('Could not record progress of ${job.uid}: $e');
    }
  }

  static (int, int) _episodeNotificationProgress(
      EpisodeDownloadProgress progress) {
    if (progress.totalSegments > 0) {
      return (progress.completedSegments, progress.totalSegments);
    }
    if (progress.totalBytes > 0) {
      final int percent =
          (progress.downloadedBytes * 100 ~/ progress.totalBytes).clamp(0, 100);
      return (percent, 100);
    }
    return (0, 0);
  }

  Future<void> _wait(Duration duration) async {
    if (duration > Duration.zero) {
      await Future<void>.delayed(duration);
    }
  }

  bool _isRateLimited(Object error) {
    if (error is! DioException) {
      return false;
    }
    final int? status = error.response?.statusCode;
    return status == HttpStatus.tooManyRequests ||
        status == HttpStatus.serviceUnavailable;
  }

  Future<void> _writePage({
    required String url,
    required File file,
    required Map<String, String> headers,
    required String extensionUid,
    required CancelToken cancelToken,
  }) async {
    if (url.startsWith('data:')) {
      final Uint8List bytes = base64Decode(url.split(',').last);
      if (bytes.isEmpty) {
        throw StateError('Empty inline page data');
      }
      await file.writeAsBytes(bytes);
      return;
    }

    Object? lastError;
    int failures = 0;
    int rateLimits = 0;

    while (failures < _pageAttempts && rateLimits < _rateLimitAttempts) {
      try {
        final Response<List<int>> response = await _dio.get<List<int>>(
          url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.bytes,
            headers: headers,
          ),
        );

        final List<int>? data = response.data;
        if (data == null || data.isEmpty) {
          throw StateError('Empty response for $url');
        }

        await file.writeAsBytes(data);
        return;
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) rethrow;
        lastError = e;
        if (_isRateLimited(e)) {
          rateLimits++;
          _throttle.rateLimited(extensionUid);
          final String? retryAfter = (e as DioException)
              .response
              ?.headers
              .value(HttpHeaders.retryAfterHeader);
          logger.w('Rate limited on $url, attempt $rateLimits');
          await _wait(
            _throttle.retryWait(rateLimits, retryAfterHeader: retryAfter),
          );
          continue;
        }
        failures++;
        if (failures < _pageAttempts) {
          await _wait(Duration(milliseconds: 300 * failures));
        }
      }
    }

    throw StateError('Failed to download $url: $lastError');
  }

  Future<void> retry({
    required MangaApiClient client,
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

  Future<void> deleteDownload(DownloadDomain download) async {
    final String uid = download.uid;
    _cancelled.add(uid);
    _jobs.removeWhere((_DownloadJob j) => j.uid == uid);
    final _DownloadJob? activeJob = _activeJob?.uid == uid ? _activeJob : null;
    activeJob?.cancel();
    if (!_processing) {
      _releaseHoldIfIdle();
    }
    await downloadRepository.deleteByUid(uid);
    final bool unwound = await _waitForUnwind(activeJob);
    await _deleteDir(download.dirPath);
    if (unwound) {
      _cancelled.remove(uid);
    }
  }

  Future<bool> _waitForUnwind(_DownloadJob? job) async {
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

  Future<void> _deleteDir(String dirPath) async {
    try {
      final Directory dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      logger.w('Failed to delete download dir $dirPath: $e');
    }
  }

  Future<Directory> _chapterDir(
      String extensionUid, String concreteUid, String chapterUid) async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(
      docs.path,
      'downloads',
      _sanitize(extensionUid),
      _sanitize(concreteUid),
      _sanitize(chapterUid),
    ));
  }

  static String _sanitize(String value) {
    final String cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final String suffix = value.hashCode.toUnsigned(32).toRadixString(16);
    if (cleaned.length <= 80) return '${cleaned}_$suffix';
    return '${cleaned.substring(0, 80)}_$suffix';
  }

  static String _pageFileName(int index) =>
      '${index.toString().padLeft(4, '0')}.img';

  static List<String> localPagePaths(DownloadDomain download) =>
      List<String>.generate(download.totalPages,
          (int i) => p.join(download.dirPath, _pageFileName(i)));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _networkPolicyChanges.cancel();
    await _runtimeEvents.cancel();
    await _setRuntimeWanted(false);
    await _networkPolicy.dispose();
    await _runtime.dispose();
    _libraryClientsIdle?.cancel();
    await _libraryClients.dispose();
    return super.close();
  }
}
