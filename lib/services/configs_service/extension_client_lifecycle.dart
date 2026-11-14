import 'package:capyscript/api_clients/api_client.dart';

class ExtensionClientLifecycle {
  ExtensionClientLifecycle._();

  static final ExtensionClientLifecycle instance = ExtensionClientLifecycle._();

  final Map<String, List<WeakReference<ApiClient>>> _clients =
      <String, List<WeakReference<ApiClient>>>{};

  void track(String extensionUid, ApiClient client) {
    final List<WeakReference<ApiClient>> clients =
        _clients.putIfAbsent(extensionUid, () => <WeakReference<ApiClient>>[]);
    clients.removeWhere((WeakReference<ApiClient> ref) => ref.target == null);
    clients.add(WeakReference<ApiClient>(client));
  }

  int reset(String extensionUid) {
    final List<WeakReference<ApiClient>>? clients = _clients[extensionUid];
    if (clients == null) {
      return 0;
    }
    int resetCount = 0;
    for (final WeakReference<ApiClient> ref in clients) {
      final ApiClient? client = ref.target;
      if (client == null) {
        continue;
      }
      client.resetLifecycle();
      resetCount++;
    }
    clients.removeWhere((WeakReference<ApiClient> ref) => ref.target == null);
    if (clients.isEmpty) {
      _clients.remove(extensionUid);
    }
    return resetCount;
  }
}
