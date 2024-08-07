import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/github_response_model.dart';
import 'package:wakaranai/data/models/github/payload/tree/item/github_tree_item_model.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/repositories/configs_repository/github/github_configs_repository.dart';
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
  final String org;
  final String repository;

  final GithubConfigsRepository _repository = GithubConfigsRepository(
    Dio()..options.validateStatus = (_) => true,
  );

  GitHubConfigsService(this.org, this.repository);

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async {
    List<GithubTreeItemModel> directories = await _getDirectories(
      GithubConfigsRepository.mangaDirectory,
    );

    return Future.wait(
      (directories).map((GithubTreeItemModel e) async {
        return await _getConfig(
          treeItem: e,
          directory: GithubConfigsRepository.mangaDirectory,
          category: "manga",
        );
      }),
    );
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    List<GithubTreeItemModel> directories = await _getDirectories(
      GithubConfigsRepository.animeDirectory,
    );

    return Future.wait(
      (directories).map((GithubTreeItemModel e) async {
        return await _getConfig(
          treeItem: e,
          directory: GithubConfigsRepository.animeDirectory,
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
    final String config = await _repository.getConcreteContent(
      org: org,
      repo: repository,
      concrete: '$directory/${treeItem.name}/config.json',
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
    final GithubResponseModel response = await _repository.getDirectories(
      org,
      repository,
      directory: directory,
    );

    final List<GithubTreeItemModel> directories = response.payload.tree!.items
        .where(
            (GithubTreeItemModel element) => element.contentType == "directory")
        .toList();
    return directories;
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    final String scriptPath = "$path/main.capyscript";
    return RemoteScript(
      path: scriptPath,
      script: await _repository.getConcreteContent(
        org: org,
        repo: repository,
        concrete: scriptPath,
      ),
    );
  }
}
