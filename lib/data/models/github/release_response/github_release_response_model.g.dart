// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubReleaseResponseModel _$GithubReleaseResponseModelFromJson(Map json) =>
    GithubReleaseResponseModel(
      url: json['url'] as String,
      htmlUrl: json['html_url'] as String,
      assetsUrl: json['assets_url'] as String,
      uploadUrl: json['upload_url'] as String,
      tarballUrl: json['tarball_url'] as String,
      zipballUrl: json['zipball_url'] as String,
      id: json['id'] as int,
      nodeId: json['node_id'] as String,
      tagName: json['tag_name'] as String,
      targetCommitish: json['target_commitish'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$GithubReleaseResponseModelToJson(
        GithubReleaseResponseModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'assets_url': instance.assetsUrl,
      'upload_url': instance.uploadUrl,
      'tarball_url': instance.tarballUrl,
      'zipball_url': instance.zipballUrl,
      'id': instance.id,
      'node_id': instance.nodeId,
      'tag_name': instance.tagName,
      'target_commitish': instance.targetCommitish,
      'name': instance.name,
    };
