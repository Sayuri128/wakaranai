import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';

part 'repo_configs_response.g.dart';

@JsonSerializable()
class RepoConfigsResponse {
  final int status;
  final List<String> availableCategories;
  final List<RemoteConfig> configs;

  factory RepoConfigsResponse.fromJson(Map<String, dynamic> json) =>
      _$RepoConfigsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RepoConfigsResponseToJson(this);

  const RepoConfigsResponse({
    required this.status,
    required this.availableCategories,
    required this.configs,
  });
}
