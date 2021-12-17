import 'package:json_annotation/json_annotation.dart';
import 'package:h_reader/models/nhentai/doujinshi/cover/cover.dart';
import 'package:h_reader/models/nhentai/doujinshi/pages_item/pages_item.dart';
import 'package:h_reader/models/nhentai/doujinshi/thumbnail/thumbnail.dart';

part 'images.g.dart';

@JsonSerializable()
class Images {

	factory Images.fromJson(Map<String, dynamic> json) => _$ImagesFromJson(json);
	Map<String, dynamic> toJson() => _$ImagesToJson(this);


  final List<PagesItem> pages;
  final Cover cover;
  final Thumbnail thumbnail;

  const Images({
    required this.pages,
    required this.cover,
    required this.thumbnail,
  });
}

enum ImageType {
  p, j
}
