import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wakaranai/repositories/configs_repository/github/github_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';

class GitHubConfigsService implements ConfigsService {
  final String ORG;
  final String REPOSITORY;

  final GithubConfigsRepository _repository = GithubConfigsRepository(Dio());

  GitHubConfigsService(this.ORG, this.REPOSITORY);


  @override
  Future<List<MangaApiClient>> getMangaConfigs() async {
    final urls = (await _repository.getMangaConfigs(ORG, REPOSITORY)).map((e) => e.download_url);
    return await compute<String, List<MangaApiClient>>(_getMangaConfigs, urls.join(" | "));
  }

  @override
  Future<List<AnimeApiClient>> getAnimeConfigs() async {
    final urls = (await _repository.getAnimeConfigs(ORG, REPOSITORY)).map((e) => e.download_url);
    return await compute<String, List<AnimeApiClient>>(_getAnimeConfigs, urls.join(" | "));
  }
}

Future<String> _downloadSourceCode(String url) async {
  return (await http.get(Uri.parse(url))).body.replaceAll("\n", "\r\n");
}

Future<List<MangaApiClient>> _getMangaConfigs(String url) async {
  return await Future.wait(
      (url.split(" | ")).map((e) async {
        final code = await _downloadSourceCode(e);
        return MangaApiClient(code: code);
      }));
}

Future<List<AnimeApiClient>> _getAnimeConfigs(String url) async {
  return await Future.wait(
      (url.split(" | ")).map((e) async {
        final code = await _downloadSourceCode(e);
        return AnimeApiClient(code: code);
      }));
}