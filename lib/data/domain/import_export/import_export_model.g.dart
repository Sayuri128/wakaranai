// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_export_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportExportMode _$ImportExportModeFromJson(Map json) => ImportExportMode(
  version: (json['version'] as num).toInt(),
  exportedAt: const DateTimeJsonConverter().fromJson(
    json['exportedAt'] as String,
  ),
  mangaChapterActivities: (json['mangaChapterActivities'] as List<dynamic>)
      .map(
        (e) =>
            ChapterActivityDomain.fromJson(Map<String, dynamic>.from(e as Map)),
      )
      .toList(),
  animeEpisodeActivities: (json['animeEpisodeActivities'] as List<dynamic>)
      .map(
        (e) => AnimeEpisodeActivityDomain.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ImportExportModeToJson(ImportExportMode instance) =>
    <String, dynamic>{
      'version': instance.version,
      'exportedAt': const DateTimeJsonConverter().toJson(instance.exportedAt),
      'mangaChapterActivities': instance.mangaChapterActivities
          .map((e) => e.toJson())
          .toList(),
      'animeEpisodeActivities': instance.animeEpisodeActivities
          .map((e) => e.toJson())
          .toList(),
    };
