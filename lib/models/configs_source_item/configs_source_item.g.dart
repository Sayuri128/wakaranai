// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configs_source_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigsSourceItem _$ConfigsSourceItemFromJson(Map json) => ConfigsSourceItem(
      id: json['id'] as int?,
      baseUrl: json['baseUrl'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ConfigsSourceTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ConfigsSourceItemToJson(ConfigsSourceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baseUrl': instance.baseUrl,
      'name': instance.name,
      'type': _$ConfigsSourceTypeEnumMap[instance.type]!,
    };

const _$ConfigsSourceTypeEnumMap = {
  ConfigsSourceType.GIT_HUB: 'GIT_HUB',
  ConfigsSourceType.REST: 'REST',
};
