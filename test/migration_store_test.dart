import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';
import 'package:wakaranai/services/migration/migration_store.dart';

ConfigInfo _config(String uid, int type) {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': uid,
    'uid': uid,
    'logoUrl': '',
    'type': type,
    'nsfw': false,
    'language': 'en',
    'version': 1,
    'filters': <dynamic>[],
    'searchAvailable': true,
  });
}

Chapter _chapter(String uid, String title, {double? number}) {
  return Chapter(
    uid: uid,
    title: title,
    data: <String, dynamic>{'uid': uid},
    number: number,
  );
}

MangaConcreteView _manga(String uid, String title, List<Chapter> chapters) {
  return MangaConcreteView(
    uid: uid,
    cover: 'https://cover/$uid',
    title: title,
    alternativeTitles: const <String>['Alt name'],
    description: '',
    tags: const <String>[],
    status: MangaStatus.ONGOING,
    groups: <ChaptersGroup>[ChaptersGroup(title: 'Main', elements: chapters)],
  );
}

AnimeVideo _episode(String uid, double number) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: '',
    title: 'Episode ${number.toInt()}',
    timestamp: null,
    data: const <String, dynamic>{},
    number: number,
  );
}

AnimeConcreteView _anime(String uid, List<AnimeVideo> episodes) {
  return AnimeConcreteView(
    uid: uid,
    cover: '',
    title: uid,
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: AnimeStatus.ONGOING,
    groups: <AnimeVideoGroup>[
      AnimeVideoGroup(title: 'Dub', elements: episodes),
    ],
  );
}

class _Fixture {
  _Fixture(this.database) : store = MigrationStore(database: database);

  final WakaranaiDatabase database;
  final MigrationStore store;
  late int categoryId;
  late int oldConcreteId;

  final MangaConcreteView oldView = _manga('old', 'Old title', <Chapter>[
    _chapter('o1', 'Opening', number: 1),
    _chapter('o2', 'Chapter 2'),
    _chapter('o7', 'Chapter 7'),
  ]);

  final MangaConcreteView newView = _manga('new', 'New title', <Chapter>[
    _chapter('n1', 'First', number: 1),
    _chapter('n2', 'Ch. 2'),
    _chapter('n3', 'Ch. 3'),
  ]);

  Future<void> seed() async {
    categoryId = await database
        .into(database.categoryTable)
        .insert(CategoryTableCompanion.insert(name: 'Reading'));
    oldConcreteId = await database.into(database.concreteDataTable).insert(
          ConcreteDataTableCompanion.insert(
            uid: 'old',
            extensionUid: 'src-a',
            title: 'Old title',
            concreteJson: Value<String?>(jsonEncode(oldView.toJson())),
          ),
        );
    await _activity('o1', 'Opening', readPages: 12, totalPages: 12);
    await _activity('o2', 'Chapter 2', readPages: 3, totalPages: 10);
    await _activity('o7', 'Chapter 7', readPages: 5, totalPages: 5);
    await database.into(database.libraryEntryTable).insert(
          LibraryEntryTableCompanion.insert(
            uid: 'old',
            extensionUid: 'src-a',
            title: 'Old title',
            categoryId: Value<int?>(categoryId),
            trackUpdates: const Value<bool>(false),
            createdAt: Value<DateTime>(DateTime(2024, 5, 1)),
          ),
        );
    await database.into(database.libraryUpdateTable).insert(
          LibraryUpdateTableCompanion.insert(
            uid: 'update-1',
            libraryEntryUid: 'old',
            extensionUid: 'src-a',
            title: 'Chapter 8',
            concreteTitle: 'Old title',
            mediaType: UpdateMediaType.manga,
          ),
        );
    await _link('old', 'anilist', 'src-a', remoteId: 10);
    await _link('old', 'mal', 'src-a', remoteId: 20);
    await _link('new', 'mal', 'src-b', remoteId: 30);
  }

  Future<void> _activity(
    String uid,
    String title, {
    required int readPages,
    required int totalPages,
  }) {
    return database.into(database.chapterActivityTable).insert(
          ChapterActivityTableCompanion.insert(
            uid: uid,
            title: title,
            concreteId: oldConcreteId,
            readPages: readPages,
            totalPages: totalPages,
          ),
        );
  }

  Future<void> _link(
    String concreteUid,
    String trackerId,
    String extensionUid, {
    required int remoteId,
  }) {
    return database.into(database.trackerLinkTable).insert(
          TrackerLinkTableCompanion.insert(
            concreteUid: concreteUid,
            trackerId: trackerId,
            extensionUid: extensionUid,
            mediaType: 'manga',
            remoteId: remoteId,
            remoteTitle: 'Remote',
            status: 'current',
          ),
        );
  }

