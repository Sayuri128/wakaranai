import 'package:json_annotation/json_annotation.dart';

part 'repo_configs_response.g.dart';

@JsonSerializable()
class RepoConfigsResponse {
  final num status;
  final List<String> availableCategories;
  final List<ScriptsBean> scripts;

  RepoConfigsResponse({required this.status, required this.availableCategories, required this.scripts});

  factory RepoConfigsResponse.fromJson(Map<String, dynamic> json) => _$RepoConfigsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RepoConfigsResponseToJson(this);
}

@JsonSerializable()
class ScriptsBean {
  final String category;
  final List<String> scripts;

  ScriptsBean({required this.category, required this.scripts});

  factory ScriptsBean.fromJson(Map<String, dynamic> json) => _$ScriptsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ScriptsBeanToJson(this);
}

