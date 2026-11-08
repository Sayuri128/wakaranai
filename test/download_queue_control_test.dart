import 'dart:async';
import 'dart:io';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_source_resolver.dart';
import 'package:wakaranai/services/downloads/runtime/download_network_policy.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';
import 'package:wakaranai/services/downloads/runtime/network_monitor.dart';

const EpisodeDownloadManifest _manifest = EpisodeDownloadManifest(
  format: EpisodeMediaFormat.hls,
  file: 'index.m3u8',
  quality: '720p',
);

const String _threePageScript = '''
import "manga_models";

function getPages(uid, data) {
    return buildPages({"uid": uid, "value": [
        "data:image/png;base64,iVBORw0KGgo=",
        "data:image/png;base64,iVBORw0KGgo=",
        "data:image/png;base64,iVBORw0KGgo="
    ]});
}

function getImageHeaders(uid, data) { return {}; }
''';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.docs);

  final String docs;

  @override
  Future<String?> getApplicationDocumentsPath() async => docs;
}

class _SilentNotifications extends DownloadNotificationService {
  int completed = -1;
  int waitingShown = 0;
  int progressCancelled = 0;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> showProgress({
    required String title,
    required String chapterTitle,
    required int progress,
    required int max,
    int queueIndex = 0,
    int queueTotal = 0,
  }) async {}

  @override
  Future<void> showComplete(int count) async {
    completed = count;
  }

  @override
  Future<void> showWaitingForWifi() async {
    waitingShown++;
  }

  @override
  Future<void> cancelProgress() async {
    progressCancelled++;
  }
}

class _FakeRuntime implements DownloadRuntime {
  final List<String> calls = <String>[];
  final StreamController<DownloadRuntimeEvent> _events =
      StreamController<DownloadRuntimeEvent>.broadcast();

  bool get running {
    final int lastStart = calls.lastIndexOf('start');
    final int lastStop = calls.lastIndexOf('stop');
    return lastStart > lastStop;
  }

  @override
  Stream<DownloadRuntimeEvent> get events => _events.stream;

  @override
  Future<DownloadRuntimeStart> start() async {
    calls.add('start');
    return DownloadRuntimeStart.started;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  @override
  Future<void> dispose() async {
    await _events.close();
  }
}

class _FakeNetworkMonitor implements NetworkMonitor {
  _FakeNetworkMonitor(this.connection);

  NetworkConnection connection;
  final StreamController<NetworkConnection> _changes =
      StreamController<NetworkConnection>.broadcast();

  void change(NetworkConnection next) {
    connection = next;
    _changes.add(next);
  }

  @override
  Future<NetworkConnection> current() async => connection;

  @override
  Stream<NetworkConnection> get changes => _changes.stream;
}

class _FakeSourceResolver implements EpisodeSourceResolver {
  @override
  Future<PlayableVideo> resolve({
    required String extensionUid,
    required AnimeVideo episode,
  }) async {
    return PlayableVideo(
      streams: <PlayableStream>[
        PlayableStream(url: 'https://cdn.test/${episode.uid}.m3u8'),
      ],
    );
  }
}

class _Call {
  _Call(this.uid, this.dir, this.cancelToken);

  final String uid;
  final Directory dir;
  final CancelToken cancelToken;
}

class _ControlledDownloader extends EpisodeDownloader {
  final List<_Call> calls = <_Call>[];
  final Map<String, Completer<void>> _releases = <String, Completer<void>>{};
  bool holdDownloads = false;

  List<String> get uids => calls.map((_Call call) => call.uid).toList();

  void release(String uid) {
    _releases.putIfAbsent(uid, Completer<void>.new);
    if (!_releases[uid]!.isCompleted) {
      _releases[uid]!.complete();
    }
  }

  void releaseAll(Iterable<String> uids) {
    uids.forEach(release);
  }

