// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doujinshi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doujinshi _$DoujinshiFromJson(Map<String, dynamic> json) => Doujinshi(
      id: json['id'],
      mediaId: json['media_id'] as String,
      title: Title.fromJson(json['title'] as Map<String, dynamic>),
      images: Images.fromJson(json['images'] as Map<String, dynamic>),
      scanlator: json['scanlator'] as String,
      uploadDate: json['uploadDate'] as int?,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      numPages: json['num_pages'] as int,
      numFavorites: json['num_favorites'] as int?,
    );

Map<String, dynamic> _$DoujinshiToJson(Doujinshi instance) => <String, dynamic>{
      'id': instance.id,
      'media_id': instance.mediaId,
      'title': instance.title,
      'images': instance.images,
      'scanlator': instance.scanlator,
      'uploadDate': instance.uploadDate,
      'tags': instance.tags,
      'num_pages': instance.numPages,
      'num_favorites': instance.numFavorites,
    };
