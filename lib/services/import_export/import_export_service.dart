import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/extension_source_domain.dart';
import 'package:wakaranai/data/domain/database/extension_source_type.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_palette.dart';
import 'package:wakaranai/utils/enum_converters.dart';

class ImportResult {
  final int imported;
  final int total;
  final int skipped;

  const ImportResult({
    required this.imported,
    required this.total,
    required this.skipped,
  });
}

class ImportExportService {
  ImportExportService({
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
    required this.animeEpisodeActivityRepository,
    required this.categoryRepository,
    required this.libraryEntryRepository,
    required this.extensionSourceRepository,
    SettingsService? settingsService,
  }) : settingsService = settingsService ?? SettingsService();

  static const int exportVersion = 2;

  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;
  final CategoryRepository categoryRepository;
  final LibraryEntryRepository libraryEntryRepository;
  final ExtensionSourceRepository extensionSourceRepository;
  final SettingsService settingsService;

  Future<ExportBundle> buildExport(Set<ExportSection> sections) async {
    List<ExportConcrete>? concreteData;
    List<ExportChapterActivity>? chapterActivities;
    List<ExportAnimeEpisodeActivity>? episodeActivities;
    List<ExportCategory>? categories;
    List<ExportLibraryEntry>? libraryEntries;
    List<ExportExtensionSource>? extensionSources;
    ExportSettings? settings;

    if (sections.contains(ExportSection.history)) {
      final List<ConcreteDataDomain> concretes =
          await concreteDataRepository.getAll();
      final Map<int, String> uidById = <int, String>{
        for (final ConcreteDataDomain c in concretes) c.id: c.uid,
      };

      concreteData = concretes
          .map((ConcreteDataDomain c) => ExportConcrete(
                uid: c.uid,
                extensionUid: c.extensionUid,
                title: c.title,
                cover: c.cover,
                data: c.data,
                concreteJson: c.concreteJson,
                createdAt: c.createdAt,
              ))
          .toList();

      chapterActivities = (await chapterActivityRepository.getAll())
          .where((ChapterActivityDomain a) => uidById.containsKey(a.concreteId))
          .map((ChapterActivityDomain a) => ExportChapterActivity(
                uid: a.uid,
                concreteUid: uidById[a.concreteId]!,
                title: a.title,
                timestamp: a.timestamp,
                data: a.data,
                readPages: a.readPages,
                totalPages: a.totalPages,
                createdAt: a.createdAt,
              ))
          .toList();

      episodeActivities = (await animeEpisodeActivityRepository.getAll())
          .where((AnimeEpisodeActivityDomain a) =>
              uidById.containsKey(a.concreteId))
          .map((AnimeEpisodeActivityDomain a) => ExportAnimeEpisodeActivity(
                uid: a.uid,
                concreteUid: uidById[a.concreteId]!,
                title: a.title,
                timestamp: a.timestamp,
                data: a.data,
                watchedTime: a.watchedTime,
                totalTime: a.totalTime,
                createdAt: a.createdAt,
              ))
          .toList();
    }

    final List<CategoryDomain> allCategories = await categoryRepository.getAll();

    if (sections.contains(ExportSection.categories)) {
      categories = allCategories
          .map((CategoryDomain c) => ExportCategory(
                name: c.name,
                sortOrder: c.sortOrder,
                createdAt: c.createdAt,
              ))
          .toList();
    }

    if (sections.contains(ExportSection.library)) {
      final Map<int, String> categoryNameById = <int, String>{
        for (final CategoryDomain c in allCategories) c.id: c.name,
      };

      libraryEntries = (await libraryEntryRepository.getAll())
          .map((LibraryEntryDomain e) => ExportLibraryEntry(
                uid: e.uid,
                extensionUid: e.extensionUid,
                title: e.title,
                cover: e.cover,
                data: e.data,
                categoryName: categoryNameById[e.categoryId],
                lastReadAt: e.lastReadAt,
                createdAt: e.createdAt,
              ))
          .toList();
    }

    if (sections.contains(ExportSection.sources)) {
      extensionSources = (await extensionSourceRepository.getAll())
          .map((ExtensionSourceDomain s) => ExportExtensionSource(
                name: s.name,
                url: s.url,
                type: encodeEnum(s.type),
                createdAt: s.createdAt,
              ))
          .toList();
    }

    if (sections.contains(ExportSection.settings)) {
      settings = ExportSettings(
        themeId: (await settingsService.getThemeId()).name,
        defaultReaderMode: (await settingsService.getDefaultReaderMode()).name,
        showNsfw: await settingsService.getShowNsfw(),
        collectStatistics: await settingsService.getCollectStatistics(),
      );
    }

    return ExportBundle(
      version: exportVersion,
      exportedAt: DateTime.now(),
      concreteData: concreteData,
      mangaChapterActivities: chapterActivities,
      animeEpisodeActivities: episodeActivities,
      categories: categories,
      libraryEntries: libraryEntries,
      extensionSources: extensionSources,
      settings: settings,
    );
  }

