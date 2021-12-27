import 'package:h_reader/repositories/sqlite/cache/doujinshi/doujinshi_cache_database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/sqlite/cache/cached_image_data/cached_image_data.dart';

part 'cached_doujinshi.g.dart';

@JsonSerializable()
class CachedDoujinshi {
  factory CachedDoujinshi.fromJson(Map<String, dynamic> json) => _$CachedDoujinshiFromJson(json);
  Map<String, dynamic> toJson() => _$CachedDoujinshiToJson(this);

  final int id;

  @JsonKey(name: DoujinshiCacheDatabase.doujinshiColumn)
  final Doujinshi doujinshi;

  @JsonKey(name: DoujinshiCacheDatabase.mediaIdColumn)
  final String mediaId;

  @JsonKey(name: DoujinshiCacheDatabase.thumbnailColumn)
  final CachedImageData thumbnail;

  @JsonKey(name: DoujinshiCacheDatabase.coverColumn)
  final CachedImageData cover;

  @JsonKey(name: DoujinshiCacheDatabase.pageItemColumn)
  final List<CachedImageData> pageItems;

  @JsonKey(name: DoujinshiCacheDatabase.sourceItemColumn)
  final List<CachedImageData> sourceItems;

  const CachedDoujinshi({
    required this.id,
    required this.doujinshi,
    required this.mediaId,
    required this.thumbnail,
    required this.cover,
    required this.pageItems,
    required this.sourceItems,
  });
}
