import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';

part 'import_export_model.g.dart';

@JsonSerializable()
class ImportExportMode {
  final int version;

  @DateTimeJsonConverter()
  final DateTime exportedAt;

  final List<ChapterActivityDomain> mangaChapterActivities;
  final List<AnimeEpisodeActivityDomain> animeEpisodeActivities;
  
  factory ImportExportMode.fromJson(Map<String, dynamic> json) =>
      _$ImportExportModeFromJson(json);
  
  Map<String, dynamic> toJson() => _$ImportExportModeToJson(this);
  
  const ImportExportMode({
    required this.version,
    required this.exportedAt,
    required this.mangaChapterActivities,
    required this.animeEpisodeActivities,
  });
  
}

class ChapterActivityDomainJsonConverter
    implements JsonConverter<ChapterActivityDomain, Map<String, dynamic>> {
  const ChapterActivityDomainJsonConverter();

  @override
  ChapterActivityDomain fromJson(Map<String, dynamic> json) =>
      ChapterActivityDomain.fromJson(json);

  @override
  Map<String, dynamic> toJson(ChapterActivityDomain object) => object.dataJson;
}

class DateTimeJsonConverter implements JsonConverter<DateTime, String> {
  const DateTimeJsonConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