  @override
  Future<EpisodeDownloadManifest> download({
    required PlayableVideo video,
    required QualityPreference quality,
    required Directory dir,
    required String throttleKey,
    required CancelToken cancelToken,
    EpisodeProgressCallback? onProgress,
  }) async {
    final String uid = _uidOf(video);
    calls.add(_Call(uid, dir, cancelToken));
    onProgress?.call(const EpisodeDownloadProgress(
      completedSegments: 4,
      totalSegments: 10,
      downloadedBytes: 4096,
      totalBytes: 0,
    ));
    if (!holdDownloads) {
      return _manifest;
    }
    final Completer<void> gate =
        _releases.putIfAbsent(uid, Completer<void>.new);
    await Future.any(<Future<void>>[
      gate.future,
      cancelToken.whenCancel.then((DioException e) => throw e),
    ]);
    return _manifest;
  }

  static String _uidOf(PlayableVideo video) {
    final String url = video.streams.single.url;
    return url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));
  }
}

AnimeVideo _episode(String uid) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/embed',
    title: 'Episode $uid',
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late WakaranaiDatabase db;
  late DownloadRepository repository;
  late _SilentNotifications notifications;
  late _FakeRuntime runtime;
  late _FakeNetworkMonitor monitor;
  late _ControlledDownloader downloader;
  late DownloadManagerCubit cubit;

  DownloadManagerCubit buildCubit({
    bool wifiOnly = false,
    NetworkConnection connection = NetworkConnection.wifi,
  }) {
    monitor = _FakeNetworkMonitor(connection);
    return DownloadManagerCubit(
      downloadRepository: repository,
      notificationService: notifications,
      episodeSourceResolver: _FakeSourceResolver(),
      episodeDownloader: downloader,
      readQualityPreference: () async =>
          const QualityPreference(streamLabel: '720p'),
      downloadRuntime: runtime,
      networkPolicy: DownloadNetworkPolicy(
        monitor: monitor,
        readWifiOnly: () async => wifiOnly,
      ),
    );
  }

  Future<void> enqueue(
    String uid, {
    String concreteUid = 'concrete',
    bool autoStart = true,
  }) {
    return cubit.enqueueEpisode(
      extensionUid: 'anime-ext',
      concreteUid: concreteUid,
      concreteId: 1,
      concreteTitle: 'Title $concreteUid',
      concreteCover: null,
      episode: _episode(uid),
      autoStart: autoStart,
    );
  }

  Future<DownloadStatus?> statusOf(String uid) async {
    return (await repository.getByUid(uid))?.status;
  }

  Future<List<String>> storedOrder() async {
    return (await repository.getPendingInQueueOrder())
        .map((DownloadDomain row) => row.uid)
        .toList();
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wakaranai_queue_control');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    repository = DownloadRepository(database: db);
    notifications = _SilentNotifications();
    runtime = _FakeRuntime();
    downloader = _ControlledDownloader();
    cubit = buildCubit();
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
    await db.close();
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      return;
    }
  });

  group('pause and resume', () {
    test('pausing the in-flight episode keeps its progress and resumes once',
        () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() => downloader.calls.isNotEmpty);
      await _until(() async =>
          (await repository.getByUid('e1'))!.downloadedBytes > 0);
      final _Call first = downloader.calls.single;

      await cubit.pauseDownload('e1');
      final DownloadDomain? paused =
          await _awaitStatus(repository, 'e1', DownloadStatus.paused);

      expect(first.cancelToken.isCancelled, isTrue);
      expect(paused!.downloadedBytes, 4096);
      expect(paused.downloadedPages, 4);
      expect(paused.totalPages, 10);

      await cubit.resumeDownload('e1');
      await _until(() => downloader.calls.length == 2);

      expect(downloader.calls.last.uid, 'e1');
      expect(downloader.calls.last.dir.path, first.dir.path);

      downloader.release('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(downloader.uids, <String>['e1', 'e1']);
    });

    test('pausing and resuming before the job stops leaves a single job',
        () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() => downloader.calls.isNotEmpty);

      final Future<void> pausing = cubit.pauseDownload('e1');
      final Future<void> resuming = cubit.resumeDownload('e1');
      await Future.wait(<Future<void>>[pausing, resuming]);
      await _until(() => downloader.calls.length == 2);

      downloader.release('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(downloader.uids, <String>['e1', 'e1']);
    });

    test('pausing a queued job keeps it out of the queue until resumed',
        () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await enqueue('e2');
      await _until(() => downloader.calls.isNotEmpty);

      await cubit.pauseDownload('e2');
      expect(await statusOf('e2'), DownloadStatus.paused);

      downloader.release('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      await _until(() => !runtime.running);

      expect(downloader.uids, <String>['e1']);
      expect(await statusOf('e2'), DownloadStatus.paused);
      expect(notifications.completed, 1);

      await cubit.resumeDownload('e2');
      await _until(() => downloader.calls.length == 2);
      expect(runtime.running, isTrue);

      downloader.release('e2');
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      await _until(() => !runtime.running);
      expect(downloader.uids, <String>['e1', 'e2']);
    });

    test('pausing the only job stops the service and settles the notification',
        () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() => runtime.running);
      final int cancelledBefore = notifications.progressCancelled;

      await cubit.pauseDownload('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.paused);
      await _until(() => !runtime.running);

      expect(runtime.running, isFalse);
      expect(notifications.progressCancelled, greaterThan(cancelledBefore));
      expect(cubit.state.runtimeStatus, DownloadRuntimeStatus.inactive);
    });

    test('pause all and resume all cover in-flight and queued jobs', () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await enqueue('e2');
      await enqueue('e3');
      await _until(() => downloader.calls.isNotEmpty);

      await cubit.pauseAll();
      await _awaitStatus(repository, 'e1', DownloadStatus.paused);
      await _until(() => !runtime.running);

      for (final String uid in <String>['e1', 'e2', 'e3']) {
        expect(await statusOf(uid), DownloadStatus.paused);
      }
      expect(downloader.uids, <String>['e1']);

      await cubit.resumeAll();
      await _until(() => downloader.calls.length == 2);
      downloader.releaseAll(<String>['e1', 'e2', 'e3']);
      await _awaitStatus(repository, 'e3', DownloadStatus.done);

      expect(downloader.uids, <String>['e1', 'e1', 'e2', 'e3']);
    });

    test('pausing and resuming a title only touches that title', () async {
      downloader.holdDownloads = true;
      await enqueue('a1', concreteUid: 'A');
      await enqueue('b1', concreteUid: 'B');
      await enqueue('a2', concreteUid: 'A');
      await _until(() => downloader.calls.isNotEmpty);

      await cubit.pauseTitle('A');
      await _awaitStatus(repository, 'a1', DownloadStatus.paused);
      await _until(() => downloader.calls.length == 2);

      expect(await statusOf('a2'), DownloadStatus.paused);
      expect(downloader.calls.last.uid, 'b1');

      await cubit.resumeTitle('A');
      downloader.releaseAll(<String>['a1', 'b1', 'a2']);
      await _awaitStatus(repository, 'a2', DownloadStatus.done);
      await _awaitStatus(repository, 'a1', DownloadStatus.done);

      expect(downloader.uids, <String>['a1', 'b1', 'a1', 'a2']);
    });

    test('paused rows survive a restart and are not resumed by recovery',
        () async {
      await enqueue('paused', autoStart: false);
      await enqueue('queued', autoStart: false);
      await cubit.pauseDownload('paused');
      await cubit.close();

      cubit = buildCubit()..init();
      await _awaitStatus(repository, 'queued', DownloadStatus.done);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await statusOf('paused'), DownloadStatus.paused);
      expect(downloader.uids, <String>['queued']);

      await cubit.resumeDownload('paused');
      await _awaitStatus(repository, 'paused', DownloadStatus.done);
      expect(downloader.uids, <String>['queued', 'paused']);
    });

    test('Wi-Fi returning does not resume paused rows', () async {
      await cubit.close();
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      );

      await enqueue('e1');
      await enqueue('e2');
      await _until(() => cubit.state.waitingForWifi);
      await cubit.pauseDownload('e1');

      monitor.change(NetworkConnection.wifi);
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(downloader.uids, <String>['e2']);
      expect(await statusOf('e1'), DownloadStatus.paused);
    });

    test('a download resumed while held for Wi-Fi waits for Wi-Fi', () async {
      await cubit.close();
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      );

      await enqueue('e1');
      await _until(() => cubit.state.waitingForWifi);
      await cubit.pauseDownload('e1');
      await _until(() => !runtime.running);

      expect(cubit.state.waitingForWifi, isFalse);

      await cubit.resumeDownload('e1');
      await _until(() => cubit.state.waitingForWifi);
      await _until(() => runtime.running);

      expect(await statusOf('e1'), DownloadStatus.queued);
      expect(downloader.calls, isEmpty);

      monitor.change(NetworkConnection.wifi);
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      expect(downloader.uids, <String>['e1']);
    });

    test('pausing a job held for Wi-Fi keeps it paused when Wi-Fi returns',
        () async {
      await cubit.close();
      cubit = buildCubit(wifiOnly: true);
      downloader.holdDownloads = true;

      await enqueue('e1');
      await _until(() => downloader.calls.isNotEmpty);
      monitor.change(NetworkConnection.cellular);
      await _awaitStatus(repository, 'e1', DownloadStatus.queued);

      await cubit.pauseDownload('e1');
      monitor.change(NetworkConnection.wifi);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(await statusOf('e1'), DownloadStatus.paused);
      expect(downloader.calls, hasLength(1));
      expect(cubit.state.waitingForWifi, isFalse);
    });

    test('deleting a paused download removes its row and partial files',
        () async {
      await enqueue('e1', autoStart: false);
      await cubit.pauseDownload('e1');
      final DownloadDomain row = (await repository.getByUid('e1'))!;
      final Directory dir = Directory(row.dirPath)..createSync(recursive: true);
      File(p.join(dir.path, 'segment.part')).writeAsStringSync('partial');

      await cubit.deleteDownload(row);

      expect(await repository.getByUid('e1'), isNull);
      expect(dir.existsSync(), isFalse);

      await cubit.resumeDownload('e1');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(downloader.calls, isEmpty);
    });

    test('a paused chapter continues from the pages it already saved',
        () async {
      final MangaApiClient client = MangaApiClient(code: _threePageScript);
      await cubit.enqueueChapter(
        client: client,
        extensionUid: 'manga-ext',
        concreteUid: 'manga',
        concreteId: 1,
        concreteTitle: 'Some Manga',
        concreteCover: null,
        chapterUid: 'c1',
        title: 'Chapter 1',
        data: const <String, dynamic>{},
        autoStart: false,
      );
      await cubit.pauseDownload('c1');
      final DownloadDomain paused = (await repository.getByUid('c1'))!;
      expect(paused.status, DownloadStatus.paused);

      final Directory dir = Directory(paused.dirPath)
        ..createSync(recursive: true);
      final File firstPage = File(p.join(dir.path, '0000.img'))
        ..writeAsStringSync('kept-0');
      final File secondPage = File(p.join(dir.path, '0001.img'))
        ..writeAsStringSync('kept-1');
      await repository
          .update(paused.copyWith(downloadedPages: 2, totalPages: 3));

      await cubit.resumeDownload('c1');
      final DownloadDomain? done =
          await _awaitStatus(repository, 'c1', DownloadStatus.done);

      expect(done!.downloadedPages, 3);
      expect(firstPage.readAsStringSync(), 'kept-0');
      expect(secondPage.readAsStringSync(), 'kept-1');
      expect(File(p.join(dir.path, '0002.img')).lengthSync(), greaterThan(0));
    });
  });

  group('queue order', () {
    test('new downloads go to the end of the stored order', () async {
      await enqueue('e1', autoStart: false);
      await enqueue('e2', autoStart: false);
      await enqueue('e3', autoStart: false);

      expect(await storedOrder(), <String>['e1', 'e2', 'e3']);
    });

    test('a reorder is stored and followed by the queue', () async {
      await enqueue('e1', autoStart: false);
      await enqueue('e2', autoStart: false);
      await enqueue('e3', autoStart: false);

      await cubit.reorderQueue(<String>['e3', 'e1', 'e2']);
      expect(await storedOrder(), <String>['e3', 'e1', 'e2']);

      cubit.startQueue();
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      expect(downloader.uids, <String>['e3', 'e1', 'e2']);
    });

    test('recovery after a restart follows the stored order', () async {
      await enqueue('e1', autoStart: false);
      await enqueue('e2', autoStart: false);
      await enqueue('e3', autoStart: false);
      await cubit.reorderQueue(<String>['e2', 'e3', 'e1']);
      await cubit.close();

      cubit = buildCubit()..init();
      await _awaitStatus(repository, 'e1', DownloadStatus.done);

      expect(downloader.uids, <String>['e2', 'e3', 'e1']);
    });

    test('download next goes after the in-flight job without interrupting it',
        () async {
      downloader.holdDownloads = true;
      for (final String uid in <String>['e1', 'e2', 'e3', 'e4']) {
        await enqueue(uid);
      }
      await _until(() => downloader.calls.isNotEmpty);

      await cubit.downloadNext('e4');

      expect(downloader.calls.single.cancelToken.isCancelled, isFalse);
      expect(await storedOrder(), <String>['e1', 'e4', 'e2', 'e3']);

      downloader.releaseAll(<String>['e1', 'e2', 'e3', 'e4']);
      await _awaitStatus(repository, 'e3', DownloadStatus.done);
      expect(downloader.uids, <String>['e1', 'e4', 'e2', 'e3']);
    });

    test('download next resumes a paused download', () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await enqueue('e2');
      await enqueue('e3');
      await _until(() => downloader.calls.isNotEmpty);
      await cubit.pauseDownload('e3');

      await cubit.downloadNext('e3');

      expect(await statusOf('e3'), DownloadStatus.queued);
      downloader.releaseAll(<String>['e1', 'e2', 'e3']);
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      expect(downloader.uids, <String>['e1', 'e3', 'e2']);
    });

    test('move title to top keeps the relative order of that title', () async {
      downloader.holdDownloads = true;
      await enqueue('a1', concreteUid: 'A');
      await enqueue('a2', concreteUid: 'A');
      await enqueue('b1', concreteUid: 'B');
      await enqueue('a3', concreteUid: 'A');
      await enqueue('b2', concreteUid: 'B');
      await _until(() => downloader.calls.isNotEmpty);

      await cubit.moveTitleToTop('B');

      expect(downloader.calls.single.cancelToken.isCancelled, isFalse);
      expect(
        await storedOrder(),
        <String>['a1', 'b1', 'b2', 'a2', 'a3'],
      );

      downloader.releaseAll(<String>['a1', 'a2', 'a3', 'b1', 'b2']);
      await _awaitStatus(repository, 'a3', DownloadStatus.done);
      expect(downloader.uids, <String>['a1', 'b1', 'b2', 'a2', 'a3']);
    });

    test('the state lists the in-flight download first, then stored order',
        () async {
      downloader.holdDownloads = true;
      cubit.init();
      await enqueue('e1');
      await enqueue('e2');
      await enqueue('e3');
      await _until(() => downloader.calls.isNotEmpty);
      await cubit.pauseDownload('e2');
      await cubit.reorderQueue(<String>['e3', 'e2']);
      await _until(() =>
          cubit.state.queue.map((DownloadDomain d) => d.uid).join(',') ==
          'e1,e3,e2');

      final List<DownloadDomain> queue = cubit.state.queue;
      expect(queue.first.status, DownloadStatus.downloading);
      expect(queue.last.status, DownloadStatus.paused);
      expect(cubit.state.canPauseAny, isTrue);
      expect(cubit.state.canResumeAny, isTrue);
    });
  });
}

Future<void> _until(FutureOr<bool> Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!await condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<DownloadDomain?> _awaitStatus(
  DownloadRepository repository,
  String uid,
  DownloadStatus status,
) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final DownloadDomain? row = await repository.getByUid(uid);
    if (row != null && row.status == status) {
      return row;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return repository.getByUid(uid);
}
