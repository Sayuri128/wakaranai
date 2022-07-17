import 'package:dio/dio.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/configs_repository/github/github_configs_repository.dart';
import 'package:wakaranai/repositories/configs_repository/local/local_configs_repository.dart';
import 'package:wakascript/api_controller.dart';
import 'package:http/http.dart' as http;

class ConfigsService {
  static const String ORG = 'KoneruHodl';
  static const String REPOSITORY = 'waka-configs';

  final GithubConfigsRepository _repository = GithubConfigsRepository(Dio());
  final LocalConfigsRepository _localRepository =
      LocalConfigsRepository(Dio(), baseUrl: Env.LOCAL_REPOSITORY_URL);

  Future<String> _downloadSourceCode(String url) async {
    return (await http.get(Uri.parse(url))).body;
  }

  Future<List<ApiClient>> getMangaConfigs() async {
    return await Future.wait(
        (await _repository.getMangaConfigs(ORG, REPOSITORY)).map((e) async =>
            ApiClient(code: await _downloadSourceCode(e.download_url))));
  }

  Future<List<ApiClient>> getLocalMangaConfigs() async {
    return await Future.wait((await _localRepository.getMangaConfigs())
        .map((e) async => ApiClient(code: await _downloadSourceCode(e))));
  }
}
