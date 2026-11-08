import 'dart:async';
import 'dart:io';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/data/entities/library_entry_table.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/auto_download/auto_download_policy.dart';
import 'package:wakaranai/services/downloads/auto_download/auto_download_queuer.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_source_resolver.dart';
import 'package:wakaranai/services/downloads/runtime/download_network_policy.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';
import 'package:wakaranai/services/downloads/runtime/network_monitor.dart';
import 'package:wakaranai/services/library_updates/library_update_notification_service.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';

const String _mangaExtensionUid = 'manga.ext';
const String _animeExtensionUid = 'anime.ext';

ExtensionDomain _extension(String uid, ConfigInfoType type) {
  return ExtensionDomain(
    id: 0,
    config: ConfigInfo(
      name: uid,
      uid: uid,
      logoUrl: '',
      nsfw: false,
      language: 'en',
      version: 1,
      filters: const <GalleryFilter>[],
      type: type,
      searchAvailable: true,
    ),
    sourceCode: 'noop',
    createdAt: DateTime.now(),
  );
}

LibraryEntryDomain _entry(
  String uid, {
  String extensionUid = _mangaExtensionUid,
  int? categoryId,
  AutoDownloadOverride autoDownload = AutoDownloadOverride.followSettings,
}) {
  return LibraryEntryDomain(
    id: 0,
    uid: uid,
    extensionUid: extensionUid,
    title: 'Title $uid',
    data: '{}',
    categoryId: categoryId,
    autoDownload: autoDownload,
    createdAt: DateTime.now(),
  );
}

Chapter _chapter(String uid) {
  return Chapter(
    uid: uid,
    title: 'Chapter $uid',
    data: <String, dynamic>{'n': uid},
  );
}

MangaConcreteView _mangaView(String uid, List<String> chapterUids) {
  return MangaConcreteView(
    uid: uid,
    cover: 'cover.png',
    title: 'Title $uid',
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: MangaStatus.UNDEFINED,
    groups: <ChaptersGroup>[
      ChaptersGroup(
        title: 'Main',
        elements: chapterUids.map(_chapter).toList(),
      ),
    ],
  );
}

AnimeVideo _episode(int number) {
  return AnimeVideo(
    type: AnimeVideoType.DIRECT,
    uid: 'ep$number',
    src: 'https://cdn.test/ep$number.mp4',
    title: 'Episode $number',
    timestamp: null,
    data: <String, dynamic>{'n': number},
    number: number.toDouble(),
  );
}

AnimeConcreteView _animeView(String uid, List<int> episodeNumbers) {
  return AnimeConcreteView(
    uid: uid,
    cover: 'cover.png',
    title: 'Title $uid',
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: AnimeStatus.ONGOING,
    groups: <AnimeVideoGroup>[
      AnimeVideoGroup(
        title: 'Sub',
        elements: episodeNumbers.map(_episode).toList(),
      ),
    ],
  );
}

List<String> _uids(int from, int to) {
  return <String>[for (int i = from; i <= to; i++) 'c$i'];
}

Future<Directory> _fakeDir(
  String extensionUid,
  String concreteUid,
  String itemUid,
) async {
  return Directory('/downloads/$extensionUid/$concreteUid/$itemUid');
}

class _Harness {
  _Harness(this.database)
      : entries = LibraryEntryRepository(database: database),
        updates = LibraryUpdateRepository(database: database),
        concretes = ConcreteDataRepository(database: database),
        extensions = ExtensionRepository(database: database),
        downloads = DownloadRepository(database: database);

  final WakaranaiDatabase database;
  final LibraryEntryRepository entries;
  final LibraryUpdateRepository updates;
  final ConcreteDataRepository concretes;
  final ExtensionRepository extensions;
  final DownloadRepository downloads;

  Future<LibraryUpdateCheckResult> check(
    Map<String, ConcreteView> views, {
    AutoDownloadSettings? settings,
  }) {
    return LibraryUpdateService(
      libraryEntryRepository: entries,
      libraryUpdateRepository: updates,
      concreteDataRepository: concretes,
      extensionRepository: extensions,
      fetcher: (ExtensionDomain _, LibraryEntryDomain entry) async =>
          views[entry.uid]!,
      autoDownloads: settings == null
          ? null
          : AutoDownloadQueuer(
              downloadRepository: downloads,
              settings: settings,
              resolveDir: _fakeDir,
            ),
    ).check();
  }

