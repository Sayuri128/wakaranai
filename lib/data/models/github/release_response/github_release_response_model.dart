import 'package:json_annotation/json_annotation.dart';

part 'github_release_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubReleaseResponseModel {
  factory GithubReleaseResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GithubReleaseResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubReleaseResponseModelToJson(this);

  @JsonKey(name: 'tag_name')
  final String? tagName;

  @JsonKey(name: 'html_url')
  final String? htmlUrl;

  final String? name;

  const GithubReleaseResponseModel({
    this.tagName,
    this.htmlUrl,
    this.name,
  });
}
