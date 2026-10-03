// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfig _$RemoteConfigFromJson(Map json) => RemoteConfig(
  path: json['path'] as String,
  config: ConfigInfo.fromJson(Map<String, dynamic>.from(json['config'] as Map)),
  revision: json['revision'] as String?,
);

Map<String, dynamic> _$RemoteConfigToJson(RemoteConfig instance) =>
    <String, dynamic>{
      'path': instance.path,
      'revision': instance.revision,
      'config': instance.config.toJson(),
    };
