import 'package:h_reader/models/nhentai/doujinshi/images/images.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cover.g.dart';

@JsonSerializable()
class Cover {

	factory Cover.fromJson(Map<String, dynamic> json) => _$CoverFromJson(json);
	Map<String, dynamic> toJson() => _$CoverToJson(this);


  final ImageType t;
  final int w;
  final int h;

  const Cover({
    required this.t,
    required this.w,
    required this.h,
  });
}
