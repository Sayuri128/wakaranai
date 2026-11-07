import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/services/downloads/storage/download_sizes.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_downloads.dart';
import 'package:wakaranai/ui/home/downloads_page/cubit/download_sizes_cubit.dart';

DownloadDomain _download(
  String uid, {
  String concreteUid = 'concrete',
  DownloadKind kind = DownloadKind.episode,
  DownloadStatus status = DownloadStatus.done,
  int downloadedBytes = 0,
  int downloadedPages = 0,
}) {
  return DownloadDomain(
    id: 1,
    uid: uid,
    extensionUid: 'ext',
    concreteUid: concreteUid,
    concreteId: 1,
    concreteTitle: 'Title $concreteUid',
    title: uid,
    status: status,
    downloadedPages: downloadedPages,
    totalPages: 0,
    dirPath: '/downloads/$uid',
    kind: kind,
    downloadedBytes: downloadedBytes,
    createdAt: DateTime(2026),
  );
}

AnimeEpisodeActivityDomain _activity(
  String uid, {
  int? watched,
  int? total,
  bool markedWatched = false,
}) {
  return AnimeEpisodeActivityDomain(
    id: 0,
    uid: uid,
    title: uid,
    concreteId: 1,
    watchedTime: watched,
    totalTime: total,
    markedWatched: markedWatched,
    createdAt: DateTime(2026),
  );
}

