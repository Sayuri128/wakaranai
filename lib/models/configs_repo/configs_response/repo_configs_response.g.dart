// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_configs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoConfigsResponse _$RepoConfigsResponseFromJson(Map json) =>
    RepoConfigsResponse(
      status: json['status'] as num,
      availableCategories: (json['availableCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      scripts: (json['scripts'] as List<dynamic>)
          .map((e) => ScriptsBean.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$RepoConfigsResponseToJson(
        RepoConfigsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'availableCategories': instance.availableCategories,
      'scripts': instance.scripts.map((e) => e.toJson()).toList(),
    };

ScriptsBean _$ScriptsBeanFromJson(Map json) => ScriptsBean(
      category: json['category'] as String,
      scripts:
          (json['scripts'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ScriptsBeanToJson(ScriptsBean instance) =>
    <String, dynamic>{
      'category': instance.category,
      'scripts': instance.scripts,
    };
