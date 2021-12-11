// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gallery _$GalleryFromJson(Map<String, dynamic> json) => Gallery(
      result: (json['result'] as List<dynamic>)
          .map((e) => Doujinshi.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GalleryToJson(Gallery instance) => <String, dynamic>{
      'result': instance.result,
    };
