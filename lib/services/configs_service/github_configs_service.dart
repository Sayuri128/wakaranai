import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/models/remote_script/remote_script.dart';
import 'package:wakaranai/repositories/configs_repository/github/github_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';

class GitHubConfigsService implements ConfigsService {
  final String ORG;
  final String REPOSITORY;

  final GithubConfigsRepository _repository = GithubConfigsRepository(Dio());

  GitHubConfigsService(this.ORG, this.REPOSITORY);

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async {
    return Future.wait(
        (await _repository.getMangaDirectories(ORG, REPOSITORY)).map((e) async {
      final concreteContent = await _repository.getConcreteContent(
          org: ORG,
          repo: REPOSITORY,
          directory: GithubConfigsRepository.MANGA_DIRECTORY,
          concrete: e.name);
      final config = await _downloadSourceCode(concreteContent
          .firstWhere((element) => element.name == "config.json")
          .download_url!);
      return RemoteConfig.fromJson({
        "category": "manga",
        "path": e.name,
        "config": jsonDecode(config)
      });
    }));
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    return Future.wait(
        (await _repository.getAnimeDirectories(ORG, REPOSITORY)).map((e) async {
      final concreteContent = await _repository.getConcreteContent(
          org: ORG,
          repo: REPOSITORY,
          directory: GithubConfigsRepository.ANIME_DIRECTORY,
          concrete: e.name);
      final config = await _downloadSourceCode(concreteContent
          .firstWhere((element) => element.name == "config.json")
          .download_url!);
      return RemoteConfig.fromJson({
        "category": "anime",
        "path": e.name,
        "config": jsonDecode(config)
      });
    }));
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    return RemoteScript.fromJson(jsonDecode(await _downloadSourceCode(
        (await _repository.getConcreteContent(
                org: ORG,
                repo: REPOSITORY,
                directory: GithubConfigsRepository.ANIME_DIRECTORY,
                concrete: path))
            .firstWhere((element) => element.name != "config.json")
            .download_url!)));
  }
}

Future<String> _downloadSourceCode(String url) async {
  return (await http.get(Uri.parse(url))).body.replaceAll("\n", "\r\n");
}
