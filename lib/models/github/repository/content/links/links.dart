import 'package:json_annotation/json_annotation.dart';

part 'links.g.dart';

@JsonSerializable()
class Links {

	factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);
	Map<String, dynamic> toJson() => _$LinksToJson(this);

  final String git;
  final String html;
  final String self;

  const Links({
    required this.git,
    required this.html,
    required this.self,
  });
}
