// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagsItem _$TagsItemFromJson(Map json) => TagsItem(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      count: json['count'] as int,
    );

Map<String, dynamic> _$TagsItemToJson(TagsItem instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'url': instance.url,
      'count': instance.count,
    };
