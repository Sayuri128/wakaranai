import 'package:json_annotation/json_annotation.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';

part 'gallery.g.dart';

@JsonSerializable()
class Gallery {

	factory Gallery.fromJson(Map<String, dynamic> json) => _$GalleryFromJson(json);
	Map<String, dynamic> toJson() => _$GalleryToJson(this);

  final List<Doujinshi> result;

  const Gallery({
    required this.result,
  });
}
