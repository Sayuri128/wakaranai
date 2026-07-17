// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportBundle _$ExportBundleFromJson(Map json) => ExportBundle(
  version: (json['version'] as num).toInt(),
  exportedAt: DateTime.parse(json['exportedAt'] as String),
  concreteData: (json['concreteData'] as List<dynamic>?)
      ?.map((e) => ExportConcrete.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  mangaChapterActivities: (json['mangaChapterActivities'] as List<dynamic>?)
      ?.map(
        (e) =>
            ExportChapterActivity.fromJson(Map<String, dynamic>.from(e as Map)),
      )
      .toList(),
  animeEpisodeActivities: (json['animeEpisodeActivities'] as List<dynamic>?)
      ?.map(
        (e) => ExportAnimeEpisodeActivity.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
      .toList(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => ExportCategory.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  libraryEntries: (json['libraryEntries'] as List<dynamic>?)
      ?.map(
        (e) => ExportLibraryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
      )
      .toList(),
  extensionSources: (json['extensionSources'] as List<dynamic>?)
      ?.map(
        (e) =>
            ExportExtensionSource.fromJson(Map<String, dynamic>.from(e as Map)),
      )
      .toList(),
  settings: json['settings'] == null
      ? null
      : ExportSettings.fromJson(
          Map<String, dynamic>.from(json['settings'] as Map),
        ),
);

Map<String, dynamic> _$ExportBundleToJson(
  ExportBundle instance,
) => <String, dynamic>{
  'version': instance.version,
  'exportedAt': instance.exportedAt.toIso8601String(),
  'concreteData': instance.concreteData?.map((e) => e.toJson()).toList(),
  'mangaChapterActivities': instance.mangaChapterActivities
      ?.map((e) => e.toJson())
      .toList(),
  'animeEpisodeActivities': instance.animeEpisodeActivities
      ?.map((e) => e.toJson())
      .toList(),
  'categories': instance.categories?.map((e) => e.toJson()).toList(),
  'libraryEntries': instance.libraryEntries?.map((e) => e.toJson()).toList(),
  'extensionSources': instance.extensionSources
      ?.map((e) => e.toJson())
      .toList(),
  'settings': instance.settings?.toJson(),
};

ExportConcrete _$ExportConcreteFromJson(Map json) => ExportConcrete(
  uid: json['uid'] as String,
  extensionUid: json['extensionUid'] as String,
  title: json['title'] as String,
  cover: json['cover'] as String?,
  data: json['data'] as String?,
  concreteJson: json['concreteJson'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExportConcreteToJson(ExportConcrete instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'extensionUid': instance.extensionUid,
      'title': instance.title,
      'cover': instance.cover,
      'data': instance.data,
      'concreteJson': instance.concreteJson,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ExportChapterActivity _$ExportChapterActivityFromJson(Map json) =>
    ExportChapterActivity(
      uid: json['uid'] as String,
      concreteUid: json['concreteUid'] as String,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String?,
      data: json['data'] as String?,
      readPages: (json['readPages'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExportChapterActivityToJson(
  ExportChapterActivity instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'concreteUid': instance.concreteUid,
  'title': instance.title,
  'timestamp': instance.timestamp,
  'data': instance.data,
  'readPages': instance.readPages,
  'totalPages': instance.totalPages,
  'createdAt': instance.createdAt.toIso8601String(),
};

ExportAnimeEpisodeActivity _$ExportAnimeEpisodeActivityFromJson(Map json) =>
    ExportAnimeEpisodeActivity(
      uid: json['uid'] as String,
      concreteUid: json['concreteUid'] as String,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String?,
      data: json['data'] as String?,
      watchedTime: (json['watchedTime'] as num?)?.toInt(),
      totalTime: (json['totalTime'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExportAnimeEpisodeActivityToJson(
  ExportAnimeEpisodeActivity instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'concreteUid': instance.concreteUid,
  'title': instance.title,
  'timestamp': instance.timestamp,
  'data': instance.data,
  'watchedTime': instance.watchedTime,
  'totalTime': instance.totalTime,
  'createdAt': instance.createdAt.toIso8601String(),
};

ExportCategory _$ExportCategoryFromJson(Map json) => ExportCategory(
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExportCategoryToJson(ExportCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ExportLibraryEntry _$ExportLibraryEntryFromJson(Map json) => ExportLibraryEntry(
  uid: json['uid'] as String,
  extensionUid: json['extensionUid'] as String,
  title: json['title'] as String,
  cover: json['cover'] as String?,
  data: json['data'] as String?,
  categoryName: json['categoryName'] as String?,
  lastReadAt: json['lastReadAt'] == null
      ? null
      : DateTime.parse(json['lastReadAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExportLibraryEntryToJson(ExportLibraryEntry instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'extensionUid': instance.extensionUid,
      'title': instance.title,
      'cover': instance.cover,
      'data': instance.data,
      'categoryName': instance.categoryName,
      'lastReadAt': instance.lastReadAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

ExportExtensionSource _$ExportExtensionSourceFromJson(Map json) =>
    ExportExtensionSource(
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ref: json['ref'] as String?,
    );

Map<String, dynamic> _$ExportExtensionSourceToJson(
  ExportExtensionSource instance,
) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'ref': instance.ref,
  'type': instance.type,
  'createdAt': instance.createdAt.toIso8601String(),
};

ExportSettings _$ExportSettingsFromJson(Map json) => ExportSettings(
  themeId: json['themeId'] as String?,
  defaultReaderMode: json['defaultReaderMode'] as String?,
  showNsfw: json['showNsfw'] as bool?,
  collectStatistics: json['collectStatistics'] as bool?,
);

Map<String, dynamic> _$ExportSettingsToJson(ExportSettings instance) =>
    <String, dynamic>{
      'themeId': instance.themeId,
      'defaultReaderMode': instance.defaultReaderMode,
      'showNsfw': instance.showNsfw,
      'collectStatistics': instance.collectStatistics,
    };
