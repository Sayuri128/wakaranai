import 'package:dio/dio.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/models/remote_config/remote_category.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/models/remote_script/remote_script.dart';
import 'package:wakaranai/repositories/configs_repository/local/local_configs_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';

class RepoConfigsService implements ConfigsService {
  late final LocalConfigsRepository _localRepository;

  RepoConfigsService({String? url}) {
    _localRepository =
        LocalConfigsRepository(Dio(), baseUrl: url ?? Env.localRepoUrl);
  }

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async {
    return (await _localRepository.getConfigs("manga"))
        .configs
        .where((element) => element.category == RemoteCategory.manga)
        .toList();
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    return (await _localRepository.getConfigs("anime"))
        .configs
        .where((element) => element.category == RemoteCategory.anime)
        .toList();
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    return _localRepository.getScript(path);
  }
}
