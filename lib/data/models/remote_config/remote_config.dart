import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';

part 'remote_config.g.dart';

@JsonSerializable()
class RemoteConfig with BaseExtension {
  factory RemoteConfig.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteConfigToJson(this);

  final String path;
  final String? revision;
  @override
  final ConfigInfo config;
  final int? apiVersion;
  final String? minAppVersion;
  const RemoteConfig({
    required this.path,
    required this.config,
    this.revision,
    this.apiVersion,
    this.minAppVersion,
  });

  int get effectiveApiVersion => ExtensionCompatibility.effectiveApiVersion(
        config,
        entryApiVersion: apiVersion,
      );

  String? get effectiveMinAppVersion =>
      ExtensionCompatibility.effectiveMinAppVersion(
        config,
        entryMinAppVersion: minAppVersion,
      );

  ExtensionCompatibility get compatibility => ExtensionCompatibility.evaluate(
        apiVersion: effectiveApiVersion,
        minAppVersion: effectiveMinAppVersion,
      );
}