  Future<ImportResult> applyImport(
    ExportBundle bundle,
    Set<ExportSection> sections,
  ) async {
    int imported = 0;
    int total = 0;
    int skipped = 0;

    Map<String, int> concreteIdByUid = <String, int>{};

    if (sections.contains(ExportSection.history)) {
      concreteIdByUid = await _importConcreteData(bundle.concreteData);

      final List<ExportChapterActivity> chapters =
          bundle.mangaChapterActivities ?? <ExportChapterActivity>[];
      final List<ExportAnimeEpisodeActivity> episodes =
          bundle.animeEpisodeActivities ?? <ExportAnimeEpisodeActivity>[];
      total += chapters.length + episodes.length;

      for (final ExportChapterActivity activity in chapters) {
        final int? concreteId =
            await _resolveConcreteId(activity.concreteUid, concreteIdByUid);
        if (concreteId == null) {
          skipped++;
          continue;
        }
        await _upsertChapterActivity(activity, concreteId);
        imported++;
      }

      for (final ExportAnimeEpisodeActivity activity in episodes) {
        final int? concreteId =
            await _resolveConcreteId(activity.concreteUid, concreteIdByUid);
        if (concreteId == null) {
          skipped++;
          continue;
        }
        await _upsertEpisodeActivity(activity, concreteId);
        imported++;
      }
    }

    Map<String, int> categoryIdByName = <String, int>{};

    if (sections.contains(ExportSection.categories)) {
      final List<ExportCategory> categories =
          bundle.categories ?? <ExportCategory>[];
      total += categories.length;
      categoryIdByName = await _importCategories(categories);
      imported += categories.length;
    }

    if (sections.contains(ExportSection.library)) {
      final List<ExportLibraryEntry> entries =
          bundle.libraryEntries ?? <ExportLibraryEntry>[];
      total += entries.length;

      for (final ExportLibraryEntry entry in entries) {
        await _upsertLibraryEntry(entry, categoryIdByName);
        imported++;
      }
    }

    if (sections.contains(ExportSection.sources)) {
      final List<ExportExtensionSource> sources =
          bundle.extensionSources ?? <ExportExtensionSource>[];
      total += sources.length;

      for (final ExportExtensionSource source in sources) {
        await _upsertExtensionSource(source);
        imported++;
      }
    }

    if (sections.contains(ExportSection.settings) && bundle.settings != null) {
      total += 1;
      await _applySettings(bundle.settings!);
      imported += 1;
    }

    return ImportResult(imported: imported, total: total, skipped: skipped);
  }

  Future<Map<String, int>> _importConcreteData(
      List<ExportConcrete>? concretes) async {
    final Map<String, int> byUid = <String, int>{};
    for (final ExportConcrete concrete in concretes ?? <ExportConcrete>[]) {
      final ConcreteDataDomain? saved = await concreteDataRepository
          .createUpdateBy<$ConcreteDataTableTable, String>(
        ConcreteDataDomain(
          id: 0,
          uid: concrete.uid,
          extensionUid: concrete.extensionUid,
          title: concrete.title,
          cover: concrete.cover,
          data: concrete.data,
          concreteJson: concrete.concreteJson,
          createdAt: concrete.createdAt,
        ),
        by: (ConcreteDataDomain d) => d.uid,
        where: (tbl) => tbl.uid,
      );
      if (saved != null) {
        byUid[concrete.uid] = saved.id;
      }
    }
    return byUid;
  }

  Future<int?> _resolveConcreteId(
      String concreteUid, Map<String, int> byUid) async {
    final int? cached = byUid[concreteUid];
    if (cached != null) return cached;

    final ConcreteDataDomain? existing =
        await concreteDataRepository.getByUid(concreteUid);
    if (existing == null) return null;

    byUid[concreteUid] = existing.id;
    return existing.id;
  }

  Future<void> _upsertChapterActivity(
      ExportChapterActivity activity, int concreteId) async {
    final ChapterActivityDomain domain = ChapterActivityDomain(
      id: 0,
      uid: activity.uid,
      concreteId: concreteId,
      title: activity.title,
      timestamp: activity.timestamp,
      data: activity.data,
      readPages: activity.readPages,
      totalPages: activity.totalPages,
      createdAt: activity.createdAt,
    );

    final ChapterActivityDomain? existing = await chapterActivityRepository
        .getByComplex<$ChapterActivityTableTable>(
      <dynamic>[concreteId, activity.uid],
      where: (tbl) => <GeneratedColumn>[tbl.concreteId, tbl.uid],
    );

    if (existing == null) {
      await chapterActivityRepository.create(domain);
    } else {
      domain.id = existing.id;
      await chapterActivityRepository.update(domain, update: false);
    }
  }

