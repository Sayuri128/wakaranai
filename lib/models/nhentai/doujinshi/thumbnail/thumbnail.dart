import 'package:json_annotation/json_annotation.dart';

part 'thumbnail.g.dart';

@JsonSerializable()
class Thumbnail {

	factory Thumbnail.fromJson(Map<String, dynamic> json) => _$ThumbnailFromJson(json);
	Map<String, dynamic> toJson() => _$ThumbnailToJson(this);

  final String t;
  final int w;
  final int h;

  const Thumbnail({
    required this.t,
    required this.w,
    required this.h,
  });
}
