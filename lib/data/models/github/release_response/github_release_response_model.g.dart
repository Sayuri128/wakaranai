// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubReleaseResponseModel _$GithubReleaseResponseModelFromJson(Map json) =>
    GithubReleaseResponseModel(
      tagName: json['tag_name'] as String?,
      htmlUrl: json['html_url'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$GithubReleaseResponseModelToJson(
  GithubReleaseResponseModel instance,
) => <String, dynamic>{
  'tag_name': instance.tagName,
  'html_url': instance.htmlUrl,
  'name': instance.name,
};