  Future<void> _upsertEpisodeActivity(
      ExportAnimeEpisodeActivity activity, int concreteId) async {
    final AnimeEpisodeActivityDomain domain = AnimeEpisodeActivityDomain(
      id: 0,
      uid: activity.uid,
      concreteId: concreteId,
      title: activity.title,
      timestamp: activity.timestamp,
      data: activity.data,
      watchedTime: activity.watchedTime,
      totalTime: activity.totalTime,
      createdAt: activity.createdAt,
    );

    final AnimeEpisodeActivityDomain? existing =
        await animeEpisodeActivityRepository
            .getByComplex<$AnimeEpisodeActivityTableTable>(
      <dynamic>[concreteId, activity.uid],
      where: (tbl) => <GeneratedColumn>[tbl.concreteId, tbl.uid],
    );

    if (existing == null) {
      await animeEpisodeActivityRepository.create(domain);
    } else {
      domain.id = existing.id;
      await animeEpisodeActivityRepository.update(domain, update: false);
    }
  }

  Future<Map<String, int>> _importCategories(
      List<ExportCategory> categories) async {
    final Map<String, int> byName = <String, int>{};

    for (final ExportCategory category in categories) {
      final CategoryDomain? existing = await categoryRepository
          .getBy<$CategoryTableTable>(category.name, where: (tbl) => tbl.name);

      if (existing != null) {
        byName[category.name] = existing.id;
        continue;
      }

      final CategoryDomain? created = await categoryRepository.create(
        CategoryDomain(
          id: 0,
          name: category.name,
          sortOrder: category.sortOrder,
          createdAt: category.createdAt,
        ),
      );
      if (created != null) {
        byName[category.name] = created.id;
      }
    }

    return byName;
  }

  Future<void> _upsertLibraryEntry(
      ExportLibraryEntry entry, Map<String, int> categoryIdByName) async {
    int? categoryId = entry.categoryName != null
        ? categoryIdByName[entry.categoryName]
        : null;

    if (categoryId == null && entry.categoryName != null) {
      final CategoryDomain? existing =
          await categoryRepository.getBy<$CategoryTableTable>(
        entry.categoryName,
        where: (tbl) => tbl.name,
      );
      categoryId = existing?.id;
    }

    final LibraryEntryDomain domain = LibraryEntryDomain(
      id: 0,
      uid: entry.uid,
      extensionUid: entry.extensionUid,
      title: entry.title,
      cover: entry.cover,
      data: entry.data,
      categoryId: categoryId,
      lastReadAt: entry.lastReadAt,
      createdAt: entry.createdAt,
    );

    final LibraryEntryDomain? existing =
        await libraryEntryRepository.getByUid(entry.uid);

    if (existing == null) {
      await libraryEntryRepository.create(domain);
    } else {
      domain.id = existing.id;
      await libraryEntryRepository.update(domain, update: false);
    }
  }

  Future<void> _upsertExtensionSource(ExportExtensionSource source) async {
    final ExtensionSourceDomain? existing = await extensionSourceRepository
        .getBy<$ExtensionSourceTableTable>(source.url, where: (tbl) => tbl.url);
    if (existing != null) return;

    await extensionSourceRepository.create(
      ExtensionSourceDomain(
        id: 0,
        name: source.name,
        url: source.url,
        type: decodeEnum(ExtensionSourceType.values, source.type) ??
            ExtensionSourceType.github,
        createdAt: source.createdAt,
        updatedAt: null,
      ),
    );
  }

  Future<void> _applySettings(ExportSettings settings) async {
    final String? themeId = settings.themeId;
    if (themeId != null) {
      final AppThemeId? id = AppThemeId.values
          .firstWhereOrNull((AppThemeId t) => t.name == themeId);
      if (id != null) {
        await settingsService.setThemeId(id);
      }
    }

    final String? readerMode = settings.defaultReaderMode;
    if (readerMode != null) {
      final ChapterViewMode? mode = ChapterViewMode.values
          .firstWhereOrNull((ChapterViewMode m) => m.name == readerMode);
      if (mode != null) {
        await settingsService.setDefaultReaderMode(mode);
      }
    }

    if (settings.showNsfw != null) {
      await settingsService.setShowNsfw(settings.showNsfw!);
    }
    if (settings.collectStatistics != null) {
      await settingsService.setCollectStatistics(settings.collectStatistics!);
    }
  }
}
