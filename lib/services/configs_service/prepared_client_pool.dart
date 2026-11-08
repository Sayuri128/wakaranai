import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';

class PreparedClientPool {
  static const Duration _interceptorTimeout = Duration(seconds: 30);

  final Map<String, Future<ApiClient>> _clients = <String, Future<ApiClient>>{};
  final Map<String, BrowserInterceptorCubit> _interceptors =
      <String, BrowserInterceptorCubit>{};
  final Map<String, StreamSubscription<BrowserInterceptorState>>
      _interceptorSubscriptions =
      <String, StreamSubscription<BrowserInterceptorState>>{};
  final Map<String, int> _challengeCounts = <String, int>{};

  bool get isEmpty => _clients.isEmpty;

  int challengeCount(String extensionUid) {
    return _challengeCounts[extensionUid] ?? 0;
  }

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
    final ApiClient client = ApiClientFactory.instance
        .create(config: extension.config, code: extension.sourceCode);
    await _prepare(client, extension.config);
    return client;
  }

  Future<void> _prepare(ApiClient client, ConfigInfo config) async {
    final ProtectorConfig? protector = config.protectorConfig;
    if (protector == null) {
      return;
    }

    if (protector.inAppBrowserInterceptor) {
      await _startInterceptor(client, config, protector);
    }

    final ProtectorStorageItem? stored =
        await ProtectorStorageService().getItemForConfig(config);
    if (stored == null) {
      throw SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.notSignedIn,
      );
    }

    await client.passProtector(
      cookies: stored.data.cookies,
      headers: stored.data.headers,
      body: stored.data.body,
    );
  }

  Future<void> _startInterceptor(
    ApiClient client,
    ConfigInfo config,
    ProtectorConfig protector,
  ) async {
    final String uid = config.uid;
    final Completer<bool> ready = Completer<bool>();
    final BrowserInterceptorCubit interceptor =
        BrowserInterceptorCubit.forProtector(protector);
    final int challengesBefore = challengeCount(uid);

    await _closeInterceptor(uid);
    _interceptors[uid] = interceptor;
    _interceptorSubscriptions[uid] = interceptor.stream.listen(
      (BrowserInterceptorState state) {
        if (state is BrowserInterceptorChallengeRequired) {
          _challengeCounts[uid] = challengeCount(uid) + 1;
        }
      },
    );
    unawaited(interceptor.init(url: protector.pingUrl, initCompleter: ready));

    await client.passWebBrowserInterceptorController(controller: interceptor);
    final bool passed = await ready.future.timeout(_interceptorTimeout);
    if (passed) {
      return;
    }
    final bool challenged = challengeCount(uid) > challengesBefore ||
        interceptor.state is BrowserInterceptorChallengeRequired;
    if (challenged) {
      await _closeInterceptor(uid);
      throw SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.challengeRequired,
      );
    }
    logger.w(
      'Browser interceptor for ${config.name} could not load its ping page',
    );
  }

  Future<void> _closeInterceptor(String uid) async {
    await _interceptorSubscriptions.remove(uid)?.cancel();
    final BrowserInterceptorCubit? previous = _interceptors.remove(uid);
    if (previous == null) {
      return;
    }
    try {
      await previous.close();
    } catch (e) {
      logger.w('Failed to close browser interceptor: $e');
    }
  }

  Future<void> dispose() async {
    for (final StreamSubscription<BrowserInterceptorState> subscription
        in _interceptorSubscriptions.values) {
      await subscription.cancel();
    }
    _interceptorSubscriptions.clear();
    for (final BrowserInterceptorCubit interceptor in _interceptors.values) {
      try {
        await interceptor.close();
      } catch (e) {
        logger.w('Failed to close browser interceptor: $e');
      }
    }
    _interceptors.clear();
    _clients.clear();
    _challengeCounts.clear();
  }
}
