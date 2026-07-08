import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_palette.dart';

class _Env {
  _Env()
      : db = WakaranaiDatabase.forTesting(NativeDatabase.memory()) {
    concrete = ConcreteDataRepository(database: db);
    chapters = ChapterActivityRepository(database: db);
    episodes = AnimeEpisodeActivityRepository(database: db);
    categories = CategoryRepository(database: db);
    library = LibraryEntryRepository(database: db);
    sources = ExtensionSourceRepository(database: db);
    service = ImportExportService(
      concreteDataRepository: concrete,
      chapterActivityRepository: chapters,
      animeEpisodeActivityRepository: episodes,
      categoryRepository: categories,
      libraryEntryRepository: library,
      extensionSourceRepository: sources,
      settingsService: SettingsService(),
    );
  }

  final WakaranaiDatabase db;
  late final ConcreteDataRepository concrete;
  late final ChapterActivityRepository chapters;
  late final AnimeEpisodeActivityRepository episodes;
  late final CategoryRepository categories;
  late final LibraryEntryRepository library;
  late final ExtensionSourceRepository sources;
  late final ImportExportService service;

  Future<void> dispose() => db.close();
}

Future<ConcreteDataDomain> _addConcrete(_Env env, String uid) async {
  final ConcreteDataDomain? created = await env.concrete.create(
    ConcreteDataDomain(
      id: 0,
      uid: uid,
      extensionUid: 'ext',
      title: 'Title $uid',
      createdAt: DateTime(2024),
    ),
  );
  return created!;
}

Future<void> _addChapterActivity(
  _Env env,
  int concreteId,
  String uid, {
  int readPages = 5,
}) async {
  await env.chapters.create(
    ChapterActivityDomain(
      id: 0,
      uid: uid,
      concreteId: concreteId,
      title: 'Chapter $uid',
      timestamp: null,
      data: null,
      readPages: readPages,
      totalPages: 10,
      createdAt: DateTime(2024),
    ),
  );
}

