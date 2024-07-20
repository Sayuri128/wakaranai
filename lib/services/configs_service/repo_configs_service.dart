import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/env.dart';
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
        .where((RemoteConfig element) =>
            element.config.type == ConfigInfoType.MANGA)
        .toList();
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    return (await _localRepository.getConfigs("anime"))
        .configs
        .where((RemoteConfig element) =>
            element.config.type == ConfigInfoType.ANIME)
        .toList();
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    return _localRepository.getScript(path);
  }
}
