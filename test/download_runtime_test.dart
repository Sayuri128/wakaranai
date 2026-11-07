import 'dart:async';
import 'dart:io';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
  DownloadRuntimeStart startOutcome = DownloadRuntimeStart.started;
  final List<String> calls = <String>[];
  final StreamController<DownloadRuntimeEvent> _events =
      StreamController<DownloadRuntimeEvent>.broadcast();
  bool disposed = false;

  bool get running {
    final int lastStart = calls.lastIndexOf('start');
    final int lastStop = calls.lastIndexOf('stop');
    return lastStart > lastStop;
  }

  int count(String call) => calls.where((String c) => c == call).length;

  void emit(DownloadRuntimeEvent event) => _events.add(event);

  @override
  Stream<DownloadRuntimeEvent> get events => _events.stream;

  @override
  Future<DownloadRuntimeStart> start() async {
    calls.add('start');
    return startOutcome;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  @override
  Future<void> dispose() async {
    disposed = true;
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
  _Call(this.uid, this.cancelToken);

  final String uid;
  final CancelToken cancelToken;
}

class _ControlledDownloader extends EpisodeDownloader {
  final List<_Call> calls = <_Call>[];
  final Map<String, Completer<void>> _releases = <String, Completer<void>>{};
  bool holdDownloads = false;

  void release(String uid) {
    _releases.putIfAbsent(uid, Completer<void>.new);
    if (!_releases[uid]!.isCompleted) {
      _releases[uid]!.complete();
    }
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
    calls.add(_Call(uid, cancelToken));
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

  group('DownloadNetworkPolicy', () {
    test('allows any network until Wi-Fi only is enabled', () async {
      final _FakeNetworkMonitor monitor =
          _FakeNetworkMonitor(NetworkConnection.cellular);
      final DownloadNetworkPolicy policy = DownloadNetworkPolicy(
        monitor: monitor,
        readWifiOnly: () async => false,
      );
      await policy.start();

      expect(policy.allowsDownloads, isTrue);

      final List<bool> changes = <bool>[];
      final StreamSubscription<bool> sub = policy.changes.listen(changes.add);
      policy.setWifiOnly(true);
      monitor.change(NetworkConnection.offline);
      monitor.change(NetworkConnection.wifi);
      await Future<void>.delayed(Duration.zero);

      expect(changes, <bool>[false, true]);
      await sub.cancel();
      await policy.dispose();
    });

    test('reads the stored setting and the current connection', () async {
      final DownloadNetworkPolicy policy = DownloadNetworkPolicy(
        monitor: _FakeNetworkMonitor(NetworkConnection.cellular),
        readWifiOnly: () async => true,
      );
      await policy.start();

      expect(policy.wifiOnly, isTrue);
      expect(policy.connection, NetworkConnection.cellular);
      expect(policy.allowsDownloads, isFalse);
      await policy.dispose();
    });

    test('a toggle made before the setting loads is kept', () async {
      final Completer<bool> stored = Completer<bool>();
      final DownloadNetworkPolicy policy = DownloadNetworkPolicy(
        monitor: _FakeNetworkMonitor(NetworkConnection.cellular),
        readWifiOnly: () => stored.future,
      );
      final Future<void> starting = policy.start();
      policy.setWifiOnly(false);
      stored.complete(true);
      await starting;

      expect(policy.wifiOnly, isFalse);
      expect(policy.allowsDownloads, isTrue);
      await policy.dispose();
    });

    test('an unreadable setting falls back to any network', () async {
      final DownloadNetworkPolicy policy = DownloadNetworkPolicy(
        monitor: _FakeNetworkMonitor(NetworkConnection.cellular),
        readWifiOnly: () async => throw StateError('no prefs'),
      );
      await policy.start();

      expect(policy.wifiOnly, isFalse);
      await policy.dispose();
    });

    test('platform network states are parsed', () {
      expect(parseNetworkConnection('wifi'), NetworkConnection.wifi);
      expect(parseNetworkConnection('cellular'), NetworkConnection.cellular);
      expect(parseNetworkConnection('offline'), NetworkConnection.offline);
      expect(parseNetworkConnection(null), NetworkConnection.other);
    });
  });

  group('DownloadManagerCubit runtime', () {
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

    Future<void> enqueue(String uid) {
      return cubit.enqueueEpisode(
        extensionUid: 'anime-ext',
        concreteUid: 'concrete',
        concreteId: 1,
        concreteTitle: 'Some Anime',
        concreteCover: null,
        episode: _episode(uid),
      );
    }

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('wakaranai_runtime');
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

    test('the service runs while the queue is active and stops when idle',
        () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await enqueue('e2');
      await _until(() => downloader.calls.isNotEmpty);
      await _until(() => runtime.running);

      expect(runtime.running, isTrue);
      expect(cubit.state.runtimeStatus, DownloadRuntimeStatus.active);

      downloader.release('e1');
      downloader.release('e2');
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      await _until(() => !runtime.running);

      expect(runtime.calls, <String>['start', 'stop']);
      expect(cubit.state.runtimeStatus, DownloadRuntimeStatus.inactive);
    });

    test('closing the cubit stops a running service', () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() => runtime.running);

      await cubit.close();

      expect(runtime.running, isFalse);
      expect(runtime.disposed, isTrue);
    });

    test('downloads continue when the service may not start', () async {
      runtime.startOutcome = DownloadRuntimeStart.notAllowed;
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() =>
          cubit.state.runtimeStatus == DownloadRuntimeStatus.startNotAllowed);

      expect(cubit.state.runsOnlyWhileAppOpen, isTrue);

      downloader.release('e1');
      final DownloadDomain? done =
          await _awaitStatus(repository, 'e1', DownloadStatus.done);
      expect(done!.status, DownloadStatus.done);
      await _until(() =>
          cubit.state.runtimeStatus == DownloadRuntimeStatus.inactive);
      expect(runtime.count('stop'), 0);
    });

    test('a timed out service is reported and downloads continue', () async {
      downloader.holdDownloads = true;
      await enqueue('e1');
      await _until(() => runtime.running);

      runtime.emit(DownloadRuntimeEvent.timedOut);
      await _until(
          () => cubit.state.runtimeStatus == DownloadRuntimeStatus.timedOut);

      downloader.release('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      expect(runtime.count('stop'), 0);
    });

    test('queued jobs wait for Wi-Fi and start when it returns', () async {
      await cubit.close();
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      );

      await enqueue('e1');
      await _until(() => cubit.state.waitingForWifi);

      await _until(() => notifications.waitingShown > 0);

      expect(cubit.state.waitingForWifi, isTrue);
      expect(downloader.calls, isEmpty);
      expect(runtime.running, isTrue);
      expect((await repository.getByUid('e1'))!.status, DownloadStatus.queued);

      monitor.change(NetworkConnection.wifi);
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      await _until(() => !runtime.running);

      expect(cubit.state.waitingForWifi, isFalse);
      expect(downloader.calls, hasLength(1));
      expect(runtime.calls, <String>['start', 'stop']);
    });

    test('losing Wi-Fi pauses the active job and regaining it resumes',
        () async {
      await cubit.close();
      cubit = buildCubit(wifiOnly: true);
      downloader.holdDownloads = true;

      await enqueue('e1');
      await enqueue('e2');
      await _until(() => downloader.calls.isNotEmpty);
      final _Call first = downloader.calls.single;

      monitor.change(NetworkConnection.cellular);
      await _awaitStatus(repository, 'e1', DownloadStatus.queued);
      await _until(() => notifications.waitingShown > 0);

      expect(first.cancelToken.isCancelled, isTrue);
      expect(cubit.state.waitingForWifi, isTrue);
      expect(runtime.running, isTrue,
          reason: 'a held queue keeps the service so it can resume in the '
              'background');
      expect(downloader.calls, hasLength(1));
      expect((await repository.getByUid('e2'))!.status, DownloadStatus.queued);

      monitor.change(NetworkConnection.wifi);
      await _until(() => downloader.calls.length == 2);

      expect(downloader.calls.last.uid, 'e1');
      expect(downloader.calls.last.cancelToken.isCancelled, isFalse);
      expect(cubit.state.waitingForWifi, isFalse);

      downloader.release('e1');
      downloader.release('e2');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      await _awaitStatus(repository, 'e2', DownloadStatus.done);
      await _until(() => !runtime.running);

      expect(runtime.calls, <String>['start', 'stop']);
    });

    test('turning Wi-Fi only on and off on cellular pauses and resumes',
        () async {
      await cubit.close();
      cubit = buildCubit(connection: NetworkConnection.cellular);
      downloader.holdDownloads = true;

      await enqueue('e1');
      await _until(() => downloader.calls.isNotEmpty);

      cubit.setWifiOnly(true);
      await _awaitStatus(repository, 'e1', DownloadStatus.queued);
      await _until(() => cubit.state.waitingForWifi);
      expect(downloader.calls.single.cancelToken.isCancelled, isTrue);

      cubit.setWifiOnly(false);
      await _until(() => downloader.calls.length == 2);
      expect(cubit.state.waitingForWifi, isFalse);

      downloader.release('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
    });

    test('deleting the last waiting job clears the Wi-Fi hold', () async {
      await cubit.close();
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.offline,
      );

      await enqueue('e1');
      await _until(() => cubit.state.waitingForWifi);

      await cubit.deleteDownload((await repository.getByUid('e1'))!);

      expect(cubit.state.waitingForWifi, isFalse);
      expect(await repository.getByUid('e1'), isNull);

      monitor.change(NetworkConnection.wifi);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(downloader.calls, isEmpty);
    });

    test('deleting the last held job stops the service and its notification',
        () async {
      await cubit.close();
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      );

      await enqueue('e1');
      await _until(() => notifications.waitingShown > 0);
      expect(runtime.running, isTrue);
      final int cancelledBefore = notifications.progressCancelled;

      await cubit.deleteDownload((await repository.getByUid('e1'))!);

      expect(runtime.running, isFalse);
      expect(notifications.progressCancelled, greaterThan(cancelledBefore));
      expect(cubit.state.runtimeStatus, DownloadRuntimeStatus.inactive);
    });

    test('a failed batch that the service could not run clears the progress',
        () async {
      runtime.startOutcome = DownloadRuntimeStart.notAllowed;
      await enqueue('missing');
      await repository.deleteByUid('missing');
      await _until(() => notifications.progressCancelled > 0);

      expect(notifications.completed, -1);
      expect(notifications.progressCancelled, greaterThan(0));
    });

    test('queued rows resume after a restart and downloading rows fail',
        () async {
      await enqueue('queued');
      await enqueue('active');
      await _awaitStatus(repository, 'active', DownloadStatus.done);
      final DownloadDomain queuedRow = (await repository.getByUid('queued'))!;
      final DownloadDomain activeRow = (await repository.getByUid('active'))!;
      await repository
          .update(queuedRow.copyWith(status: DownloadStatus.queued));
      await repository
          .update(activeRow.copyWith(status: DownloadStatus.downloading));
      await cubit.close();
      downloader.calls.clear();

      cubit = buildCubit()..init();

      await _awaitStatus(repository, 'queued', DownloadStatus.done);
      final DownloadDomain? interrupted =
          await _awaitStatus(repository, 'active', DownloadStatus.failed);

      expect(interrupted!.status, DownloadStatus.failed);
      expect(downloader.calls.map((_Call call) => call.uid), <String>['queued']);
    });

    test('queued rows recovered while off Wi-Fi stay queued and wait',
        () async {
      await enqueue('e1');
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      final DownloadDomain row = (await repository.getByUid('e1'))!;
      await repository.update(row.copyWith(status: DownloadStatus.queued));
      await cubit.close();
      downloader.calls.clear();

      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      )..init();
      await _until(() => cubit.state.waitingForWifi);

      expect((await repository.getByUid('e1'))!.status, DownloadStatus.queued);
      expect(downloader.calls, isEmpty);

      monitor.change(NetworkConnection.wifi);
      await _awaitStatus(repository, 'e1', DownloadStatus.done);
      expect(downloader.calls, hasLength(1));
    });

    test('deleting a job paused for Wi-Fi does not requeue it', () async {
      await cubit.close();
      cubit = buildCubit(wifiOnly: true);
      downloader.holdDownloads = true;

      await enqueue('e1');
      await _until(() => downloader.calls.isNotEmpty);
      final DownloadDomain row = (await repository.getByUid('e1'))!;

      monitor.change(NetworkConnection.cellular);
      await cubit.deleteDownload(row);
      monitor.change(NetworkConnection.wifi);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await repository.getByUid('e1'), isNull);
      expect(downloader.calls, hasLength(1));
      expect(cubit.state.waitingForWifi, isFalse);
    });
  });
}

Future<void> _until(bool Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition() && DateTime.now().isBefore(deadline)) {
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
