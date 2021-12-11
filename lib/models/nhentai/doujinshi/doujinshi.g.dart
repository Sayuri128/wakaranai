// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doujinshi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doujinshi _$DoujinshiFromJson(Map<String, dynamic> json) => Doujinshi(
      id: json['id'],
      mediaId: json['mediaId'] as String?,
      title: Title.fromJson(json['title'] as Map<String, dynamic>),
      images: Images.fromJson(json['images'] as Map<String, dynamic>),
      scanlator: json['scanlator'] as String,
      uploadDate: json['uploadDate'] as int?,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      numPages: json['numPages'] as int?,
      numFavorites: json['numFavorites'] as int?,
    );

Map<String, dynamic> _$DoujinshiToJson(Doujinshi instance) => <String, dynamic>{
      'id': instance.id,
      'mediaId': instance.mediaId,
      'title': instance.title,
      'images': instance.images,
      'scanlator': instance.scanlator,
      'uploadDate': instance.uploadDate,
      'tags': instance.tags,
      'numPages': instance.numPages,
      'numFavorites': instance.numFavorites,
    };
