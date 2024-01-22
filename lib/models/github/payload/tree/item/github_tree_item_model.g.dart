// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_tree_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubTreeItemModel _$GithubTreeItemModelFromJson(Map json) =>
    GithubTreeItemModel(
      name: json['name'] as String,
      path: json['path'] as String,
      contentType: json['contentType'] as String,
    );

Map<String, dynamic> _$GithubTreeItemModelToJson(
        GithubTreeItemModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'contentType': instance.contentType,
    };
