// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_tree_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubTreeModel _$GithubTreeModelFromJson(Map json) => GithubTreeModel(
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              GithubTreeItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$GithubTreeModelToJson(GithubTreeModel instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
