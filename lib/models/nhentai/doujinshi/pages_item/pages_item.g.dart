// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pages_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagesItem _$PagesItemFromJson(Map<String, dynamic> json) => PagesItem(
      t: $enumDecode(_$ImageTypeEnumMap, json['t']),
      w: json['w'] as int,
      h: json['h'] as int,
    );

Map<String, dynamic> _$PagesItemToJson(PagesItem instance) => <String, dynamic>{
      't': _$ImageTypeEnumMap[instance.t],
      'w': instance.w,
      'h': instance.h,
    };

const _$ImageTypeEnumMap = {
  ImageType.p: 'p',
  ImageType.j: 'j',
  ImageType.g: 'g',
};
