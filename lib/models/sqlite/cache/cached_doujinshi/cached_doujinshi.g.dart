// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_doujinshi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedDoujinshi _$CachedDoujinshiFromJson(Map json) => CachedDoujinshi(
      id: json['id'] as int,
      doujinshi: Doujinshi.fromJson(
          Map<String, dynamic>.from(json['doujinshi_json'] as Map)),
      thumbnail: CachedImageData.fromJson(
          Map<String, dynamic>.from(json['cached_thumbnail_id'] as Map)),
      cover: CachedImageData.fromJson(
          Map<String, dynamic>.from(json['cached_cover_id'] as Map)),
      pageItems: (json['cached_page_item_ids_json'] as List<dynamic>)
          .map((e) =>
              CachedImageData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      sourceItems: (json['cached_source_ids_json'] as List<dynamic>)
          .map((e) =>
              CachedImageData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$CachedDoujinshiToJson(CachedDoujinshi instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doujinshi_json': instance.doujinshi.toJson(),
      'cached_thumbnail_id': instance.thumbnail.toJson(),
      'cached_cover_id': instance.cover.toJson(),
      'cached_page_item_ids_json':
          instance.pageItems.map((e) => e.toJson()).toList(),
      'cached_source_ids_json':
          instance.sourceItems.map((e) => e.toJson()).toList(),
    };
