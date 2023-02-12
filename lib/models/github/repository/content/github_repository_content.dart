import 'package:json_annotation/json_annotation.dart';

import 'links/links.dart';

part 'github_repository_content.g.dart';

@JsonSerializable()
class GithubRepositoryContent {

	factory GithubRepositoryContent.fromJson(Map<String, dynamic> json) => _$GithubRepositoryContentFromJson(json);
	Map<String, dynamic> toJson() => _$GithubRepositoryContentToJson(this);


  @JsonKey(name: '_links')
  final Links links;
  final String? download_url;
  final String git_url;
  final String html_url;
  final String name;
  final String path;
  final String sha;
  final int size;
  final String type;
  final String url;

  const GithubRepositoryContent({
    required this.links,
    required this.download_url,
    required this.git_url,
    required this.html_url,
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    required this.type,
    required this.url,
  });
}
