import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_bulk_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_candidates.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/global_search/global_search_backend.dart';
import 'package:wakaranai/services/global_search/global_search_catalog.dart';
import 'package:wakaranai/services/global_search/global_search_scope.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_store.dart';

ConfigInfo _config(String uid) {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': uid,
    'uid': uid,
    'logoUrl': '',
    'type': 0,
    'nsfw': false,
    'language': 'en',
    'version': 1,
    'filters': <dynamic>[],
    'searchAvailable': true,
  });
}

GlobalSearchSource _source(String uid) {
  return GlobalSearchSource(
    extension: ExtensionDomain(
      id: 0,
      config: _config(uid),
      sourceCode: '',
      createdAt: DateTime(2026),
    ),
  );
}

MangaGalleryView _item(String uid, String title) {
  return MangaGalleryView(
    uid: uid,
    cover: '',
    title: title,
    data: <String, dynamic>{'uid': uid},
  );
}

class _Catalog implements GlobalSearchCatalog {
  _Catalog(this.sources);

  final List<GlobalSearchSource> sources;

  @override
  Future<GlobalSearchCatalogSnapshot> loadKnown() async {
    return GlobalSearchCatalogSnapshot(
      sources: sources,
      pinned: const <String>[],
      used: sources.map((GlobalSearchSource source) => source.uid).toSet(),
    );
  }

  @override
  Future<List<GlobalSearchSource>> loadAllRepositories() async {
    return const <GlobalSearchSource>[];
  }
}

class _Backend implements GlobalSearchBackend {
  _Backend(this.results);

  final Map<String, List<GalleryView>> results;
  final MangaApiClient client = MangaApiClient(code: '');
  final List<String> queries = <String>[];

  @override
  Future<bool> needsSignIn(GlobalSearchSource source) async => false;

  @override
  Future<GlobalSearchHit> search(GlobalSearchSource source, String query) async {
    queries.add(query);
    return GlobalSearchHit(
      items: results[query] ?? const <GalleryView>[],
      client: client,
      config: source.config,
    );
  }

  @override
  Future<BaseExtension> openable(GlobalSearchSource source) async {
    return source.extension;
  }

  @override
  Future<void> dispose() async {}
}

ConcreteView _concreteFor(MigrationCandidate candidate) {
  return MangaConcreteView(
    uid: candidate.item.uid,
    cover: '',
    title: migrationCandidateTitleOf(candidate.item),
    alternativeTitles: const <String>[],
    description: '',
    tags: const <String>[],
    status: MangaStatus.ONGOING,
    groups: <ChaptersGroup>[
      ChaptersGroup(
        title: 'Main',
        elements: <Chapter>[
          Chapter(
            uid: '${candidate.item.uid}-1',
            title: 'Chapter 1',
            data: const <String, dynamic>{},
          ),
        ],
      ),
    ],
  );
}

Future<void> _settle() async {
  for (int index = 0; index < 20; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late WakaranaiDatabase database;
  late GlobalSearchCubit search;
  late MigrationBulkCubit bulk;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    for (final String uid in <String>['old-a', 'old-b']) {
      await database.into(database.libraryEntryTable).insert(
            LibraryEntryTableCompanion.insert(
              uid: uid,
              extensionUid: 'gone',
              title: uid,
            ),
          );
    }
    search = GlobalSearchCubit(
      backend: _Backend(<String, List<GalleryView>>{
        'Dorohedoro': <GalleryView>[
          _item('new-a', 'Dorohedoro'),
          _item('new-a-extra', 'Dorohedoro Extra'),
        ],
        'Blame': <GalleryView>[_item('new-b', 'Blame Academy')],
      }),
      catalog: _Catalog(<GlobalSearchSource>[_source('target')]),
      rules: const GlobalSearchScopeRules(),
    );
    await search.init();
    bulk = MigrationBulkCubit(
      search: search,
      planner: MigrationPlanner(
        store: MigrationStore(database: database),
        loadConcrete: (MigrationCandidate candidate) async =>
            _concreteFor(candidate),
      ),
      subjects: const <MigrationSubject>[
        MigrationSubject(uid: 'old-a', extensionUid: 'gone', title: 'Dorohedoro'),
        MigrationSubject(uid: 'old-b', extensionUid: 'gone', title: 'Blame'),
      ],
    );
  });

  tearDown(() async {
    await bulk.close();
    await search.close();
    await database.close();
  });

  Future<List<String>> libraryUids() async {
    final List<LibraryEntryTableData> rows =
        await database.select(database.libraryEntryTable).get();
    return rows.map((LibraryEntryTableData row) => row.uid).toList()..sort();
  }

  test('auto-picks an exact match and waits for the user otherwise', () async {
    final Future<void> run = bulk.start();
    await _settle();

    expect(bulk.state.items[0].status, MigrationBulkItemStatus.done);
    expect(bulk.state.items[0].autoPicked, isTrue);
    expect(bulk.state.items[1].status, MigrationBulkItemStatus.needsPick);
    expect(bulk.state.items[1].candidateCount, 1);

    final MigrationCandidate pick =
        rankMigrationSearch(bulk.state.items[1].subject, search.state)
            .single
            .candidate;
    bulk.resolvePick(1, pick);
    await run;

    expect(bulk.state.phase, MigrationBulkPhase.finished);
    expect(bulk.state.items[1].status, MigrationBulkItemStatus.done);
    expect(await libraryUids(), <String>['new-a', 'new-b']);
  });

  test('asks for every pick when auto-pick is off and skips on request',
      () async {
    bulk.setAutoPickExact(false);
    final Future<void> run = bulk.start();
    await _settle();

    expect(bulk.state.items[0].status, MigrationBulkItemStatus.needsPick);
    expect(bulk.state.items[0].candidateCount, 2);
    bulk.resolvePick(0, null);
    await _settle();
    expect(bulk.state.items[0].status, MigrationBulkItemStatus.skipped);
    expect(bulk.state.items[1].status, MigrationBulkItemStatus.needsPick);

    bulk.stop();
    await run;

    expect(bulk.state.items[1].status, MigrationBulkItemStatus.skipped);
    expect(await libraryUids(), <String>['old-a', 'old-b']);
  });

  test('keeps the old entries when asked', () async {
    bulk.setOptions(const MigrationOptions(keepOld: true));
    final Future<void> run = bulk.start();
    await _settle();
    bulk.resolvePick(1, null);
    await run;

    expect(await libraryUids(), <String>['new-a', 'old-a', 'old-b']);
  });
}
