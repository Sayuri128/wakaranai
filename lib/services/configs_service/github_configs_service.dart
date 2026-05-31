import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/payload/tree/item/github_tree_item_model.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/services/configs_service/capyscript_import_bundler.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';

/*
* This needs to be refactored to avoid too many requests to GitHub
* ideally we should get all the configs at once
* e.g. there is .json file that contains all the necessary information
* like the path to the config file, category, etc.
* basically a lightweight version of ConfigInfo model
* this way it will also allow us to make the order of the configs customizable
 */
class GitHubConfigsService implements ConfigsService {
  static const String _branch = 'main';
  static const String _mangaDirectory = 'manga';
  static const String _animeDirectory = 'anime';

  final String org;
  final String repository;

  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (_) => true,
      headers: <String, String>{
        'accept': 'application/vnd.github+json',
      },
    ),
  );

  GitHubConfigsService(this.org, this.repository);

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async {
    List<GithubTreeItemModel> directories = await _getDirectories(
      _mangaDirectory,
    );

    return Future.wait(
      (directories).map((GithubTreeItemModel e) async {
        return await _getConfig(
          treeItem: e,
          directory: _mangaDirectory,
          category: "manga",
        );
      }),
    );
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    List<GithubTreeItemModel> directories = await _getDirectories(
      _animeDirectory,
    );

    return Future.wait(
      (directories).map((GithubTreeItemModel e) async {
        return await _getConfig(
          treeItem: e,
          directory: _animeDirectory,
          category: "anime",
        );
      }),
    );
  }

  Future<RemoteConfig> _getConfig({
    required GithubTreeItemModel treeItem,
    required String directory,
    required String category,
  }) async {
    final String config = await _getRawContent(
      '$directory/${treeItem.name}/config.json',
    );

    return RemoteConfig.fromJson(
      <String, dynamic>{
        "category": category,
        "path": '$directory/${treeItem.name}',
        "config": jsonDecode(config),
      },
    );
  }

  Future<List<GithubTreeItemModel>> _getDirectories(
    String directory,
  ) async {
    final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
      'https://api.github.com/repos/$org/$repository/contents/$directory',
      queryParameters: <String, dynamic>{'ref': _branch},
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Failed to load GitHub directory $directory from $org/$repository',
      );
    }

    return response.data!
        .whereType<Map<String, dynamic>>()
        .where((Map<String, dynamic> item) => item['type'] == 'dir')
        .map((Map<String, dynamic> item) => GithubTreeItemModel(
              name: item['name'] as String,
              path: item['path'] as String,
              contentType: 'directory',
            ))
        .toList();
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    final String scriptPath = "$path/main.capyscript";
    return CapyscriptImportBundler.bundle(
      entryPath: scriptPath,
      fetchScript: (String concretePath) async => RemoteScript(
        path: concretePath,
        script: await _getRawContent(concretePath),
      ),
    );
  }

  Future<String> _getRawContent(String path) async {
    final Response<String> response = await _dio.get<String>(
      'https://raw.githubusercontent.com/$org/$repository/$_branch/$path',
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Failed to load GitHub file $path from $org/$repository',
      );
    }

    return response.data!;
  }
}
