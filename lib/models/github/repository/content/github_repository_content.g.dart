// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repository_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubRepositoryContent _$GithubRepositoryContentFromJson(Map json) =>
    GithubRepositoryContent(
      links: Links.fromJson(Map<String, dynamic>.from(json['_links'] as Map)),
      download_url: json['download_url'] as String,
      git_url: json['git_url'] as String,
      html_url: json['html_url'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      sha: json['sha'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$GithubRepositoryContentToJson(
        GithubRepositoryContent instance) =>
    <String, dynamic>{
      '_links': instance.links.toJson(),
      'download_url': instance.download_url,
      'git_url': instance.git_url,
      'html_url': instance.html_url,
      'name': instance.name,
      'path': instance.path,
      'sha': instance.sha,
      'size': instance.size,
      'type': instance.type,
      'url': instance.url,
    };