void main() {
  group('measureDirectorySize', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('download_sizes_test');
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('sums every file below the directory', () async {
      await File(
        p.join(root.path, 'a.bin'),
      ).writeAsBytes(List<int>.filled(10, 1));
      final Directory nested = Directory(p.join(root.path, 'v'));
      await nested.create();
      await File(
        p.join(nested.path, 'b.ts'),
      ).writeAsBytes(List<int>.filled(25, 1));

      expect(await measureDirectorySize(root.path), 35);
    });

    test('reports zero for a missing or empty path', () async {
      expect(await measureDirectorySize(p.join(root.path, 'missing')), 0);
      expect(await measureDirectorySize(''), 0);
    });
  });

  group('DownloadSizeCache', () {
    test('measures settled downloads once until they change', () async {
      final List<String> reads = <String>[];
      final DownloadSizeCache cache = DownloadSizeCache(
        readDirectorySize: (String dirPath) async {
          reads.add(dirPath);
          return 100;
        },
      );
      final DownloadDomain chapter = _download(
        'c1',
        kind: DownloadKind.chapter,
        downloadedPages: 3,
      );

      expect(await cache.refresh(<DownloadDomain>[chapter]), <String, int>{
        'c1': 100,
      });
      await cache.refresh(<DownloadDomain>[chapter]);
      expect(reads, <String>['/downloads/c1']);

      final DownloadDomain changed = chapter.copyWith(downloadedPages: 4);
      await cache.refresh(<DownloadDomain>[changed]);
      expect(reads, <String>['/downloads/c1', '/downloads/c1']);
    });

    test('uses reported bytes for downloads still in progress', () async {
      final List<String> reads = <String>[];
      final DownloadSizeCache cache = DownloadSizeCache(
        readDirectorySize: (String dirPath) async {
          reads.add(dirPath);
          return 1;
        },
      );

      final Map<String, int> sizes = await cache.refresh(<DownloadDomain>[
        _download(
          'e1',
          status: DownloadStatus.downloading,
          downloadedBytes: 512,
        ),
        _download(
          'c1',
          kind: DownloadKind.chapter,
          status: DownloadStatus.queued,
        ),
      ]);

      expect(sizes, <String, int>{'e1': 512});
      expect(reads, isEmpty);
    });

    test('forgets downloads that were removed', () async {
      int reads = 0;
      final DownloadSizeCache cache = DownloadSizeCache(
        readDirectorySize: (String dirPath) async {
          reads++;
          return 7;
        },
      );
      final DownloadDomain episode = _download('e1');

      await cache.refresh(<DownloadDomain>[episode]);
      expect(await cache.refresh(const <DownloadDomain>[]), isEmpty);
      await cache.refresh(<DownloadDomain>[episode]);

      expect(reads, 2);
    });
  });

  group('summarizeDownloadStorage', () {
    test('totals per item, per title and overall', () {
      final List<DownloadDomain> downloads = <DownloadDomain>[
        _download('a1', concreteUid: 'anime'),
        _download('a2', concreteUid: 'anime'),
        _download('m1', concreteUid: 'manga', kind: DownloadKind.chapter),
      ];

      final DownloadStorageUsage usage = summarizeDownloadStorage(
        downloads,
        <String, int>{'a1': 300, 'a2': 200, 'm1': 50},
      );

      expect(usage.bytesOfItem('a2'), 200);
      expect(usage.bytesOfTitle('anime'), 500);
      expect(usage.bytesOfTitle('manga'), 50);
      expect(usage.totalBytes, 550);
      expect(usage.complete, isTrue);
      expect(
        usage.titlesBySize.map((TitleStorageUsage title) => title.concreteUid),
        <String>['anime', 'manga'],
      );
      expect(usage.titles['anime']!.isEpisode, isTrue);
      expect(usage.titles['anime']!.downloads, hasLength(2));
    });

    test('is incomplete while a settled download is unmeasured', () {
      final DownloadStorageUsage usage = summarizeDownloadStorage(
        <DownloadDomain>[
          _download('a1'),
          _download('a2', status: DownloadStatus.downloading),
        ],
        const <String, int>{},
      );

      expect(usage.complete, isFalse);
      expect(usage.totalBytes, 0);
    });

    test('adds up only the given downloads', () {
      expect(
        bytesOfDownloads(
          <DownloadDomain>[_download('a1'), _download('x')],
          <String, int>{'a1': 3, 'a2': 4},
        ),
        3,
      );
    });
  });

  group('watched episode selection', () {
    test('keeps finished, completed episode downloads only', () {
      final List<DownloadDomain> downloads = <DownloadDomain>[
        _download('e1'),
        _download('e2'),
        _download('e3', status: DownloadStatus.downloading),
        _download('c1', kind: DownloadKind.chapter),
      ];

      final List<DownloadDomain> watched = watchedEpisodeDownloads(
        downloads,
        <String>{'e1', 'e3', 'c1'},
      );

      expect(watched.map((DownloadDomain d) => d.uid), <String>['e1']);
    });

    test('reads finished episodes from the title activity', () async {
      final List<String> askedFor = <String>[];
      final WatchedEpisodeFinder finder = WatchedEpisodeFinder(
        readActivities: (String concreteUid) async {
          askedFor.add(concreteUid);
          return <AnimeEpisodeActivityDomain>[
            _activity('e1', watched: 1380, total: 1400),
            _activity('e2', watched: 100, total: 1400),
            _activity('e3', watched: 100, total: 1400, markedWatched: true),
            _activity('e4', markedWatched: true),
          ];
        },
      );

      final List<DownloadDomain> watched = await finder.watchedDownloadsOf(
        <DownloadDomain>[
          _download('e1'),
          _download('e2'),
          _download('e3'),
          _download('e4'),
        ],
      );

      expect(
        watched.map((DownloadDomain d) => d.uid),
        <String>['e1', 'e3', 'e4'],
      );
      expect(askedFor, <String>['concrete']);
    });

    test('opened episodes without real progress are not deleted', () async {
      final WatchedEpisodeFinder finder = WatchedEpisodeFinder(
        readActivities: (String concreteUid) async {
          return <AnimeEpisodeActivityDomain>[
            _activity('opened'),
            _activity('unknown-length', watched: 1300),
            _activity('zero-length', watched: 0, total: 0),
          ];
        },
      );

      final List<DownloadDomain> watched = await finder.watchedDownloadsOf(
        <DownloadDomain>[
          _download('opened'),
          _download('unknown-length'),
          _download('zero-length'),
        ],
      );

      expect(watched, isEmpty);
    });

    test('skips the activity lookup for manga titles', () async {
      bool asked = false;
      final WatchedEpisodeFinder finder = WatchedEpisodeFinder(
        readActivities: (String concreteUid) async {
          asked = true;
          return null;
        },
      );

      final List<DownloadDomain> watched = await finder.watchedDownloadsOf(
        <DownloadDomain>[_download('c1', kind: DownloadKind.chapter)],
      );

      expect(watched, isEmpty);
      expect(asked, isFalse);
    });
  });

  group('DownloadSizesCubit', () {
    test('measures on start and again when downloads change', () async {
      final StreamController<List<DownloadDomain>> downloads =
          StreamController<List<DownloadDomain>>();
      final DownloadSizesCubit cubit = DownloadSizesCubit(
        downloads: downloads.stream,
        initial: <DownloadDomain>[_download('e1')],
        cache: DownloadSizeCache(
          readDirectorySize: (String dirPath) async => dirPath.length,
        ),
        debounce: Duration.zero,
      );

      await pumpEventQueue();
      expect(cubit.state.measured, isTrue);
      expect(cubit.state.usage.totalBytes, '/downloads/e1'.length);

      downloads.add(<DownloadDomain>[_download('e1'), _download('e22')]);
      await pumpEventQueue();
      expect(
        cubit.state.usage.totalBytes,
        '/downloads/e1'.length + '/downloads/e22'.length,
      );

      await cubit.close();
      await downloads.close();
    });
  });
}
