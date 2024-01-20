import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/models/remote_script/remote_script.dart';

abstract class ConfigsService {
  Future<List<RemoteConfig>> getMangaConfigs();
  Future<List<RemoteConfig>> getAnimeConfigs();

  Future<RemoteScript> getRemoteScript(String path);
}
