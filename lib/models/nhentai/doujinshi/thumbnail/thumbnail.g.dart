// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thumbnail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thumbnail _$ThumbnailFromJson(Map<String, dynamic> json) => Thumbnail(
      t: $enumDecode(_$ImageTypeEnumMap, json['t']),
      w: json['w'] as int,
      h: json['h'] as int,
    );

Map<String, dynamic> _$ThumbnailToJson(Thumbnail instance) => <String, dynamic>{
      't': _$ImageTypeEnumMap[instance.t],
      'w': instance.w,
      'h': instance.h,
    };

const _$ImageTypeEnumMap = {
  ImageType.p: 'p',
  ImageType.j: 'j',
};
