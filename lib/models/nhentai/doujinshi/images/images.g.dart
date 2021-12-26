// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Images _$ImagesFromJson(Map json) => Images(
      pages: (json['pages'] as List<dynamic>)
          .map((e) => PagesItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      cover: Cover.fromJson(Map<String, dynamic>.from(json['cover'] as Map)),
      thumbnail: Thumbnail.fromJson(
          Map<String, dynamic>.from(json['thumbnail'] as Map)),
    );

Map<String, dynamic> _$ImagesToJson(Images instance) => <String, dynamic>{
      'pages': instance.pages.map((e) => e.toJson()).toList(),
      'cover': instance.cover.toJson(),
      'thumbnail': instance.thumbnail.toJson(),
    };
