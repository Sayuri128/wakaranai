// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Images _$ImagesFromJson(Map<String, dynamic> json) => Images(
      pages: (json['pages'] as List<dynamic>)
          .map((e) => PagesItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cover: Cover.fromJson(json['cover'] as Map<String, dynamic>),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImagesToJson(Images instance) => <String, dynamic>{
      'pages': instance.pages,
      'cover': instance.cover,
      'thumbnail': instance.thumbnail,
    };
