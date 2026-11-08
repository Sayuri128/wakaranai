import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/repositories/database/extension_storage_repository.dart';
import 'package:wakaranai/services/extension_preferences/extension_host_services.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_manga_api_client.dart';
import 'package:wakaranai/services/local_source/local_novel_api_client.dart';
import 'package:wakaranai/services/local_source/local_source.dart';

class ExtensionHostFactory {
  const ExtensionHostFactory({this.preferenceStore, this.storageRepository});

  final ExtensionPreferencesStore? preferenceStore;
  final ExtensionStorageRepository? storageRepository;

  ExtensionPreferencesProvider preferencesFor(ConfigInfo config) {
    final ExtensionPreferencesStore? store = preferenceStore;
    if (store == null) {
      return const NoopExtensionPreferencesProvider();
    }
    return StoredExtensionPreferencesProvider(store: store, config: config);
  }

  ExtensionStorage storageFor(ConfigInfo config) {
    final ExtensionStorageRepository? repository = storageRepository;
    if (repository == null) {
      return const NoopExtensionStorage();
    }
    return DatabaseExtensionStorage(
      repository: repository,
      extensionUid: config.uid,
    );
  }

  ExtensionHost hostFor(ConfigInfo config) {
    return ExtensionHost(
      extensionUid: config.uid,
      preferenceDefinitions: config.preferences,
      preferences: preferencesFor(config),
      storage: storageFor(config),
      requestPolicy: config.requestPolicy,
      pagination: config.pagination,
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
      case ConfigInfoType.NOVEL:
        return novel(config: config, code: code);
    }
  }

  MangaApiClient manga({required ConfigInfo config, required String code}) {
    if (LocalSource.isLocal(config.uid)) {
      return LocalMangaApiClient(
        library: LocalSource.library,
        host: hostFactory.hostFor(config),
      );
    }
    return MangaApiClient(code: code, host: hostFactory.hostFor(config));
  }

  AnimeApiClient anime({required ConfigInfo config, required String code}) {
    return AnimeApiClient(code: code, host: hostFactory.hostFor(config));
  }

  NovelApiClient novel({required ConfigInfo config, required String code}) {
    if (LocalBooksSource.isLocal(config.uid)) {
      return LocalNovelApiClient(
        library: LocalBooksSource.library,
        host: hostFactory.hostFor(config),
      );
    }
    return NovelApiClient(code: code, host: hostFactory.hostFor(config));
  }
}
