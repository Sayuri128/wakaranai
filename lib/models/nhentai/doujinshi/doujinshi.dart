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

  @JsonKey(name: 'upload_date')
  final int uploadDate;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doujinshi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mediaId == other.mediaId &&
          title == other.title &&
          images == other.images &&
          scanlator == other.scanlator &&
          uploadDate == other.uploadDate &&
          tags == other.tags &&
          numPages == other.numPages &&
          numFavorites == other.numFavorites;

  @override
  int get hashCode =>
      id.hashCode ^
      mediaId.hashCode ^
      title.hashCode ^
      images.hashCode ^
      scanlator.hashCode ^
      uploadDate.hashCode ^
      tags.hashCode ^
      numPages.hashCode ^
      numFavorites.hashCode;
}
