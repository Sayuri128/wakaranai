import 'package:dio/dio.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/configs_repository/local/local_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/logger.dart';

class RepoConfigsService implements ConfigsService {
  late final LocalConfigsRepository _localRepository;

  RepoConfigsService({String? url}) {
    _localRepository =
        LocalConfigsRepository(Dio(), baseUrl: url ?? Env.LOCAL_REPOSITORY_URL);
  }

  @override
  Future<List<MangaApiClient>> getMangaConfigs() async {
    return await Future.wait((await _localRepository.getConfigs())
        .scripts
        .where((e) => e.category == 'manga')
        .first
        .scripts
        .map((e) async {
      logger.d(e);
      return MangaApiClient(code: e);
    }));
  }

  @override
  Future<List<AnimeApiClient>> getAnimeConfigs() async {
    return await Future.wait((await _localRepository.getConfigs())
        .scripts
        .where((e) => e.category == 'anime')
        .first
        .scripts
        .map((e) async => AnimeApiClient(code: e)));
  }
}
