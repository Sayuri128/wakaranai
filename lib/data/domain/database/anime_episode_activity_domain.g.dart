// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_episode_activity_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeEpisodeActivityDomain _$AnimeEpisodeActivityDomainFromJson(Map json) =>
    AnimeEpisodeActivityDomain(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] as String,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String?,
      data: json['data'] as String?,
      concreteId: (json['concreteId'] as num).toInt(),
      watchedTime: (json['watchedTime'] as num?)?.toInt(),
      totalTime: (json['totalTime'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnimeEpisodeActivityDomainToJson(
        AnimeEpisodeActivityDomain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'uid': instance.uid,
      'concreteId': instance.concreteId,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'watchedTime': instance.watchedTime,
      'totalTime': instance.totalTime,
    };
