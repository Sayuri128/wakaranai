import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/tracker_link_repository.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';
import 'package:wakaranai/services/trackers/tracker_accounts_store.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_progress.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';

class _FakeTracker extends TrackerService {
  _FakeTracker(this.id);

  @override
  final TrackerId id;

  final Map<int, TrackerEntry> entries = <int, TrackerEntry>{};
  final List<int> pushed = <int>[];
  bool failUpdates = false;

  @override
  String get name => id.name;

  @override
  bool get isConfigured => true;

  @override
  Future<TrackerAccount> login() async {
    return const TrackerAccount(accessToken: 't', userId: 1, userName: 'me');
  }

  @override
  Future<List<TrackerSearchResult>> search(
    TrackerAccount account,
    String query,
    TrackerMediaType type,
  ) async {
    return <TrackerSearchResult>[
      TrackerSearchResult(remoteId: 10, title: query, malId: 99, totalCount: 5),
    ];
  }

  @override
  Future<TrackerSearchResult?> byId(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    return TrackerSearchResult(remoteId: remoteId, title: 'Same', totalCount: 5);
  }

  @override
  Future<TrackerEntry?> entry(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type,
  ) async {
    return entries[remoteId];
  }

  @override
  Future<TrackerEntry> update(
    TrackerAccount account,
    int remoteId,
    TrackerMediaType type, {
    required TrackerStatus status,
    required int progress,
  }) async {
    if (failUpdates) {
      throw Exception('offline');
    }
    pushed.add(progress);
    final TrackerEntry entry =
        TrackerEntry(status: status, progress: progress, totalCount: 5);
    entries[remoteId] = entry;
    return entry;
  }
}

Chapter _chapter(String uid, {double? number, String? title}) {
  return Chapter(
    uid: uid,
    title: title ?? 'Chapter $uid',
    data: const <String, dynamic>{},
    number: number,
  );
}

ChapterActivityDomain _read(String uid) {
  return ChapterActivityDomain(
    id: 0,
    uid: uid,
    title: uid,
    timestamp: null,
    data: null,
    concreteId: 1,
    readPages: 10,
    totalPages: 10,
    createdAt: DateTime(2026),
  );
}

void main() {
  group('progress', () {
    test('parses chapter numbers in several languages', () {
      expect(parseChapterNumber('Chapter 12'), 12);
      expect(parseChapterNumber('Том 2 Глава 15.5'), 15.5);
      expect(parseChapterNumber('Розділ 7: Початок'), 7);
      expect(parseChapterNumber('Extra'), isNull);
    });

    test('uses the highest finished chapter number, falling back to position',
        () {
      final List<ChaptersGroup> groups = <ChaptersGroup>[
        ChaptersGroup(title: 'Main', elements: <Chapter>[
          _chapter('a', title: 'Prologue'),
          _chapter('b', number: 2),
          _chapter('c', title: 'Chapter 7'),
        ]),
      ];
      expect(
        finishedChapterProgress(
          groups: groups,
          activities: <String, ChapterActivityDomain>{'a': _read('a')},
        ),
        1,
      );
      expect(
        finishedChapterProgress(
          groups: groups,
          activities: <String, ChapterActivityDomain>{
            'b': _read('b'),
            'c': _read('c'),
          },
        ),
        7,
      );
    });

    test('completes when the total is reached', () {
      expect(
        statusAfterProgress(
          current: TrackerStatus.planning,
          progress: 5,
          totalCount: 5,
        ),
        TrackerStatus.completed,
      );
      expect(
        statusAfterProgress(current: TrackerStatus.paused, progress: 2),
        TrackerStatus.current,
      );
    });
  });

  group('TrackerSyncService', () {
    late WakaranaiDatabase database;
    late _FakeTracker anilist;
    late _FakeTracker mal;
    late MemoryTrackerAccountsStore accounts;
    late TrackerSyncService sync;

    setUp(() async {
      database = WakaranaiDatabase.forTesting(
        NativeDatabase.opened(sqlite3.openInMemory()),
      );
      anilist = _FakeTracker(TrackerId.anilist);
      mal = _FakeTracker(TrackerId.mal);
      accounts = MemoryTrackerAccountsStore();
      sync = TrackerSyncService(
        links: TrackerLinkRepository(database: database),
        accounts: accounts,
        services: <TrackerService>[anilist, mal],
      );
      await sync.login(TrackerId.anilist);
      IncognitoMode.active = false;
    });

    tearDown(() async {
      IncognitoMode.active = false;
      await database.close();
    });

    Future<TrackerLink> linkTitle() {
      return sync.link(
        trackerId: TrackerId.anilist,
        concreteUid: 'title',
        extensionUid: 'ext',
        type: TrackerMediaType.manga,
        result: const TrackerSearchResult(
          remoteId: 10,
          title: 'Title',
          malId: 99,
          totalCount: 5,
        ),
        localProgress: 2,
      );
    }

    test('linking adds the title with the local progress', () async {
      final TrackerLink link = await linkTitle();
      expect(link.progress, 2);
      expect(link.status, TrackerStatus.current);
      expect(anilist.pushed, <int>[2]);
    });

    test('linking keeps a remote progress that is ahead', () async {
      anilist.entries[10] =
          const TrackerEntry(status: TrackerStatus.current, progress: 4);
      final TrackerLink link = await linkTitle();
      expect(link.progress, 4);
      expect(anilist.pushed, isEmpty);
    });

    test('only pushes progress that moves forward', () async {
      await linkTitle();
      await sync.recordProgress('title', 2);
      await sync.recordProgress('title', 1);
      await sync.recordProgress('title', 5);
      expect(anilist.pushed, <int>[2, 5]);
      final TrackerLink stored =
          (await sync.links.linksFor('title')).single;
      expect(stored.status, TrackerStatus.completed);
    });

    test('incognito mode never pushes', () async {
      await linkTitle();
      IncognitoMode.active = true;
      await sync.recordProgress('title', 4);
      expect(anilist.pushed, <int>[2]);
    });

    test('failed pushes are kept and retried', () async {
      await linkTitle();
      anilist.failUpdates = true;
      await sync.recordProgress('title', 3);
      expect((await sync.links.pending()).single.pendingProgress, 3);

      anilist.failUpdates = false;
      expect(await sync.retryPending(), 1);
      expect((await sync.links.pending()), isEmpty);
      expect((await sync.links.linksFor('title')).single.progress, 3);
    });

    test('links other signed-in trackers through the MAL id', () async {
      await sync.login(TrackerId.mal);
      await linkTitle();
      final List<TrackerLink> linked = await sync.linkOthersByMalId(
        origin: TrackerId.anilist,
        concreteUid: 'title',
        extensionUid: 'ext',
        type: TrackerMediaType.manga,
        malId: 99,
        localProgress: 2,
      );
      expect(linked.single.trackerId, TrackerId.mal);
      expect(linked.single.remoteId, 99);
    });

    test('signing out removes the links of that tracker', () async {
      await linkTitle();
      await sync.logout(TrackerId.anilist);
      expect(await sync.links.linksFor('title'), isEmpty);
      expect(await sync.account(TrackerId.anilist), isNull);
    });
  });
}
