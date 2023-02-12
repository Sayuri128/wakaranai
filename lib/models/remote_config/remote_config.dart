import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/remote_config/remote_category.dart';
import 'package:wakascript/models/config_info/config_info.dart';

part 'remote_config.g.dart';

@JsonSerializable()
class RemoteConfig {

	factory RemoteConfig.fromJson(Map<String, dynamic> json) => _$RemoteConfigFromJson(json);
	Map<String, dynamic> toJson() => _$RemoteConfigToJson(this);

  final RemoteCategory category;
  final String path;
  final ConfigInfo config;

  const RemoteConfig({
    required this.category,
    required this.path,
    required this.config,
  });
}