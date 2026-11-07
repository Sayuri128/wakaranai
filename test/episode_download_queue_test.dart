import 'dart:async';
import 'dart:io';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
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
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';

const QualityPreference _preferredQuality =
    QualityPreference(streamLabel: '720p');

const EpisodeDownloadManifest _hlsManifest = EpisodeDownloadManifest(
  format: EpisodeMediaFormat.hls,
  file: 'index.m3u8',
  quality: '720p',
);

AnimeVideo _episode(
  String uid, {
  AnimeVideoType type = AnimeVideoType.IFRAME,
  String src = 'https://player.test/embed',
}) {
  return AnimeVideo(
    type: type,
    uid: uid,
    src: src,
    title: 'Episode $uid',
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
  );
}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.docs);

  final String docs;

  @override
  Future<String?> getApplicationDocumentsPath() async => docs;
}

class _RecordingNotifications extends DownloadNotificationService {
  final List<(int, int)> progress = <(int, int)>[];
  int completed = -1;

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
  }) async {
    this.progress.add((progress, max));
  }

  @override
  Future<void> showComplete(int count) async {
    completed = count;
  }

  @override
  Future<void> cancelProgress() async {}
}

class _FakeSourceResolver implements EpisodeSourceResolver {
  _FakeSourceResolver({this.failure});

  final Object? failure;
  int calls = 0;

  @override
  Future<PlayableVideo> resolve({
    required String extensionUid,
    required AnimeVideo episode,
  }) async {
    calls++;
    final Object? error = failure;
    if (error != null) {
      throw error;
    }
    return PlayableVideo(
      streams: <PlayableStream>[
        PlayableStream(url: 'https://cdn.test/${episode.uid}/$calls.m3u8'),
      ],
    );
  }
}

class _DownloadCall {
  _DownloadCall({
    required this.video,
    required this.quality,
    required this.dir,
    required this.throttleKey,
    required this.cancelToken,
    required this.onProgress,
  });

  final PlayableVideo video;
  final QualityPreference quality;
  final Directory dir;
  final String throttleKey;
  final CancelToken cancelToken;
  final EpisodeProgressCallback? onProgress;

  void report({
    int completedSegments = 0,
    int totalSegments = 0,
    int downloadedBytes = 0,
    int totalBytes = 0,
  }) {
    onProgress?.call(EpisodeDownloadProgress(
      completedSegments: completedSegments,
      totalSegments: totalSegments,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
    ));
  }

  Future<File> writePartial(String name) async {
    await dir.create(recursive: true);
    final File file = File(p.join(dir.path, name));
    await file.writeAsString('partial');
    return file;
  }
}

typedef _DownloadBehavior = Future<EpisodeDownloadManifest> Function(
  _DownloadCall call,
);

class _ScriptedDownloader extends EpisodeDownloader {
  _ScriptedDownloader(this.behaviors);

  final List<_DownloadBehavior> behaviors;
  final List<_DownloadCall> calls = <_DownloadCall>[];

  @override
  Future<EpisodeDownloadManifest> download({
    required PlayableVideo video,
    required QualityPreference quality,
    required Directory dir,
    required String throttleKey,
    required CancelToken cancelToken,
    EpisodeProgressCallback? onProgress,
  }) {
    final _DownloadCall call = _DownloadCall(
      video: video,
      quality: quality,
      dir: dir,
      throttleKey: throttleKey,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );
    calls.add(call);
    final int index = calls.length - 1;
    final _DownloadBehavior behavior =
        index < behaviors.length ? behaviors[index] : behaviors.last;
    return behavior(call);
  }
}

class _FakeVideoSourceProvider implements VideoSourceProvider {
  _FakeVideoSourceProvider({
    this.supported = true,
    this.sources = const <AnimeVideoSource>[],
  });

  final bool supported;
  final List<AnimeVideoSource> sources;

  @override
  Future<bool> supportsVideoSources() async => supported;

  @override
  Future<List<AnimeVideoSource>> getVideoSources(AnimeVideo video) async {
    return sources;
  }
}

