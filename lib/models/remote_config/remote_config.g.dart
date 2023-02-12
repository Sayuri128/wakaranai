// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfig _$RemoteConfigFromJson(Map json) => RemoteConfig(
      category: $enumDecode(_$RemoteCategoryEnumMap, json['category']),
      path: json['path'] as String,
      config:
          ConfigInfo.fromJson(Map<String, dynamic>.from(json['config'] as Map)),
    );

Map<String, dynamic> _$RemoteConfigToJson(RemoteConfig instance) =>
    <String, dynamic>{
      'category': _$RemoteCategoryEnumMap[instance.category]!,
      'path': instance.path,
      'config': instance.config.toJson(),
    };

const _$RemoteCategoryEnumMap = {
  RemoteCategory.anime: 'anime',
  RemoteCategory.manga: 'manga',
};
