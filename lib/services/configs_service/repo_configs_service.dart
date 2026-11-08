import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/utils/http_client.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/configs_repository/local/local_configs_repository.dart';
import 'package:wakaranai/services/configs_service/capyscript_import_bundler.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';

class RepoConfigsService implements ConfigsService {
  late final LocalConfigsRepository _localRepository;

  RepoConfigsService({String? url}) {
    _localRepository =
        LocalConfigsRepository(createDio(), baseUrl: url ?? Env.localRepoUrl);
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
  Future<List<RemoteConfig>> getNovelConfigs() async {
    return (await _localRepository.getConfigs("novel"))
        .configs
        .where((RemoteConfig element) =>
            element.config.type == ConfigInfoType.NOVEL)
        .toList();
  }

  @override
  Future<List<RemoteConfig>> getAudioConfigs() async {
    return (await _localRepository.getConfigs("audio"))
        .configs
        .where((RemoteConfig element) =>
            element.config.type == ConfigInfoType.AUDIO)
        .toList();
  }

  @override
  void invalidate() {}

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    return CapyscriptImportBundler.bundle(
      entryPath: path,
      fetchScript: (String scriptPath) => _localRepository.getScript(scriptPath),
    );
  }
}
