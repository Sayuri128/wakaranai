import 'package:dio/dio.dart';
import 'package:wakaranai/models/github/repository/content/github_repository_content.dart';
import 'package:wakaranai/repositories/configs_repository/configs_repository.dart';
import 'package:http/http.dart' as http;

class ConfigsService {
  static const String ORG = 'KoneruHodl';
  static const String REPOSITORY = 'wakaranai_configs';

  final ConfigsRepository _repository = ConfigsRepository(Dio());

  Future<List<String>> getMangaConfigs() async {
    return await Future.wait((await _repository.getMangaConfigs(ORG, REPOSITORY))
        .map((e) async => (await http.get(Uri.parse(e.download_url))).body));
  }
}
