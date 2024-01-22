import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/github/payload/repo/github_repo_model.dart';
import 'package:wakaranai/models/github/payload/tree/blob/github_blob_model.dart';
import 'package:wakaranai/models/github/payload/tree/github_tree_model.dart';

part 'github_payload_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubPayloadModel {
  factory GithubPayloadModel.fromJson(Map<String, dynamic> json) =>
      _$GithubPayloadModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubPayloadModelToJson(this);

  final String path;
  final GithubRepoModel repo;
  final GithubTreeModel? tree;
  final GithubBlobModel? blob;
  final String? title;

  const GithubPayloadModel({
    required this.path,
    required this.repo,
    required this.tree,
    this.blob,
    this.title,
  });
}
