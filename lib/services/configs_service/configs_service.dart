import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';

abstract class ConfigsService {
  Future<List<BaseExtension>> getMangaConfigs();
  Future<List<BaseExtension>> getAnimeConfigs();

  Future<RemoteScript> getRemoteScript(String path);
}
