import 'package:json_annotation/json_annotation.dart';

part 'github_blob_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubBlobModel {
  factory GithubBlobModel.fromJson(Map<String, dynamic> json) =>
      _$GithubBlobModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubBlobModelToJson(this);

  final List<String> rawLines;
  final String displayName;
  final String displayUrl;

  const GithubBlobModel({
    required this.rawLines,
    required this.displayName,
    required this.displayUrl,
  });
}