Future<EpisodeDownloadManifest> _succeeds(_DownloadCall call) async {
  return _hlsManifest;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late WakaranaiDatabase db;
  late DownloadRepository repository;
  late _RecordingNotifications notifications;
  late _FakeSourceResolver resolver;
  late _ScriptedDownloader downloader;
  late DownloadManagerCubit cubit;

  DownloadManagerCubit buildCubit({
    Object? resolverFailure,
    required List<_DownloadBehavior> behaviors,
  }) {
    resolver = _FakeSourceResolver(failure: resolverFailure);
    downloader = _ScriptedDownloader(behaviors);
    return DownloadManagerCubit(
      downloadRepository: repository,
      notificationService: notifications,
      episodeSourceResolver: resolver,
      episodeDownloader: downloader,
      readQualityPreference: () async => _preferredQuality,
    );
  }

  Future<void> enqueue(String uid, {bool autoStart = true}) {
    return cubit.enqueueEpisode(
      extensionUid: 'anime-ext',
      concreteUid: 'concrete',
      concreteId: 1,
      concreteTitle: 'Some Anime',
      concreteCover: null,
      episode: _episode(uid),
      autoStart: autoStart,
    );
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wakaranai_episodes');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    repository = DownloadRepository(database: db);
    notifications = _RecordingNotifications();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[_succeeds]);
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      return;
    }
  });

  test('sources are resolved when the job starts and the manifest is stored',
      () async {
    await enqueue('e1', autoStart: false);

    final DownloadDomain? queued = await repository.getByUid('e1');
    expect(queued!.status, DownloadStatus.queued);
    expect(queued.kind, DownloadKind.episode);
    expect(downloadedEpisodeOf(queued)!.uid, 'e1');
    expect(resolver.calls, 0);

    cubit.startQueue();
    final DownloadDomain? done =
        await _awaitStatus(repository, 'e1', DownloadStatus.done);

    expect(resolver.calls, 1);
    expect(downloader.calls.single.video.streams.single.url,
        'https://cdn.test/e1/1.m3u8');
    expect(downloader.calls.single.dir.path, queued.dirPath);
    expect(downloader.calls.single.quality, _preferredQuality);
    expect(downloader.calls.single.throttleKey, 'anime-ext');
    expect(EpisodeDownloadManifest.decode(done!.playback)!.file, 'index.m3u8');
    expect(notifications.completed, 1);
  });

  test('a finished episode is reported as downloaded by its uid', () async {
    cubit.init();
    await enqueue('e1');
    await _awaitStatus(repository, 'e1', DownloadStatus.done);

    await _until(() => cubit.isDownloaded('e1'));

    expect(cubit.isDownloaded('e1'), isTrue);
    expect(cubit.state.forChapter('e1')!.isEpisode, isTrue);
  });

  test('segment progress is persisted while an episode downloads', () async {
    final Completer<void> release = Completer<void>();
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        call.report(
          completedSegments: 3,
          totalSegments: 10,
          downloadedBytes: 300,
        );
        await release.future;
        call.report(
          completedSegments: 10,
          totalSegments: 10,
          downloadedBytes: 1000,
        );
        return _hlsManifest;
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? partial = await _awaitRow(
      repository,
      'e1',
      (DownloadDomain row) => row.downloadedPages == 3,
    );

    expect(partial!.status, DownloadStatus.downloading);
    expect(partial.totalPages, 10);
    expect(partial.downloadedBytes, 300);
    expect(partial.progress, closeTo(0.3, 0.001));
    expect(notifications.progress, contains((3, 10)));

    release.complete();
    final DownloadDomain? done =
        await _awaitStatus(repository, 'e1', DownloadStatus.done);
    expect(done!.downloadedPages, 10);
    expect(done.progress, 1.0);
  });

  test('byte progress is persisted and notified as a percentage', () async {
    final Completer<void> release = Completer<void>();
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        call.report(downloadedBytes: 250, totalBytes: 1000);
        await release.future;
        return _hlsManifest;
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? partial = await _awaitRow(
      repository,
      'e1',
      (DownloadDomain row) => row.downloadedBytes == 250,
    );

    expect(partial!.totalBytes, 1000);
    expect(partial.totalPages, 0);
    expect(partial.progress, closeTo(0.25, 0.001));
    expect(notifications.progress, contains((25, 100)));

    release.complete();
    await _awaitStatus(repository, 'e1', DownloadStatus.done);
  });

  test('expired sources are resolved again and the download resumes',
      () async {
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        await call.writePartial('seg0.ts');
        throw const EpisodeSourceExpired(
          url: 'https://cdn.test',
          statusCode: 403,
        );
      },
      (_DownloadCall call) async {
        expect(File(p.join(call.dir.path, 'seg0.ts')).existsSync(), isTrue);
        return _hlsManifest;
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? done =
        await _awaitStatus(repository, 'e1', DownloadStatus.done);

    expect(done!.status, DownloadStatus.done);
    expect(resolver.calls, 2);
    expect(downloader.calls, hasLength(2));
    expect(downloader.calls.last.video.streams.single.url,
        'https://cdn.test/e1/2.m3u8');
    expect(downloader.calls.last.dir.path, downloader.calls.first.dir.path);
  });

  test('sources that keep expiring fail after two refreshes', () async {
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        throw const EpisodeSourceExpired(
          url: 'https://cdn.test',
          statusCode: 410,
        );
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? failed =
        await _awaitStatus(repository, 'e1', DownloadStatus.failed);

    expect(failed!.status, DownloadStatus.failed);
    expect(resolver.calls, 3);
    expect(downloader.calls, hasLength(3));
    expect(notifications.completed, -1);
  });

  test('an unsupported episode fails and keeps its partial files', () async {
    late File partialFile;
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        partialFile = await call.writePartial('audio.part');
        throw const UnsupportedEpisodeDownload('DASH');
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? failed =
        await _awaitStatus(repository, 'e1', DownloadStatus.failed);

    expect(failed!.playback, isNull);
    expect(partialFile.existsSync(), isTrue);
  });

  test('sources that cannot be resolved fail without downloading', () async {
    await cubit.close();
    cubit = buildCubit(
      resolverFailure: const EpisodeSourcesUnavailable('e1'),
      behaviors: <_DownloadBehavior>[_succeeds],
    );

    await enqueue('e1');
    await _awaitStatus(repository, 'e1', DownloadStatus.failed);

    expect(resolver.calls, 1);
    expect(downloader.calls, isEmpty);
  });

  test('retrying a failed episode resolves again in the same directory',
      () async {
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        await call.writePartial('seg0.ts');
        call.report(completedSegments: 1, totalSegments: 4);
        throw const EpisodeDownloadFailure(url: 'https://cdn.test/seg1.ts');
      },
      (_DownloadCall call) async {
        expect(File(p.join(call.dir.path, 'seg0.ts')).existsSync(), isTrue);
        return _hlsManifest;
      },
    ]);

    await enqueue('e1');
    final DownloadDomain? failed =
        await _awaitStatus(repository, 'e1', DownloadStatus.failed);
    expect(failed!.downloadedPages, 1);
    expect(resolver.calls, 1);

    await cubit.retryDownload(failed);
    final DownloadDomain? done =
        await _awaitStatus(repository, 'e1', DownloadStatus.done);

    expect(resolver.calls, 2);
    expect(done!.dirPath, failed.dirPath);
    expect(downloader.calls.last.dir.path, failed.dirPath);
    expect(File(p.join(failed.dirPath, 'seg0.ts')).existsSync(), isTrue);
  });

  test('deleting a downloading episode cancels it and removes its files',
      () async {
    final Completer<void> finished = Completer<void>();
    final Completer<void> started = Completer<void>();
    await cubit.close();
    cubit = buildCubit(behaviors: <_DownloadBehavior>[
      (_DownloadCall call) async {
        try {
          await call.writePartial('seg0.ts');
          started.complete();
          throw await call.cancelToken.whenCancel;
        } finally {
          finished.complete();
        }
      },
    ]);

    await enqueue('e1');
    await started.future;
    final DownloadDomain row = (await repository.getByUid('e1'))!;

    await cubit.deleteDownload(row);
    await finished.future.timeout(const Duration(seconds: 5));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(downloader.calls.single.cancelToken.isCancelled, isTrue);
    expect(await repository.getByUid('e1'), isNull);
    expect(Directory(row.dirPath).existsSync(), isFalse);
    expect(notifications.completed, -1);
  });

  test('retrying an episode without its payload leaves it failed', () async {
    await _insertFailedRow(repository, kind: DownloadKind.episode);

    final DownloadDomain row = (await repository.getByUid('broken'))!;
    await cubit.retryDownload(row);

    expect((await repository.getByUid('broken'))!.status,
        DownloadStatus.failed);
    expect(resolver.calls, 0);
  });

  test('retrying a chapter of a missing extension leaves it failed', () async {
    await _insertFailedRow(repository, kind: DownloadKind.chapter);

    final DownloadDomain row = (await repository.getByUid('broken'))!;
    await cubit.retryDownload(row);

    expect((await repository.getByUid('broken'))!.status,
        DownloadStatus.failed);
  });

  group('resolveDownloadableEpisode', () {
    test('maps the extension sources', () async {
      final PlayableVideo video = await resolveDownloadableEpisode(
        episode: _episode('e1'),
        provider: _FakeVideoSourceProvider(sources: const <AnimeVideoSource>[
          AnimeVideoSource(
            url: 'https://cdn.test/master.m3u8',
            quality: '1080p',
          ),
        ]),
      );

      expect(video.streams.single.url, 'https://cdn.test/master.m3u8');
    });

    test('falls back to a direct source when no stream is returned', () async {
      final PlayableVideo video = await resolveDownloadableEpisode(
        episode: _episode(
          'e1',
          type: AnimeVideoType.DIRECT,
          src: 'https://cdn.test/episode.mp4',
        ),
        provider: _FakeVideoSourceProvider(),
      );

      expect(video.streams.single.url, 'https://cdn.test/episode.mp4');
    });

    test('falls back to a direct source when sources are unsupported',
        () async {
      final PlayableVideo video = await resolveDownloadableEpisode(
        episode: _episode(
          'e1',
          type: AnimeVideoType.DIRECT,
          src: 'https://cdn.test/episode.mp4',
        ),
        provider: _FakeVideoSourceProvider(supported: false),
      );

      expect(video.streams.single.url, 'https://cdn.test/episode.mp4');
    });

    test('fails for an iframe episode without sources', () async {
      await expectLater(
        resolveDownloadableEpisode(
          episode: _episode('e1'),
          provider: _FakeVideoSourceProvider(),
        ),
        throwsA(isA<EpisodeSourcesUnavailable>()),
      );
    });
  });
}

Future<void> _insertFailedRow(
  DownloadRepository repository, {
  required DownloadKind kind,
}) async {
  await repository.create(DownloadDomain(
    id: 0,
    uid: 'broken',
    extensionUid: 'missing-ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Broken',
    title: 'Broken',
    status: DownloadStatus.failed,
    downloadedPages: 0,
    totalPages: 0,
    dirPath: '',
    kind: kind,
    createdAt: DateTime.now(),
  ));
}

Future<void> _until(bool Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 15));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<DownloadDomain?> _awaitRow(
  DownloadRepository repository,
  String uid,
  bool Function(DownloadDomain row) matches,
) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    final DownloadDomain? row = await repository.getByUid(uid);
    if (row != null && matches(row)) {
      return row;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return repository.getByUid(uid);
}

Future<DownloadDomain?> _awaitStatus(
  DownloadRepository repository,
  String uid,
  DownloadStatus status,
) {
  return _awaitRow(
    repository,
    uid,
    (DownloadDomain row) => row.status == status,
  );
}
