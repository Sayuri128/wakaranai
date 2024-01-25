// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_blob_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubBlobModel _$GithubBlobModelFromJson(Map json) => GithubBlobModel(
      rawLines:
          (json['rawLines'] as List<dynamic>).map((e) => e as String).toList(),
      displayName: json['displayName'] as String,
      displayUrl: json['displayUrl'] as String,
    );

Map<String, dynamic> _$GithubBlobModelToJson(GithubBlobModel instance) =>
    <String, dynamic>{
      'rawLines': instance.rawLines,
      'displayName': instance.displayName,
      'displayUrl': instance.displayUrl,
    };
