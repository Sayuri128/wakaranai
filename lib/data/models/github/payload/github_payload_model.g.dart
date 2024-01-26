// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_payload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubPayloadModel _$GithubPayloadModelFromJson(Map json) => GithubPayloadModel(
      path: json['path'] as String,
      repo: GithubRepoModel.fromJson(
          Map<String, dynamic>.from(json['repo'] as Map)),
      tree: json['tree'] == null
          ? null
          : GithubTreeModel.fromJson(
              Map<String, dynamic>.from(json['tree'] as Map)),
      blob: json['blob'] == null
          ? null
          : GithubBlobModel.fromJson(
              Map<String, dynamic>.from(json['blob'] as Map)),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$GithubPayloadModelToJson(GithubPayloadModel instance) =>
    <String, dynamic>{
      'path': instance.path,
      'repo': instance.repo.toJson(),
      'tree': instance.tree?.toJson(),
      'blob': instance.blob?.toJson(),
      'title': instance.title,
    };