  Future<MigrationRequest> request({
    MigrationOptions options = const MigrationOptions(),
  }) async {
    final List<MigrationOldProgress> progress =
        await store.loadOldProgress('old', MigrationMediaKind.chapters);
    return MigrationRequest(
      subject: const MigrationSubject(
        uid: 'old',
        extensionUid: 'src-a',
        title: 'Old title',
      ),
      target: MigrationTarget(
        concrete: newView,
        config: _config('src-b', 0),
        galleryData: const <String, dynamic>{'slug': 'new'},
      ),
      progress: mapMigrationProgress(
        kind: MigrationMediaKind.chapters,
        progress: progress,
        targetGroups:
            migrationTargetGroupsOf(newView, MigrationMediaKind.chapters),
      ),
      options: options,
    );
  }

  Future<LibraryEntryTableData?> entry(String uid) {
    return (database.select(database.libraryEntryTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<ConcreteDataTableData?> concrete(String uid) {
    return (database.select(database.concreteDataTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<ChapterActivityTableData?> activity(String uid) {
    return (database.select(database.chapterActivityTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<List<TrackerLinkTableData>> links() {
    return database.select(database.trackerLinkTable).get();
  }
}

void main() {
  late WakaranaiDatabase database;
  late _Fixture fixture;

  setUp(() async {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    fixture = _Fixture(database);
    await fixture.seed();
  });

  tearDown(() async {
    await database.close();
  });

  test('reads old progress with numbers from the saved details', () async {
    final List<MigrationOldProgress> progress = await fixture.store
        .loadOldProgress('old', MigrationMediaKind.chapters);
    final Map<String, double?> numbers = <String, double?>{
      for (final MigrationOldProgress item in progress) item.uid: item.number,
    };
    expect(numbers, <String, double?>{'o1': 1, 'o2': 2, 'o7': 7});
    expect(
      await fixture.store.loadAlternativeTitles('old'),
      <String>['Alt name'],
    );
    expect(
      await fixture.store.detectKind('old'),
      MigrationMediaKind.chapters,
    );
  });

  test('replaces the old entry and carries progress and category', () async {
    final MigrationRequest request = await fixture.request();
    expect(
      request.progress.unmatched.map((MigrationOldProgress p) => p.uid),
      <String>['o7'],
    );

    final MigrationResult result = await fixture.store.apply(request);

    expect(result.removedOld, isTrue);
    expect(result.progressWritten, 2);
    final ConcreteDataTableData? concrete = await fixture.concrete('new');
    expect(concrete?.extensionUid, 'src-b');
    expect(concrete?.concreteJson, isNotNull);

    final ChapterActivityTableData? first = await fixture.activity('n1');
    expect(first?.concreteId, concrete?.id);
    expect(first?.readPages, 12);
    expect(first?.totalPages, 12);
    final ChapterActivityTableData? second = await fixture.activity('n2');
    expect(second?.readPages, 3);
    expect(second?.totalPages, 10);
    expect(await fixture.activity('n3'), isNull);

    final LibraryEntryTableData? entry = await fixture.entry('new');
    expect(entry?.extensionUid, 'src-b');
    expect(entry?.categoryId, fixture.categoryId);
    expect(entry?.trackUpdates, isFalse);
    expect(entry?.createdAt, DateTime(2024, 5, 1));
    expect(jsonDecode(entry!.data!), <String, dynamic>{'slug': 'new'});
    expect(await fixture.entry('old'), isNull);
    expect(await database.select(database.libraryUpdateTable).get(), isEmpty);

    expect(await fixture.activity('o1'), isNotNull);
    expect(await fixture.concrete('old'), isNotNull);
  });

  test('re-points tracker links and keeps a link the target already has',
      () async {
    final MigrationResult result =
        await fixture.store.apply(await fixture.request());

    expect(result.trackersMoved, 1);
    final List<TrackerLinkTableData> links = await fixture.links();
    final Map<String, TrackerLinkTableData> byTracker =
        <String, TrackerLinkTableData>{
      for (final TrackerLinkTableData link in links) link.trackerId: link,
    };
    expect(links, hasLength(2));
    expect(byTracker['anilist']?.concreteUid, 'new');
    expect(byTracker['anilist']?.extensionUid, 'src-b');
    expect(byTracker['anilist']?.remoteId, 10);
    expect(byTracker['mal']?.concreteUid, 'new');
    expect(byTracker['mal']?.remoteId, 30);
  });

  test('keeps the old entry when asked and skips what is turned off',
      () async {
    final MigrationResult result = await fixture.store.apply(
      await fixture.request(
        options: const MigrationOptions(
          keepOld: true,
          moveCategory: false,
          moveProgress: false,
          moveTrackers: false,
        ),
      ),
    );

    expect(result.removedOld, isFalse);
    expect(result.progressWritten, 0);
    expect(await fixture.entry('old'), isNotNull);
    expect((await fixture.entry('new'))?.categoryId, isNull);
    expect(await fixture.activity('n1'), isNull);
    final List<TrackerLinkTableData> links = await fixture.links();
    expect(
      links.where((TrackerLinkTableData link) => link.concreteUid == 'old'),
      hasLength(2),
    );
  });

  test('never downgrades progress the new title already has', () async {
    final int newConcreteId = await database.into(database.concreteDataTable).insert(
          ConcreteDataTableCompanion.insert(
            uid: 'new',
            extensionUid: 'src-b',
            title: 'New title',
          ),
        );
    await database.into(database.chapterActivityTable).insert(
          ChapterActivityTableCompanion.insert(
            uid: 'n2',
            title: 'Ch. 2',
            concreteId: newConcreteId,
            readPages: 10,
            totalPages: 10,
          ),
        );

    final MigrationResult result =
        await fixture.store.apply(await fixture.request());

    expect(result.progressWritten, 1);
    expect((await fixture.activity('n2'))?.readPages, 10);
    expect((await fixture.concrete('new'))?.id, newConcreteId);
  });

  test('rolls everything back when a write fails', () async {
    await database.customStatement(
      'CREATE TRIGGER fail_link BEFORE UPDATE ON tracker_link_table '
      "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
    );
    final MigrationRequest request = await fixture.request();

    await expectLater(fixture.store.apply(request), throwsA(isA<Object>()));

    expect(await fixture.concrete('new'), isNull);
    expect(await fixture.entry('new'), isNull);
    expect(await fixture.entry('old'), isNotNull);
    expect(await fixture.activity('n1'), isNull);
    expect(await database.select(database.libraryUpdateTable).get(), hasLength(1));
    final List<TrackerLinkTableData> links = await fixture.links();
    expect(
      links.where((TrackerLinkTableData link) => link.concreteUid == 'old'),
      hasLength(2),
    );
  });

  test('marks matched episodes watched', () async {
    final int concreteId = await database.into(database.concreteDataTable).insert(
          ConcreteDataTableCompanion.insert(
            uid: 'old-anime',
            extensionUid: 'anime-a',
            title: 'Old anime',
            concreteJson: Value<String?>(jsonEncode(
              _anime('old-anime', <AnimeVideo>[_episode('oe1', 1)]).toJson(),
            )),
          ),
        );
    await database.into(database.animeEpisodeActivityTable).insert(
          AnimeEpisodeActivityTableCompanion.insert(
            uid: 'oe1',
            title: 'Pilot',
            concreteId: concreteId,
            watchedTime: const Value<int?>(1380),
            totalTime: const Value<int?>(1400),
          ),
        );
    final AnimeConcreteView target =
        _anime('new-anime', <AnimeVideo>[_episode('ne1', 1), _episode('ne2', 2)]);
    final List<MigrationOldProgress> progress = await fixture.store
        .loadOldProgress('old-anime', MigrationMediaKind.episodes);

    await fixture.store.apply(MigrationRequest(
      subject: const MigrationSubject(
        uid: 'old-anime',
        extensionUid: 'anime-a',
        title: 'Old anime',
      ),
      target: MigrationTarget(
        concrete: target,
        config: _config('anime-b', 1),
        galleryData: const <String, dynamic>{},
      ),
      progress: mapMigrationProgress(
        kind: MigrationMediaKind.episodes,
        progress: progress,
        targetGroups:
            migrationTargetGroupsOf(target, MigrationMediaKind.episodes),
      ),
      options: const MigrationOptions(),
    ));

    final AnimeEpisodeActivityTableData? watched =
        await (database.select(database.animeEpisodeActivityTable)
              ..where((tbl) => tbl.uid.equals('ne1')))
            .getSingleOrNull();
    expect(watched?.markedWatched, isTrue);
    expect(watched?.watchedTime, 1380);
    expect(await fixture.store.detectKind('old-anime'),
        MigrationMediaKind.episodes);
  });
}
