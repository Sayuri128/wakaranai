// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_image_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedImageData _$CachedImageDataFromJson(Map<String, dynamic> json) =>
    CachedImageData(
      id: json['id'] as int,
      cacheKey: json['cache_key'] as String,
      cachedDate: DateTime.parse(json['cached_date'] as String),
    );

Map<String, dynamic> _$CachedImageDataToJson(CachedImageData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cache_key': instance.cacheKey,
      'cached_date': instance.cachedDate.toIso8601String(),
    };
