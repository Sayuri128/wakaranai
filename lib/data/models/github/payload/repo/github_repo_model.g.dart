// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubRepoModel _$GithubRepoModelFromJson(Map json) => GithubRepoModel(
      id: json['id'] as int,
      defaultBranch: json['defaultBranch'] as String,
      name: json['name'] as String,
      ownerLogin: json['ownerLogin'] as String,
      currentUserCanPush: json['currentUserCanPush'] as bool,
      isFork: json['isFork'] as bool,
      isEmpty: json['isEmpty'] as bool,
      createdAt: json['createdAt'] as String,
      ownerAvatar: json['ownerAvatar'] as String,
      public: json['public'] as bool,
      private: json['private'] as bool,
      isOrgOwned: json['isOrgOwned'] as bool,
    );

Map<String, dynamic> _$GithubRepoModelToJson(GithubRepoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'defaultBranch': instance.defaultBranch,
      'name': instance.name,
      'ownerLogin': instance.ownerLogin,
      'currentUserCanPush': instance.currentUserCanPush,
      'isFork': instance.isFork,
      'isEmpty': instance.isEmpty,
      'createdAt': instance.createdAt,
      'ownerAvatar': instance.ownerAvatar,
      'public': instance.public,
      'private': instance.private,
      'isOrgOwned': instance.isOrgOwned,
    };
