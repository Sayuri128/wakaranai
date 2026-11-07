import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
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
      database: db,
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

  test('import reports progress that ends at the item count', () async {
    final _Env source = _Env();
    final ConcreteDataDomain a = await _addConcrete(source, 'manga-a');
    await _addChapterActivity(source, a.id, 'ch-1');
    await _addChapterActivity(source, a.id, 'ch-2');

    final ExportBundle bundle = _roundTrip(
      await source.service.buildExport(<ExportSection>{ExportSection.history}),
    );
    await source.dispose();

    final _Env target = _Env();
    final List<ImportExportProgress> seen = <ImportExportProgress>[];

    final int expected = target.service
        .countImportItems(bundle, <ExportSection>{ExportSection.history});
    expect(expected, 3);

    await target.service.applyImport(
      bundle,
      <ExportSection>{ExportSection.history},
      onProgress: seen.add,
    );

    expect(seen.first.processed, 0);
    expect(seen.last.processed, expected);
    expect(seen.last.total, expected);
    expect(seen.last.value, 1.0);
    expect(seen.every((ImportExportProgress p) => !p.exporting), isTrue);
    expect(
      seen.map((ImportExportProgress p) => p.processed).toList(),
      <int>[0, 1, 2, 3],
    );

    await target.dispose();
  });

  test('export reports one step per selected section', () async {
    final _Env env = _Env();
    await _addConcrete(env, 'manga-a');

    final List<ImportExportProgress> seen = <ImportExportProgress>[];
    const Set<ExportSection> sections = <ExportSection>{
      ExportSection.history,
      ExportSection.settings,
    };

    await env.service.buildExport(sections, onProgress: seen.add);

    expect(seen.every((ImportExportProgress p) => p.exporting), isTrue);
    expect(seen.every((ImportExportProgress p) => p.total == 2), isTrue);
    expect(seen.last.processed, 2);
    expect(seen.last.value, 1.0);
    expect(
      seen.map((ImportExportProgress p) => p.section).contains(
            ExportSection.history,
          ),
      isTrue,
    );

    await env.dispose();
  });

  test('progress value is null when there is nothing to do', () async {
    final _Env env = _Env();
    final List<ImportExportProgress> seen = <ImportExportProgress>[];

    await env.service.applyImport(
      ExportBundle(version: 2, exportedAt: DateTime(2024)),
      <ExportSection>{ExportSection.history},
      onProgress: seen.add,
    );

    expect(seen.single.total, 0);
    expect(seen.single.value, isNull);

    await env.dispose();
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

  test('page translations round-trip and overwrite by uid', () async {
    final _Env source = _Env();
    await source.db.pageTranslationTable.insert().insert(
          PageTranslationTableCompanion.insert(
            uid: 'mlkit+mlkit@v8|en|uk|/page/1.png',
            pagePath: '/page/1.png',
            engine: 'mlkit+mlkit@v8',
            sourceLanguage: 'en',
            targetLanguage: 'uk',
            resultJson: '{"width":1,"height":1,"bubbles":[]}',
          ),
        );

    final ExportBundle bundle = await source.service
        .buildExport(<ExportSection>{ExportSection.translations});
    expect(bundle.pageTranslations, hasLength(1));
    expect(bundle.availableSections,
        <ExportSection>{ExportSection.translations});

    final ExportBundle decoded = ExportBundle.fromJson(
        jsonDecode(jsonEncode(bundle.toJson())) as Map<String, dynamic>);

    final _Env target = _Env();
    await target.service
        .applyImport(decoded, <ExportSection>{ExportSection.translations});
    await target.service
        .applyImport(decoded, <ExportSection>{ExportSection.translations});

    final List<PageTranslationTableData> rows =
        await target.db.pageTranslationTable.select().get();
    expect(rows, hasLength(1));
    expect(rows.single.engine, 'mlkit+mlkit@v8');
    expect(rows.single.resultJson, '{"width":1,"height":1,"bubbles":[]}');

    await source.dispose();
    await target.dispose();
  });

  test('backups without page translations still import', () async {
    final ExportBundle bundle = ExportBundle.fromJson(<String, dynamic>{
      'version': 2,
      'exportedAt': DateTime(2026).toIso8601String(),
    });

    expect(bundle.pageTranslations, isNull);
    expect(bundle.hasSection(ExportSection.translations), isFalse);
  });

  test('player preferences round-trip with their value types', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'PLAYER_PLAYBACK_SPEED': 1.5,
      'PLAYER_HOLD_SPEED': 2.0,
      'PLAYER_SKIP_OPENING_SECONDS': 85,
      'PLAYER_AUTO_PLAY_NEXT': false,
      'PLAYER_SUBTITLE': 'en',
      'PLAYER_RECENT_TRACKS': <String>['ja', 'en'],
      'VIDEO_PLAYER_PREFERENCE': 'native',
      'GALLERY_LAYOUT': 'list',
      'PAGE_TRANSLATION_TARGET': 'de',
      'SOURCE_ATTENTION_NOTIFIED_AT_mangalib': 123,
      'AUTO_BACKUP_LAST_AT': 456,
      'default_extension_id': 7,
    });

    final _Env source = _Env();
    final ExportBundle bundle = _roundTrip(
      await source.service.buildExport(<ExportSection>{ExportSection.settings}),
    );
    await source.dispose();

    final List<String> exportedKeys = bundle.settings!.preferences!
        .map((ExportPreference entry) => entry.key)
        .toList();
    expect(exportedKeys, isNot(contains('SOURCE_ATTENTION_NOTIFIED_AT_mangalib')));
    expect(exportedKeys, isNot(contains('AUTO_BACKUP_LAST_AT')));
    expect(exportedKeys, isNot(contains('default_extension_id')));

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _Env target = _Env();
    await target.service
        .applyImport(bundle, <ExportSection>{ExportSection.settings});

    final SharedPreferences restored = await SharedPreferences.getInstance();
    expect(restored.get('PLAYER_PLAYBACK_SPEED'), isA<double>());
    expect(restored.getDouble('PLAYER_PLAYBACK_SPEED'), 1.5);
    expect(restored.get('PLAYER_HOLD_SPEED'), isA<double>());
    expect(restored.getDouble('PLAYER_HOLD_SPEED'), 2.0);
    expect(restored.get('PLAYER_SKIP_OPENING_SECONDS'), isA<int>());
    expect(restored.getInt('PLAYER_SKIP_OPENING_SECONDS'), 85);
    expect(restored.getBool('PLAYER_AUTO_PLAY_NEXT'), isFalse);
    expect(restored.getString('PLAYER_SUBTITLE'), 'en');
    expect(restored.getStringList('PLAYER_RECENT_TRACKS'), <String>['ja', 'en']);
    expect(restored.getString('VIDEO_PLAYER_PREFERENCE'), 'native');
    expect(restored.getString('GALLERY_LAYOUT'), 'list');
    expect(restored.getString('PAGE_TRANSLATION_TARGET'), 'de');
    expect(restored.containsKey('SOURCE_ATTENTION_NOTIFIED_AT_mangalib'),
        isFalse);
    expect(restored.containsKey('AUTO_BACKUP_LAST_AT'), isFalse);
    expect(restored.containsKey('default_extension_id'), isFalse);

    await target.dispose();
  });

  test('settings from a bundle without preferences keep local player settings',
      () async {
    final ExportBundle bundle = ExportBundle.fromJson(<String, dynamic>{
      'version': 2,
      'exportedAt': DateTime(2026).toIso8601String(),
      'settings': <String, dynamic>{
        'themeId': AppThemeId.sakura.name,
        'showNsfw': true,
      },
    });
    expect(bundle.settings!.preferences, isNull);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'PLAYER_PLAYBACK_SPEED': 1.25,
    });
    final _Env target = _Env();
    final ImportResult result = await target.service
        .applyImport(bundle, <ExportSection>{ExportSection.settings});

    expect(result.imported, 1);
    final SharedPreferences restored = await SharedPreferences.getInstance();
    expect(restored.getDouble('PLAYER_PLAYBACK_SPEED'), 1.25);
    expect(await SettingsService().getThemeId(), AppThemeId.sakura);

    await target.dispose();
  });

  test('unknown keys, types and preference names are ignored on import',
      () async {
    final ExportBundle bundle = ExportBundle.fromJson(
      jsonDecode(jsonEncode(<String, dynamic>{
        'version': 3,
        'exportedAt': DateTime(2026).toIso8601String(),
        'someFutureSection': <String>['x'],
        'settings': <String, dynamic>{
          'someFutureSetting': 42,
          'preferences': <Map<String, dynamic>>[
            <String, dynamic>{
              'key': 'PLAYER_HOLD_SPEED',
              'type': 'double',
              'value': 3,
            },
            <String, dynamic>{
              'key': 'PLAYER_FUTURE_OPTION',
              'type': 'someFutureType',
              'value': <String, dynamic>{'a': 1},
            },
            <String, dynamic>{
              'key': 'PLAYER_QUALITY',
              'type': 'int',
              'value': 'not a number',
            },
            <String, dynamic>{
              'key': 'APP_THEME_ID',
              'type': 'string',
              'value': 'sakura',
            },
            <String, dynamic>{
              'key': 'SOURCE_ATTENTION_NOTIFIED_AT_mangalib',
              'type': 'int',
              'value': 1,
            },
          ],
        },
      })) as Map<String, dynamic>,
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _Env target = _Env();
    await target.service
        .applyImport(bundle, <ExportSection>{ExportSection.settings});

    final SharedPreferences restored = await SharedPreferences.getInstance();
    expect(restored.get('PLAYER_HOLD_SPEED'), isA<double>());
    expect(restored.getDouble('PLAYER_HOLD_SPEED'), 3.0);
    expect(restored.containsKey('PLAYER_FUTURE_OPTION'), isFalse);
    expect(restored.containsKey('PLAYER_QUALITY'), isFalse);
    expect(restored.containsKey('APP_THEME_ID'), isFalse);
    expect(restored.containsKey('SOURCE_ATTENTION_NOTIFIED_AT_mangalib'),
        isFalse);

    await target.dispose();
  });
}
