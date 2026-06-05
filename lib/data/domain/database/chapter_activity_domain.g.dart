// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_activity_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterActivityDomain _$ChapterActivityDomainFromJson(Map json) =>
    ChapterActivityDomain(
      uid: json['uid'] as String,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String?,
      data: json['data'] as String?,
      concreteId: (json['concreteId'] as num).toInt(),
      readPages: (json['readPages'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChapterActivityDomainToJson(
        ChapterActivityDomain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'uid': instance.uid,
      'concreteId': instance.concreteId,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'readPages': instance.readPages,
      'totalPages': instance.totalPages,
    };
