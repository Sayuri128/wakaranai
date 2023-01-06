// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protector_storage_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtectorStorageItem _$ProtectorStorageItemFromJson(Map json) =>
    ProtectorStorageItem(
      uid: json['uid'] as String,
      headers: Map<String, dynamic>.from(json['headers'] as Map),
    );

Map<String, dynamic> _$ProtectorStorageItemToJson(
        ProtectorStorageItem instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'headers': instance.headers,
    };
