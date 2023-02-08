
import 'package:dio/dio.dart';
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

  Future<String> _downloadSourceCode(String url) async {
    return (await http.get(Uri.parse(url))).body.replaceAll("\n", "\r\n");
  }

  @override
  Future<List<MangaApiClient>> getMangaConfigs() async {
    return await Future.wait(
        (await _repository.getMangaConfigs(ORG, REPOSITORY)).map((e) async {
      final code = await _downloadSourceCode(e.download_url);
      return MangaApiClient(code: code);
    }));
  }

  @override
  Future<List<AnimeApiClient>> getAnimeConfigs() async {
    return await Future.wait(
        (await _repository.getAnimeConfigs(ORG, REPOSITORY)).map((e) async {
      final code = await _downloadSourceCode(e.download_url);
      return AnimeApiClient(code: code);
    }));
  }
}
