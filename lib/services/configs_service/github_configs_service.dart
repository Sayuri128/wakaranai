import 'package:dio/dio.dart';
import 'package:wakaranai/repositories/configs_repository/github/github_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakascript/api_controller.dart';
import 'package:http/http.dart' as http;

class GitHubConfigsService implements ConfigsService {
  static const String ORG = 'KoneruHodl';
  static const String REPOSITORY = 'waka-configs';

  final GithubConfigsRepository _repository = GithubConfigsRepository(Dio());

  Future<String> _downloadSourceCode(String url) async {
    return (await http.get(Uri.parse(url))).body;
  }

  @override
  Future<List<ApiClient>> getMangaConfigs() async {
    return await Future.wait(
        (await _repository.getMangaConfigs(ORG, REPOSITORY)).map((e) async =>
            ApiClient(code: await _downloadSourceCode(e.download_url))));
  }

}