  Future<List<String>> pendingUids() async {
    return (await downloads.getPendingInQueueOrder())
        .map((DownloadDomain row) => row.uid)
        .toList();
  }
}

class _SilentNotifications extends DownloadNotificationService {
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
  Future<void> showComplete(int count) async {}

  @override
  Future<void> showWaitingForWifi() async {}

  @override
  Future<void> cancelProgress() async {}
}

class _IdleRuntime implements DownloadRuntime {
  @override
  Stream<DownloadRuntimeEvent> get events =>
      const Stream<DownloadRuntimeEvent>.empty();

  @override
  Future<DownloadRuntimeStart> start() async => DownloadRuntimeStart.started;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _FixedNetwork implements NetworkMonitor {
  _FixedNetwork(this.connection);

  final NetworkConnection connection;

  @override
  Future<NetworkConnection> current() async => connection;

  @override
  Stream<NetworkConnection> get changes =>
      const Stream<NetworkConnection>.empty();
}

class _DirectSources implements EpisodeSourceResolver {
  @override
  Future<PlayableVideo> resolve({
    required String extensionUid,
    required AnimeVideo episode,
  }) async {
    return PlayableVideo(
      streams: <PlayableStream>[PlayableStream(url: episode.src)],
    );
  }
}

class _RecordingDownloader extends EpisodeDownloader {
  final List<String> urls = <String>[];

