import 'package:json_annotation/json_annotation.dart';

part 'title.g.dart';

@JsonSerializable()
class Title {

	factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);
	Map<String, dynamic> toJson() => _$TitleToJson(this);

  final String? english;
  final String? japanese;
  final String? pretty;

  const Title({
    required this.english,
    required this.japanese,
    required this.pretty,
  });
}
