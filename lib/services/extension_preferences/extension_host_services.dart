import 'package:capyscript/api_clients/host/extension_host.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_storage_repository.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/extension_preferences/extension_preference_values.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';

class StoredExtensionPreferencesProvider extends ExtensionPreferencesProvider {
  const StoredExtensionPreferencesProvider({
    required this.store,
    required this.config,
  });

  final ExtensionPreferencesStore store;
  final ConfigInfo config;

  @override
  Future<Object?> getPreference(String key) async {
    final Object? stored = await store.read(config.uid, key);
    if (stored == null) {
      return null;
    }
    if (key == ExtensionPreference.mirrorKey) {
      return ExtensionPreferenceValues.sanitizeMirror(
        extensionMirrors(config),
        stored,
      );
    }
    if (key == ExtensionPreference.pageSizeKey) {
      return ExtensionPreferenceValues.sanitizePageSize(
        config.pagination,
        stored,
      );
    }
    final ExtensionPreference? definition = _definition(key);
    if (definition == null) {
      return null;
    }
    return ExtensionPreferenceValues.sanitize(definition, stored);
  }

  ExtensionPreference? _definition(String key) {
    for (final ExtensionPreference definition in config.preferences) {
      if (definition.key == key) {
        return definition;
      }
    }
    return null;
  }
}

class DatabaseExtensionStorage extends ExtensionStorage {
  const DatabaseExtensionStorage({
    required this.repository,
    required this.extensionUid,
  });

  final ExtensionStorageRepository repository;
  final String extensionUid;

  @override
  Future<String?> read(String key) {
    return repository.read(extensionUid, key);
  }

  @override
  Future<void> write(String key, String value, {Duration? ttl}) {
    return repository.write(extensionUid, key, value, ttl: ttl);
  }

  @override
  Future<void> remove(String key) {
    return repository.remove(extensionUid, key);
  }
}

class ExtensionDataCleaner {
  ExtensionDataCleaner({
    required this.storageRepository,
    ExtensionPreferencesStore? preferenceStore,
  }) : preferenceStore = preferenceStore ?? ExtensionPreferencesStore.instance;

  final ExtensionStorageRepository storageRepository;
  final ExtensionPreferencesStore preferenceStore;

  Future<int> clearStorage(String extensionUid) {
    return storageRepository.clearExtension(extensionUid);
  }

  Future<void> forgetExtension(String extensionUid) async {
    await storageRepository.clearExtension(extensionUid);
    await preferenceStore.clearExtension(extensionUid);
  }
}

void configureExtensionHost(
  WakaranaiDatabase database, {
  ExtensionPreferencesStore? preferenceStore,
}) {
  ApiClientFactory.instance = ApiClientFactory(
    hostFactory: ExtensionHostFactory(
      preferenceStore: preferenceStore ?? ExtensionPreferencesStore.instance,
      storageRepository: ExtensionStorageRepository(database: database),
    ),
  );
}
