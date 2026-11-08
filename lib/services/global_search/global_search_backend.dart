import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/utils/image_headers.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';
import 'package:wakaranai/services/configs_service/session_failure_classifier.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

class GlobalSearchHit {
  const GlobalSearchHit({
    required this.items,
    this.client,
    this.config,
    this.coverHeaders = const <String, Map<String, String>>{},
  });

  final List<GalleryView> items;
  final ApiClient? client;
  final ConfigInfo? config;
  final Map<String, Map<String, String>> coverHeaders;
}

class GlobalSearchSourceUnavailable implements Exception {
  const GlobalSearchSourceUnavailable(this.sourceName);

  final String sourceName;

  @override
  String toString() => 'GlobalSearchSourceUnavailable($sourceName)';
}

abstract class GlobalSearchBackend {
  Future<bool> needsSignIn(GlobalSearchSource source);

  Future<GlobalSearchHit> search(GlobalSearchSource source, String query);

  Future<BaseExtension> openable(GlobalSearchSource source);

  Future<void> dispose();
}

typedef StoredSessionCheck = Future<bool> Function(ConfigInfo config);

Future<bool> _hasStoredProtectorSession(ConfigInfo config) async {
  final ProtectorStorageItem? stored =
      await ProtectorStorageService().getItemForConfig(config);
  return stored != null;
}

class PooledGlobalSearchBackend implements GlobalSearchBackend {
  PooledGlobalSearchBackend({
    required this.extensionRepository,
    required this.resolver,
    PreparedClientPool? pool,
    StoredSessionCheck? hasStoredSession,
  })  : _pool = pool ?? PreparedClientPool(),
        _hasStoredSession = hasStoredSession ?? _hasStoredProtectorSession;

  final ExtensionRepository extensionRepository;
  final ExtensionResolver resolver;
  final PreparedClientPool _pool;
  final StoredSessionCheck _hasStoredSession;

  @override
  Future<bool> needsSignIn(GlobalSearchSource source) async {
    if (!source.hasProtector) {
      return false;
    }
    return !await _hasStoredSession(source.config);
  }

  @override
  Future<GlobalSearchHit> search(
    GlobalSearchSource source,
    String query,
  ) async {
    final ExtensionDomain extension = await _extensionFor(source);
    final ConfigInfo config = extension.config;
    final int challengesBefore = _pool.challengeCount(config.uid);
    try {
      final ApiClient client = await _pool.clientFor(extension);
      final List<GalleryView> items = await runSerializedOn(
        client,
        () => client.getGallery(page: 1, query: query),
      );
      return GlobalSearchHit(
        items: items,
        client: client,
        config: config,
        coverHeaders: await _coverHeaders(client, items),
      );
    } catch (error) {
      final SourceNeedsAttention? attention = SessionFailureClassifier.classify(
        error,
        config,
        challengeObserved: _pool.challengeCount(config.uid) > challengesBefore,
      );
      if (attention != null) {
        throw attention;
      }
      rethrow;
    }
  }

  @override
  Future<BaseExtension> openable(GlobalSearchSource source) {
    return _extensionFor(source);
  }

  Future<Map<String, Map<String, String>>> _coverHeaders(
    ApiClient client,
    List<GalleryView> items,
  ) async {
    final Map<String, Map<String, String>> headers =
        <String, Map<String, String>>{};
    for (final GalleryView item in items) {
      try {
        headers[item.uid] = await runSerializedOn(
          client,
          () => client.imageHeadersOrEmpty(uid: item.uid, data: item.data),
        );
      } catch (e) {
        logger.w('Cover headers are unavailable for a search result: $e');
        break;
      }
    }
    return headers;
  }

  Future<ExtensionDomain> _extensionFor(GlobalSearchSource source) async {
    final BaseExtension extension = source.extension;
    if (extension is ExtensionDomain) {
      return extension;
    }
    final ExtensionDomain? cached =
        await extensionRepository.getByUid(source.uid);
    if (cached != null) {
      return cached;
    }
    final ConfigsService? service = source.configsService;
    if (extension is RemoteConfig && service != null) {
      return _install(extension, service);
    }
    final ExtensionDomain? resolved = await resolver.resolve(source.uid);
    if (resolved == null) {
      throw GlobalSearchSourceUnavailable(source.name);
    }
    return resolved;
  }

  Future<ExtensionDomain> _install(
    RemoteConfig remote,
    ConfigsService service,
  ) async {
    if (remote.compatibility.requiresNewerApp) {
      throw GlobalSearchSourceUnavailable(remote.config.name.trim());
    }
    final String script = (await service.getRemoteScript(remote.path)).script;
    final ExtensionDomain domain = ExtensionDomain(
      id: 0,
      config: remote.config,
      sourceCode: script,
      revision: remote.revision,
      createdAt: DateTime.now(),
    );
    return await extensionRepository.createUpdateByUid(domain) ?? domain;
  }

  @override
  Future<void> dispose() {
    return _pool.dispose();
  }
}
