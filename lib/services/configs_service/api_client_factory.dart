import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';

class ExtensionHostFactory {
  const ExtensionHostFactory();

  ExtensionPreferencesProvider preferencesFor(ConfigInfo config) {
    return const NoopExtensionPreferencesProvider();
  }

  ExtensionStorage storageFor(ConfigInfo config) {
    return const NoopExtensionStorage();
  }

  ExtensionHost hostFor(ConfigInfo config) {
    return ExtensionHost(
      extensionUid: config.uid,
      preferenceDefinitions: config.preferences,
      preferences: preferencesFor(config),
      storage: storageFor(config),
      requestPolicy: config.requestPolicy,
    );
  }
}

class ApiClientFactory {
  ApiClientFactory({this.hostFactory = const ExtensionHostFactory()});

  static ApiClientFactory instance = ApiClientFactory();

  final ExtensionHostFactory hostFactory;

  ApiClient create({required ConfigInfo config, required String code}) {
    switch (config.type) {
      case ConfigInfoType.ANIME:
        return anime(config: config, code: code);
      case ConfigInfoType.MANGA:
        return manga(config: config, code: code);
    }
  }

  MangaApiClient manga({required ConfigInfo config, required String code}) {
    return MangaApiClient(code: code, host: hostFactory.hostFor(config));
  }

  AnimeApiClient anime({required ConfigInfo config, required String code}) {
    return AnimeApiClient(code: code, host: hostFactory.hostFor(config));
  }
}
