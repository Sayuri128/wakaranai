import 'package:json_annotation/json_annotation.dart';

part 'github_release_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubReleaseResponseModel {
  factory GithubReleaseResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GithubReleaseResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubReleaseResponseModelToJson(this);

  final String url;

  @JsonKey(name: "html_url")
  final String htmlUrl;

  @JsonKey(name: "assets_url")
  final String assetsUrl;

  @JsonKey(name: "upload_url")
  final String uploadUrl;

  @JsonKey(name: "tarball_url")
  final String tarballUrl;

  @JsonKey(name: "zipball_url")
  final String zipballUrl;

  final int id;

  @JsonKey(name: "node_id")
  final String nodeId;

  @JsonKey(name: "tag_name")
  final String tagName;

  @JsonKey(name: "target_commitish")
  final String targetCommitish;

  final String name;

  const GithubReleaseResponseModel({
    required this.url,
    required this.htmlUrl,
    required this.assetsUrl,
    required this.uploadUrl,
    required this.tarballUrl,
    required this.zipballUrl,
    required this.id,
    required this.nodeId,
    required this.tagName,
    required this.targetCommitish,
    required this.name,
  });
}
