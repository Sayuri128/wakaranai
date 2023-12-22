import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/remote_config/remote_category.dart';

part 'remote_config.g.dart';

ConfigInfoType remoteCategoryToConfigInfoType(RemoteCategory remoteCategory) {
  switch(remoteCategory) {
    case RemoteCategory.anime:
      return ConfigInfoType.ANIME;
    case RemoteCategory.manga:
      return ConfigInfoType.MANGA;
  }
}

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
