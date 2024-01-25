import 'package:json_annotation/json_annotation.dart';

part 'github_repo_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubRepoModel {
  factory GithubRepoModel.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubRepoModelToJson(this);

  final int id;
  final String defaultBranch;
  final String name;
  final String ownerLogin;
  final bool currentUserCanPush;
  final bool isFork;
  final bool isEmpty;
  final String createdAt;
  final String ownerAvatar;
  final bool public;
  final bool private;
  final bool isOrgOwned;

  const GithubRepoModel({
    required this.id,
    required this.defaultBranch,
    required this.name,
    required this.ownerLogin,
    required this.currentUserCanPush,
    required this.isFork,
    required this.isEmpty,
    required this.createdAt,
    required this.ownerAvatar,
    required this.public,
    required this.private,
    required this.isOrgOwned,
  });
}
