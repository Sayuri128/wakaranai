// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gallery _$GalleryFromJson(Map json) => Gallery(
      result: (json['result'] as List<dynamic>)
          .map((e) => Doujinshi.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$GalleryToJson(Gallery instance) => <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
    };
