import 'package:json_annotation/json_annotation.dart';

part 'github_tree_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubTreeItemModel {
  factory GithubTreeItemModel.fromJson(Map<String, dynamic> json) =>
      _$GithubTreeItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubTreeItemModelToJson(this);
  final String name;
  final String path;
  final String contentType;

  const GithubTreeItemModel({
    required this.name,
    required this.path,
    required this.contentType,
  });
}
