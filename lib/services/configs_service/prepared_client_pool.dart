import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';

class PreparedClientPool {
  static const Duration _interceptorTimeout = Duration(seconds: 30);

  final Map<String, Future<ApiClient>> _clients = <String, Future<ApiClient>>{};
  final Map<String, BrowserInterceptorCubit> _interceptors =
      <String, BrowserInterceptorCubit>{};

  bool get isEmpty => _clients.isEmpty;

  Future<ApiClient> clientFor(ExtensionDomain extension) {
    final String uid = extension.config.uid;
    final Future<ApiClient>? existing = _clients[uid];
    if (existing != null) {
      return existing;
    }
    final Future<ApiClient> created = _buildAndPrepare(extension);
    _clients[uid] = created;
    unawaited(created.then<void>(
      (ApiClient client) {},
      onError: (Object error) {
        if (identical(_clients[uid], created)) {
          _clients.remove(uid);
        }
      },
    ));
    return created;
  }

  Future<ApiClient> _buildAndPrepare(ExtensionDomain extension) async {
    late final ApiClient client;
    switch (extension.config.type) {
      case ConfigInfoType.ANIME:
        client = AnimeApiClient(code: extension.sourceCode);
        break;
      case ConfigInfoType.MANGA:
        client = MangaApiClient(code: extension.sourceCode);
        break;
    }
    await _prepare(client, extension.config);
    return client;
  }

  Future<void> _prepare(ApiClient client, ConfigInfo config) async {
    final ProtectorConfig? protector = config.protectorConfig;
    if (protector == null) {
      return;
    }

    if (protector.inAppBrowserInterceptor) {
      final Completer<bool> ready = Completer<bool>();
      final BrowserInterceptorCubit interceptor = BrowserInterceptorCubit();
      unawaited(interceptor.init(url: protector.pingUrl, initCompleter: ready));
      await _interceptors[config.uid]?.close();
      _interceptors[config.uid] = interceptor;

      await client.passWebBrowserInterceptorController(controller: interceptor);
      await ready.future.timeout(_interceptorTimeout);
    }

    final ProtectorStorageItem? stored =
        await ProtectorStorageService().getItemForConfig(config);
    if (stored == null) {
      throw Exception('Protector for ${config.name} has not been passed yet');
    }

    await client.passProtector(
      cookies: stored.data.cookies,
      headers: stored.data.headers,
      body: stored.data.body,
    );
  }

  Future<void> dispose() async {
    for (final BrowserInterceptorCubit interceptor in _interceptors.values) {
      try {
        await interceptor.close();
      } catch (e) {
        logger.w('Failed to close browser interceptor: $e');
      }
    }
    _interceptors.clear();
    _clients.clear();
  }
}
