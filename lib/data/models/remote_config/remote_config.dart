import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/data/domain/extension/base_extension.dart';
import 'package:wakaranai/data/domain/extension/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_category.dart';

part 'remote_config.g.dart';

@JsonSerializable()
class RemoteConfig with BaseExtension {
  factory RemoteConfig.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteConfigToJson(this);

  final String path;
  @override
  final ConfigInfo config;
  const RemoteConfig({
    required this.path,
    required this.config,
  });
}
