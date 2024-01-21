import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/github/payload/tree/item/github_tree_item_model.dart';

part 'github_tree_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubTreeModel {
  factory GithubTreeModel.fromJson(Map<String, dynamic> json) =>
      _$GithubTreeModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubTreeModelToJson(this);

  final List<GithubTreeItemModel> items;

  const GithubTreeModel({
    required this.items,
  });
}
