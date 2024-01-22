// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_configs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoConfigsResponse _$RepoConfigsResponseFromJson(Map json) =>
    RepoConfigsResponse(
      status: json['status'] as int,
      availableCategories: (json['availableCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      configs: (json['configs'] as List<dynamic>)
          .map(
              (e) => RemoteConfig.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$RepoConfigsResponseToJson(
        RepoConfigsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'availableCategories': instance.availableCategories,
      'configs': instance.configs.map((e) => e.toJson()).toList(),
    };
