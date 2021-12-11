import 'package:json_annotation/json_annotation.dart';
import 'package:h_reader/models/nhentai/doujinshi/tags_item/tags_item.dart';
import 'package:h_reader/models/nhentai/doujinshi/title/title.dart';

import 'images/images.dart';

part 'doujinshi.g.dart';

@JsonSerializable()
class Doujinshi {

	factory Doujinshi.fromJson(Map<String, dynamic> json) => _$DoujinshiFromJson(json);
	Map<String, dynamic> toJson() => _$DoujinshiToJson(this);


  final dynamic id;

  @JsonKey(name: 'media_id')
  final String mediaId;
  final Title title;
  final Images images;
  final String scanlator;
  final int? uploadDate;
  final List<TagsItem> tags;
  @JsonKey(name: 'num_pages')
  final int numPages;
  @JsonKey(name: 'num_favorites')
  final int? numFavorites;

  const Doujinshi({
    required this.id,
    required this.mediaId,
    required this.title,
    required this.images,
    required this.scanlator,
    required this.uploadDate,
    required this.tags,
    required this.numPages,
    required this.numFavorites,
  });
}
