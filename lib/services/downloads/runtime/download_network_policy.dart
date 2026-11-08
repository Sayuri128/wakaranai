import 'dart:async';

import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/runtime/network_monitor.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

typedef WifiOnlyPreferenceReader = Future<bool> Function();

class DownloadNetworkPolicy {
  DownloadNetworkPolicy({
    required this.monitor,
    required this.readWifiOnly,
  });

  factory DownloadNetworkPolicy.platform() {
    final NetworkMonitor monitor = createNetworkMonitor();
    if (monitor is UnrestrictedNetworkMonitor) {
      return DownloadNetworkPolicy(
        monitor: monitor,
        readWifiOnly: () async => false,
      );
    }
    return DownloadNetworkPolicy(
      monitor: monitor,
      readWifiOnly: SettingsService().getDownloadWifiOnly,
    );
  }

  final NetworkMonitor monitor;
  final WifiOnlyPreferenceReader readWifiOnly;

  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  StreamSubscription<NetworkConnection>? _subscription;
  Future<void>? _starting;
  bool _wifiOnly = false;
  bool _wifiOnlyChanged = false;
  NetworkConnection _connection = NetworkConnection.wifi;
  bool _disposed = false;

  bool get wifiOnly => _wifiOnly;

  NetworkConnection get connection => _connection;

  bool get allowsDownloads =>
      !_wifiOnly || _connection == NetworkConnection.wifi;

  Stream<bool> get changes => _changes.stream;

  Future<void> start() => _starting ??= _load();

  void setWifiOnly(bool value) {
    _wifiOnlyChanged = true;
    _update(() => _wifiOnly = value);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _changes.close();
  }

  Future<void> _load() async {
    final bool storedWifiOnly = await _readStoredWifiOnly();
    final NetworkConnection connection = await monitor.current();
    if (_disposed) {
      return;
    }
    _update(() {
      if (!_wifiOnlyChanged) {
        _wifiOnly = storedWifiOnly;
      }
      _connection = connection;
    });
    _subscription = monitor.changes.listen(
      _onConnection,
      onError: (Object error) {
        logger.w('Network state updates failed: $error');
      },
    );
  }

  Future<bool> _readStoredWifiOnly() async {
    try {
      return await readWifiOnly();
    } catch (error) {
      logger.w('Could not read the Wi-Fi only download setting: $error');
      return false;
    }
  }

  void _onConnection(NetworkConnection connection) {
    _update(() => _connection = connection);
  }

  void _update(void Function() change) {
    final bool allowedBefore = allowsDownloads;
    change();
    final bool allowedNow = allowsDownloads;
    if (allowedBefore == allowedNow || _changes.isClosed) {
      return;
    }
    _changes.add(allowedNow);
  }
}
