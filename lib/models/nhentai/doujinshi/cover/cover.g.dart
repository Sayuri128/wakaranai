// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cover _$CoverFromJson(Map<String, dynamic> json) => Cover(
      t: $enumDecode(_$ImageTypeEnumMap, json['t']),
      w: json['w'] as int,
      h: json['h'] as int,
    );

Map<String, dynamic> _$CoverToJson(Cover instance) => <String, dynamic>{
      't': _$ImageTypeEnumMap[instance.t],
      'w': instance.w,
      'h': instance.h,
    };

const _$ImageTypeEnumMap = {
  ImageType.p: 'p',
  ImageType.j: 'j',
  ImageType.g: 'g',
};
