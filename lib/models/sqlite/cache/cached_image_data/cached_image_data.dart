import 'package:h_reader/repositories/sqlite/cache/image/image_cache_database.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cached_image_data.g.dart';

@JsonSerializable()
class CachedImageData {

	factory CachedImageData.fromJson(Map<String, dynamic> json) => _$CachedImageDataFromJson(json);
	Map<String, dynamic> toJson() => _$CachedImageDataToJson(this);

  final int id;

  @JsonKey(name: ImageCacheDataBase.urlColumn)
  final String url;

  @JsonKey(name: ImageCacheDataBase.cachedDateColumn)
  final DateTime cachedDate;

  const CachedImageData({
    required this.id,
    required this.url,
    required this.cachedDate,
  });

  @override
  String toString() {
    return 'CachedImageData{id: $id, cachedDate: $cachedDate}';
  }
}
