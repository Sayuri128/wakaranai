// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doujinshi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doujinshi _$DoujinshiFromJson(Map json) => Doujinshi(
      id: json['id'],
      mediaId: json['media_id'] as String,
      title: Title.fromJson(Map<String, dynamic>.from(json['title'] as Map)),
      images: Images.fromJson(Map<String, dynamic>.from(json['images'] as Map)),
      scanlator: json['scanlator'] as String,
      uploadDate: json['upload_date'] as int,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagsItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      numPages: json['num_pages'] as int,
      numFavorites: json['num_favorites'] as int?,
    );

Map<String, dynamic> _$DoujinshiToJson(Doujinshi instance) => <String, dynamic>{
      'id': instance.id,
      'media_id': instance.mediaId,
      'title': instance.title.toJson(),
      'images': instance.images.toJson(),
      'scanlator': instance.scanlator,
      'upload_date': instance.uploadDate,
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'num_pages': instance.numPages,
      'num_favorites': instance.numFavorites,
    };