ExportBundle _roundTrip(ExportBundle bundle) =>
    ExportBundle.fromJson(jsonDecode(jsonEncode(bundle.toJson())));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('activities survive import when concrete row ids differ', () async {
    final _Env source = _Env();
    final ConcreteDataDomain a = await _addConcrete(source, 'manga-a');
    final ConcreteDataDomain b = await _addConcrete(source, 'manga-b');
    await _addChapterActivity(source, a.id, 'ch-a', readPages: 3);
    await _addChapterActivity(source, b.id, 'ch-b', readPages: 7);

    final ExportBundle bundle = _roundTrip(
      await source.service.buildExport(<ExportSection>{ExportSection.history}),
    );
    await source.dispose();

    final _Env target = _Env();
    // Shift ids so 'manga-a' cannot land on the same numeric id as before.
    await _addConcrete(target, 'decoy-1');
    await _addConcrete(target, 'decoy-2');
    await _addConcrete(target, 'decoy-3');

    final ImportResult result = await target.service
        .applyImport(bundle, <ExportSection>{ExportSection.history});

    expect(result.imported, 2);
    expect(result.skipped, 0);

    final ConcreteDataDomain? importedA =
        await target.concrete.getByUid('manga-a');
    final ConcreteDataDomain? importedB =
        await target.concrete.getByUid('manga-b');
    expect(importedA!.id, isNot(a.id));

    final List<ChapterActivityDomain> activities =
        await target.chapters.getAll();
    expect(activities.length, 2);

    final ChapterActivityDomain chA =
        activities.firstWhere((ChapterActivityDomain x) => x.uid == 'ch-a');
    final ChapterActivityDomain chB =
        activities.firstWhere((ChapterActivityDomain x) => x.uid == 'ch-b');

    expect(chA.concreteId, importedA.id);
    expect(chB.concreteId, importedB!.id);
    expect(chA.readPages, 3);
    expect(chB.readPages, 7);

    await target.dispose();
  });

  test('an activity whose concrete is missing is skipped, not mis-attached',
      () async {
    final _Env source = _Env();
    final ConcreteDataDomain a = await _addConcrete(source, 'manga-a');
    await _addChapterActivity(source, a.id, 'ch-a');

    final ExportBundle full =
        await source.service.buildExport(<ExportSection>{ExportSection.history});
    await source.dispose();

    final ExportBundle withoutConcrete = ExportBundle(
      version: full.version,
      exportedAt: full.exportedAt,
      concreteData: const <ExportConcrete>[],
      mangaChapterActivities: full.mangaChapterActivities,
      animeEpisodeActivities: full.animeEpisodeActivities,
    );

    final _Env target = _Env();
    await _addConcrete(target, 'unrelated');

    final ImportResult result = await target.service
        .applyImport(withoutConcrete, <ExportSection>{ExportSection.history});

    expect(result.imported, 0);
    expect(result.skipped, 1);
    expect(await target.chapters.getAll(), isEmpty);

    await target.dispose();
  });

  test('library entries keep their category by name', () async {
    final _Env source = _Env();
    final CategoryDomain? reading = await source.categories.create(
      CategoryDomain(
          id: 0, name: 'Reading', sortOrder: 0, createdAt: DateTime(2024)),
    );
    await source.library.create(
      LibraryEntryDomain(
        id: 0,
        uid: 'lib-1',
        extensionUid: 'ext',
        title: 'Fav',
        categoryId: reading!.id,
        createdAt: DateTime(2024),
      ),
    );

    final ExportBundle bundle = _roundTrip(await source.service.buildExport(
      <ExportSection>{ExportSection.library, ExportSection.categories},
    ));
    await source.dispose();

    final _Env target = _Env();
    await target.categories.create(
      CategoryDomain(
          id: 0, name: 'Decoy', sortOrder: 0, createdAt: DateTime(2024)),
    );

    await target.service.applyImport(
      bundle,
      <ExportSection>{ExportSection.library, ExportSection.categories},
    );

    final CategoryDomain? importedCategory =
        (await target.categories.getAll())
            .where((CategoryDomain c) => c.name == 'Reading')
            .firstOrNull;
    expect(importedCategory, isNotNull);
    expect(importedCategory!.id, isNot(reading.id));

    final LibraryEntryDomain? entry = await target.library.getByUid('lib-1');
    expect(entry, isNotNull);
    expect(entry!.categoryId, importedCategory.id);

    await target.dispose();
  });

  test('settings round-trip through export and import', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsService settings = SettingsService();
    await settings.setThemeId(AppThemeId.sakura);
    await settings.setDefaultReaderMode(ChapterViewMode.webtoon);
    await settings.setShowNsfw(true);
    await settings.setCollectStatistics(false);

    final _Env source = _Env();
    final ExportBundle bundle = _roundTrip(
      await source.service.buildExport(<ExportSection>{ExportSection.settings}),
    );
    await source.dispose();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _Env target = _Env();
    await target.service
        .applyImport(bundle, <ExportSection>{ExportSection.settings});

    final SettingsService restored = SettingsService();
    expect(await restored.getThemeId(), AppThemeId.sakura);
    expect(await restored.getDefaultReaderMode(), ChapterViewMode.webtoon);
    expect(await restored.getShowNsfw(), isTrue);
    expect(await restored.getCollectStatistics(), isFalse);

    await target.dispose();
  });

  test('only the selected sections are exported', () async {
    final _Env env = _Env();
    await _addConcrete(env, 'manga-a');

    final ExportBundle bundle = await env.service
        .buildExport(<ExportSection>{ExportSection.settings});

    expect(bundle.concreteData, isNull);
    expect(bundle.mangaChapterActivities, isNull);
    expect(bundle.libraryEntries, isNull);
    expect(bundle.settings, isNotNull);
    expect(bundle.availableSections, <ExportSection>{ExportSection.settings});

    await env.dispose();
  });
}
