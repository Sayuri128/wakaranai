import 'package:h_reader/models/nhentai/doujinshi/images/images.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pages_item.g.dart';

@JsonSerializable()
class PagesItem {

	factory PagesItem.fromJson(Map<String, dynamic> json) => _$PagesItemFromJson(json);
	Map<String, dynamic> toJson() => _$PagesItemToJson(this);

  final ImageType t;
  final int w;
  final int h;

  const PagesItem({
    required this.t,
    required this.w,
    required this.h,
  });
}