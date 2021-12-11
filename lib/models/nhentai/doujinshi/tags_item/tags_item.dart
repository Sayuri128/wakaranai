import 'package:json_annotation/json_annotation.dart';

part 'tags_item.g.dart';

@JsonSerializable()
class TagsItem {

	factory TagsItem.fromJson(Map<String, dynamic> json) => _$TagsItemFromJson(json);
	Map<String, dynamic> toJson() => _$TagsItemToJson(this);

  final int id;
  final String type;
  final String name;
  final String url;
  final int count;

  const TagsItem({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.count,
  });
}
