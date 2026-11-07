import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';

class DownloadClientPool {
  DownloadClientPool({
    required this.extensionRepository,
    this.idleTimeout = const Duration(minutes: 2),
  });

  final ExtensionRepository? extensionRepository;
  final Duration idleTimeout;
  final PreparedClientPool _clients = PreparedClientPool();
  Timer? _idleRelease;

  Future<ApiClient> chapterClientFor(ExtensionDomain extension) async {
    final ApiClient client = await _pooledClientFor(extension);
    if (client is MangaApiClient || client is NovelApiClient) {
      return client;
    }
    throw StateError('${extension.config.name} has no chapters to download');
  }

  Future<AnimeApiClient> animeClientFor(ExtensionDomain extension) async {
    final ApiClient client = await _pooledClientFor(extension);
    if (client is! AnimeApiClient) {
      throw StateError('${extension.config.name} is not an anime extension');
    }
    return client;
  }

  Future<AnimeApiClient> animeClientForUid(String extensionUid) async {
    final ExtensionDomain? extension = await installedExtension(extensionUid);
    if (extension == null) {
      throw StateError('Extension $extensionUid is not installed');
    }
    return animeClientFor(extension);
  }

  Future<ExtensionDomain?> installedExtension(String extensionUid) async {
    final ExtensionRepository? extensions = extensionRepository;
    if (extensions == null) {
      return null;
    }
    return extensions.getByUid(extensionUid);
  }

  void cancelIdleRelease() {
    _idleRelease?.cancel();
  }

  void scheduleIdleRelease({required bool Function() stillIdle}) {
    _idleRelease?.cancel();
    if (_clients.isEmpty) {
      return;
    }
    _idleRelease = Timer(idleTimeout, () {
      if (stillIdle()) {
        unawaited(_clients.dispose());
      }
    });
  }

  Future<void> dispose() async {
    _idleRelease?.cancel();
    await _clients.dispose();
  }

  Future<ApiClient> _pooledClientFor(ExtensionDomain extension) {
    _idleRelease?.cancel();
    return _clients.clientFor(extension);
  }
}