  @override
  Future<EpisodeDownloadManifest> download({
    required PlayableVideo video,
    required QualityPreference quality,
    required Directory dir,
    required String throttleKey,
    required CancelToken cancelToken,
    EpisodeProgressCallback? onProgress,
  }) async {
    urls.add(video.streams.single.url);
    return const EpisodeDownloadManifest(
      format: EpisodeMediaFormat.mp4,
      file: 'video.mp4',
      quality: '720p',
    );
  }
}

Future<void> _until(FutureOr<bool> Function() condition) async {
  for (int attempt = 0; attempt < 200; attempt++) {
    if (await condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition was not met in time');
}

void main() {
  group('AutoDownloadPolicy.appliesTo', () {
    const AutoDownloadSettings allTitles = AutoDownloadSettings(enabled: true);
    const AutoDownloadSettings categories = AutoDownloadSettings(
      enabled: true,
      scope: AutoDownloadScope.selectedCategories,
      categoryIds: <int>{2},
    );

    test('nothing qualifies while the master switch is off', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(
        AutoDownloadSettings(),
      );

      expect(policy.appliesTo(_entry('a')), isFalse);
      expect(
        policy.appliesTo(
          _entry('b', autoDownload: AutoDownloadOverride.always),
        ),
        isFalse,
      );
    });

    test('every title qualifies with the all titles scope', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(allTitles);

      expect(policy.appliesTo(_entry('a')), isTrue);
      expect(policy.appliesTo(_entry('b', categoryId: 7)), isTrue);
    });

    test('the category scope keeps only titles in selected categories', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(categories);

      expect(policy.appliesTo(_entry('a', categoryId: 2)), isTrue);
      expect(policy.appliesTo(_entry('b', categoryId: 3)), isFalse);
      expect(policy.appliesTo(_entry('c')), isFalse);
    });

    test('a per-title override wins over the scope', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(categories);

      expect(
        policy.appliesTo(
          _entry('a', categoryId: 3, autoDownload: AutoDownloadOverride.always),
        ),
        isTrue,
      );
      expect(
        policy.appliesTo(
          _entry('b', categoryId: 2, autoDownload: AutoDownloadOverride.never),
        ),
        isFalse,
      );
    });
  });

  group('AutoDownloadPolicy.pick', () {
    final List<Chapter> chapters =
        _uids(1, 8).map(_chapter).toList(growable: false);

    test('takes at most the per-title limit in reading order', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(
        AutoDownloadSettings(enabled: true, maxPerTitle: 3),
      );

      final List<Chapter> picked =
          policy.pick(chapters, keptUids: const <String>{});

      expect(picked.map((Chapter c) => c.uid), <String>['c1', 'c2', 'c3']);
    });

    test('skips items that are already downloaded or queued', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(
        AutoDownloadSettings(enabled: true, maxPerTitle: 3),
      );

      final List<Chapter> picked =
          policy.pick(chapters, keptUids: <String>{'c1', 'c3'});

      expect(picked.map((Chapter c) => c.uid), <String>['c2', 'c4', 'c5']);
    });

    test('no limit keeps every new item once', () {
      const AutoDownloadPolicy policy = AutoDownloadPolicy(
        AutoDownloadSettings(
          enabled: true,
          maxPerTitle: kAutoDownloadUnlimited,
        ),
      );

      final List<Chapter> picked = policy.pick(
        <Chapter>[...chapters, _chapter('c2')],
        keptUids: const <String>{},
      );

      expect(picked, hasLength(8));
    });
  });

  group('AutoDownloadPreferences', () {
    test('defaults to off with a limit of five', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final AutoDownloadSettings settings =
          await AutoDownloadPreferences().read();

      expect(settings, const AutoDownloadSettings());
      expect(settings.maxPerTitle, 5);
    });

    test('round-trips every field', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const AutoDownloadSettings stored = AutoDownloadSettings(
        enabled: true,
        scope: AutoDownloadScope.selectedCategories,
        categoryIds: <int>{4, 1},
        maxPerTitle: kAutoDownloadUnlimited,
      );

      await AutoDownloadPreferences().write(stored);

      expect(await AutoDownloadPreferences().read(reload: true), stored);
    });
  });

  group('auto-download from a library update check', () {
    late WakaranaiDatabase database;
    late _Harness harness;

    setUp(() async {
      database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
      harness = _Harness(database);
      await harness.extensions
          .create(_extension(_mangaExtensionUid, ConfigInfoType.MANGA));
      await harness.extensions
          .create(_extension(_animeExtensionUid, ConfigInfoType.ANIME));
    });

    tearDown(() async => database.close());

    test('queues new chapters up to the limit as queued rows', () async {
      await harness.entries.create(_entry('m1'));
      await harness.check(<String, ConcreteView>{
        'm1': _mangaView('m1', _uids(1, 2)),
      });

      final LibraryUpdateCheckResult result = await harness.check(
        <String, ConcreteView>{'m1': _mangaView('m1', _uids(1, 10))},
        settings: const AutoDownloadSettings(enabled: true),
      );

      expect(result.updates, hasLength(8));
      expect(result.autoQueuedByEntry, <String, int>{'m1': 5});
      expect(result.autoQueued, 5);
      expect(await harness.pendingUids(), _uids(3, 7));

      final DownloadDomain row = (await harness.downloads.getByUid('c3'))!;
      expect(row.status, DownloadStatus.queued);
      expect(row.kind, DownloadKind.chapter);
      expect(row.concreteUid, 'm1');
      expect(row.concreteTitle, 'Title m1');
      expect(row.dataJson, <String, dynamic>{'n': 'c3'});
      expect(row.dirPath, '/downloads/manga.ext/m1/c3');
      final int concreteId = (await harness.concretes.getByUid('m1'))!.id;
      expect(row.concreteId, concreteId);
    });

    test('leaves titles alone when auto-download does not apply', () async {
      await harness.entries.create(
        _entry('never', autoDownload: AutoDownloadOverride.never),
      );
      await harness.entries.create(_entry('other', categoryId: 9));
      final Map<String, ConcreteView> before = <String, ConcreteView>{
        'never': _mangaView('never', <String>['n1']),
        'other': _mangaView('other', <String>['o1']),
      };
      await harness.check(before);

      final LibraryUpdateCheckResult result = await harness.check(
        <String, ConcreteView>{
          'never': _mangaView('never', <String>['n1', 'n2']),
          'other': _mangaView('other', <String>['o1', 'o2']),
        },
        settings: const AutoDownloadSettings(
          enabled: true,
          scope: AutoDownloadScope.selectedCategories,
          categoryIds: <int>{1},
        ),
      );

      expect(result.updates, hasLength(2));
      expect(result.autoQueuedByEntry, isEmpty);
      expect(await harness.pendingUids(), isEmpty);
    });

    test('a check without the master switch queues nothing', () async {
      await harness.entries.create(_entry('m1'));
      await harness.check(<String, ConcreteView>{
        'm1': _mangaView('m1', <String>['c1']),
      });

      final LibraryUpdateCheckResult result = await harness.check(
        <String, ConcreteView>{'m1': _mangaView('m1', <String>['c1', 'c2'])},
      );

      expect(result.updates, hasLength(1));
      expect(result.autoQueued, 0);
      expect(await harness.pendingUids(), isEmpty);
    });

    test('does not queue a chapter that is already downloaded', () async {
      await harness.entries.create(_entry('m1'));
      await harness.check(<String, ConcreteView>{
        'm1': _mangaView('m1', <String>['c1']),
      });
      await harness.downloads.create(DownloadDomain(
        id: 0,
        uid: 'c2',
        extensionUid: _mangaExtensionUid,
        concreteUid: 'm1',
        concreteId: (await harness.concretes.getByUid('m1'))!.id,
        concreteTitle: 'Title m1',
        title: 'Chapter c2',
        status: DownloadStatus.done,
        downloadedPages: 3,
        totalPages: 3,
        dirPath: '/downloads/c2',
        createdAt: DateTime.now(),
      ));

      final LibraryUpdateCheckResult result = await harness.check(
        <String, ConcreteView>{
          'm1': _mangaView('m1', <String>['c1', 'c2', 'c3']),
        },
        settings: const AutoDownloadSettings(enabled: true, maxPerTitle: 1),
      );

      expect(result.autoQueuedByEntry, <String, int>{'m1': 1});
      expect(await harness.pendingUids(), <String>['c3']);
      expect(
        (await harness.downloads.getByUid('c2'))!.status,
        DownloadStatus.done,
      );
    });

    test('queues new episodes oldest first as episode rows', () async {
      await harness.entries.create(
        _entry('a1', extensionUid: _animeExtensionUid),
      );
      await harness.check(<String, ConcreteView>{
        'a1': _animeView('a1', <int>[3, 2, 1]),
      });

      final LibraryUpdateCheckResult result = await harness.check(
        <String, ConcreteView>{'a1': _animeView('a1', <int>[6, 5, 4, 3, 2, 1])},
        settings: const AutoDownloadSettings(enabled: true),
      );

      expect(result.autoQueuedByEntry, <String, int>{'a1': 3});
      expect(await harness.pendingUids(), <String>['ep4', 'ep5', 'ep6']);
      final DownloadDomain row = (await harness.downloads.getByUid('ep4'))!;
      expect(row.kind, DownloadKind.episode);
      expect(downloadedEpisodeOf(row)?.src, 'https://cdn.test/ep4.mp4');
    });
  });

  group('the app picks up rows queued in the background', () {
    late Directory tempDir;
    late WakaranaiDatabase database;
    late _Harness harness;
    late _RecordingDownloader downloader;
    late DownloadManagerCubit cubit;

    DownloadManagerCubit buildCubit({
      bool wifiOnly = false,
      NetworkConnection connection = NetworkConnection.wifi,
    }) {
      return DownloadManagerCubit(
        downloadRepository: harness.downloads,
        notificationService: _SilentNotifications(),
        episodeSourceResolver: _DirectSources(),
        episodeDownloader: downloader,
        readQualityPreference: () async =>
            const QualityPreference(streamLabel: '720p'),
        downloadRuntime: _IdleRuntime(),
        networkPolicy: DownloadNetworkPolicy(
          monitor: _FixedNetwork(connection),
          readWifiOnly: () async => wifiOnly,
        ),
      );
    }

    Future<void> queueInBackground(List<int> before, List<int> after) async {
      await harness.check(<String, ConcreteView>{
        'a1': _animeView('a1', before),
      });
      await harness.check(
        <String, ConcreteView>{'a1': _animeView('a1', after)},
        settings: const AutoDownloadSettings(enabled: true),
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('wakaranai_auto_download');
      database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
      harness = _Harness(database);
      downloader = _RecordingDownloader();
      await harness.extensions
          .create(_extension(_animeExtensionUid, ConfigInfoType.ANIME));
      await harness.entries.create(
        _entry('a1', extensionUid: _animeExtensionUid),
      );
    });

    tearDown(() async {
      if (!cubit.isClosed) {
        await cubit.close();
      }
      await database.close();
      try {
        tempDir.deleteSync(recursive: true);
      } on FileSystemException {
        return;
      }
    });

    Future<Directory> tempDirFor(
      String extensionUid,
      String concreteUid,
      String itemUid,
    ) async {
      return Directory('${tempDir.path}/$itemUid');
    }

    Future<void> queueWithRealDirs(List<int> before, List<int> after) async {
      await harness.check(<String, ConcreteView>{
        'a1': _animeView('a1', before),
      });
      await LibraryUpdateService(
        libraryEntryRepository: harness.entries,
        libraryUpdateRepository: harness.updates,
        concreteDataRepository: harness.concretes,
        extensionRepository: harness.extensions,
        fetcher: (ExtensionDomain _, LibraryEntryDomain __) async =>
            _animeView('a1', after),
        autoDownloads: AutoDownloadQueuer(
          downloadRepository: harness.downloads,
          settings: const AutoDownloadSettings(enabled: true),
          resolveDir: tempDirFor,
        ),
      ).check();
    }

    test('downloads the queued rows when the app starts', () async {
      await queueWithRealDirs(<int>[1], <int>[2, 1]);
      cubit = buildCubit();

      cubit.init();
      await _until(() async =>
          (await harness.downloads.getByUid('ep2'))?.status ==
          DownloadStatus.done);

      expect(downloader.urls, <String>['https://cdn.test/ep2.mp4']);
    });

    test('adopts rows written while the app was already open', () async {
      cubit = buildCubit();
      cubit.init();
      await cubit.adoptQueuedDownloads();
      await queueWithRealDirs(<int>[1], <int>[3, 2, 1]);
      expect(downloader.urls, isEmpty);

      cubit.init();
      await _until(() async =>
          (await harness.downloads.getByUid('ep3'))?.status ==
          DownloadStatus.done);

      expect(downloader.urls, <String>[
        'https://cdn.test/ep2.mp4',
        'https://cdn.test/ep3.mp4',
      ]);
    });

    test('holds adopted rows for Wi-Fi when the queue is Wi-Fi only',
        () async {
      await queueInBackground(<int>[1], <int>[2, 1]);
      cubit = buildCubit(
        wifiOnly: true,
        connection: NetworkConnection.cellular,
      );

      cubit.init();
      await _until(() => cubit.state.waitingForWifi);

      expect(downloader.urls, isEmpty);
      expect(
        (await harness.downloads.getByUid('ep2'))!.status,
        DownloadStatus.queued,
      );
    });
  });

  group('the library update notification', () {
    setUpAll(() => S.load(const Locale('en')));

    LibraryUpdateDomain update(String uid, String entryUid) {
      return LibraryUpdateDomain(
        id: 0,
        uid: uid,
        libraryEntryUid: entryUid,
        extensionUid: _mangaExtensionUid,
        title: 'Chapter $uid',
        concreteTitle: 'Title $entryUid',
        mediaType: UpdateMediaType.manga,
        createdAt: DateTime.now(),
      );
    }

    test('says how many new items are waiting to download', () {
      final UpdatesNotificationText text = UpdatesNotificationText(
        <LibraryUpdateDomain>[
          update('c1', 'm1'),
          update('c2', 'm1'),
          update('c3', 'm1'),
          update('x1', 'm2'),
        ],
        autoQueuedByEntry: <String, int>{'m1': 3},
      );

      expect(text.lines, <String>[
        'Title m1 · 3 new, 3 to download',
        'Title m2 · 1 new',
        '3 downloads start when you open the app',
      ]);
      expect(text.body, '3 downloads start when you open the app');
      expect(text.autoQueued, 3);
    });

    test('keeps the plain summary when nothing was queued', () {
      final UpdatesNotificationText text = UpdatesNotificationText(
        <LibraryUpdateDomain>[update('c1', 'm1')],
      );

      expect(text.lines, <String>['Title m1 · 1 new']);
      expect(text.body, text.summary);
    });
  });
}
