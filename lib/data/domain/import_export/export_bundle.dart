import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_bundle.g.dart';

enum ExportSection { history, library, categories, sources, settings }

String encodeExportSections(Set<ExportSection> sections) =>
    sections.map((ExportSection s) => s.name).join(',');

Set<ExportSection> decodeExportSections(String raw) => raw
    .split(',')
    .map((String name) => ExportSection.values
        .firstWhereOrNull((ExportSection s) => s.name == name))
    .whereType<ExportSection>()
    .toSet();

@JsonSerializable(explicitToJson: true)
class ExportBundle {
  final int version;
  final DateTime exportedAt;

  final List<ExportConcrete>? concreteData;
  final List<ExportChapterActivity>? mangaChapterActivities;
  final List<ExportAnimeEpisodeActivity>? animeEpisodeActivities;
  final List<ExportCategory>? categories;
  final List<ExportLibraryEntry>? libraryEntries;
  final List<ExportExtensionSource>? extensionSources;
  final ExportSettings? settings;

  const ExportBundle({
    required this.version,
    required this.exportedAt,
    this.concreteData,
    this.mangaChapterActivities,
    this.animeEpisodeActivities,
    this.categories,
    this.libraryEntries,
    this.extensionSources,
    this.settings,
  });

  factory ExportBundle.fromJson(Map<String, dynamic> json) =>
      _$ExportBundleFromJson(json);

  Map<String, dynamic> toJson() => _$ExportBundleToJson(this);

  bool hasSection(ExportSection section) {
    switch (section) {
      case ExportSection.history:
        return (mangaChapterActivities?.isNotEmpty ?? false) ||
            (animeEpisodeActivities?.isNotEmpty ?? false);
      case ExportSection.library:
        return libraryEntries?.isNotEmpty ?? false;
      case ExportSection.categories:
        return categories?.isNotEmpty ?? false;
      case ExportSection.sources:
        return extensionSources?.isNotEmpty ?? false;
      case ExportSection.settings:
        return settings != null;
    }
  }

  Set<ExportSection> get availableSections => ExportSection.values
      .where((ExportSection s) => hasSection(s))
      .toSet();
}

@JsonSerializable()
class ExportConcrete {
  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final String? concreteJson;
  final DateTime createdAt;

  const ExportConcrete({
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.concreteJson,
    required this.createdAt,
  });

  factory ExportConcrete.fromJson(Map<String, dynamic> json) =>
      _$ExportConcreteFromJson(json);

  Map<String, dynamic> toJson() => _$ExportConcreteToJson(this);
}

@JsonSerializable()
class ExportChapterActivity {
  final String uid;
  final String concreteUid;
  final String title;
  final String? timestamp;
  final String? data;
  final int readPages;
  final int totalPages;
  final DateTime createdAt;

  const ExportChapterActivity({
    required this.uid,
    required this.concreteUid,
    required this.title,
    this.timestamp,
    this.data,
    required this.readPages,
    required this.totalPages,
    required this.createdAt,
  });

  factory ExportChapterActivity.fromJson(Map<String, dynamic> json) =>
      _$ExportChapterActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ExportChapterActivityToJson(this);
}

@JsonSerializable()
class ExportAnimeEpisodeActivity {
  final String uid;
  final String concreteUid;
  final String title;
  final String? timestamp;
  final String? data;
  final int? watchedTime;
  final int? totalTime;
  final DateTime createdAt;

  const ExportAnimeEpisodeActivity({
    required this.uid,
    required this.concreteUid,
    required this.title,
    this.timestamp,
    this.data,
    this.watchedTime,
    this.totalTime,
    required this.createdAt,
  });

  factory ExportAnimeEpisodeActivity.fromJson(Map<String, dynamic> json) =>
      _$ExportAnimeEpisodeActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ExportAnimeEpisodeActivityToJson(this);
}

@JsonSerializable()
class ExportCategory {
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  const ExportCategory({
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ExportCategory.fromJson(Map<String, dynamic> json) =>
      _$ExportCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ExportCategoryToJson(this);
}

@JsonSerializable()
class ExportLibraryEntry {
  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final String? categoryName;
  final DateTime? lastReadAt;
  final DateTime createdAt;

  const ExportLibraryEntry({
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.categoryName,
    this.lastReadAt,
    required this.createdAt,
  });

  factory ExportLibraryEntry.fromJson(Map<String, dynamic> json) =>
      _$ExportLibraryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ExportLibraryEntryToJson(this);
}

@JsonSerializable()
class ExportExtensionSource {
  final String name;
  final String url;
  final String type;
  final DateTime createdAt;

  const ExportExtensionSource({
    required this.name,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  factory ExportExtensionSource.fromJson(Map<String, dynamic> json) =>
      _$ExportExtensionSourceFromJson(json);

  Map<String, dynamic> toJson() => _$ExportExtensionSourceToJson(this);
}

@JsonSerializable()
class ExportSettings {
  final String? themeId;
  final String? defaultReaderMode;
  final bool? showNsfw;
  final bool? collectStatistics;

  const ExportSettings({
    this.themeId,
    this.defaultReaderMode,
    this.showNsfw,
    this.collectStatistics,
  });

  factory ExportSettings.fromJson(Map<String, dynamic> json) =>
      _$ExportSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ExportSettingsToJson(this);
}
