import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/main.dart';

const String kNetworkChannel = 'wakaranai/network';
const String kNetworkChangesChannel = 'wakaranai/network/changes';

enum NetworkConnection { wifi, cellular, offline, other }

abstract class NetworkMonitor {
  Future<NetworkConnection> current();

  Stream<NetworkConnection> get changes;
}

NetworkMonitor createNetworkMonitor() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return MethodChannelNetworkMonitor();
  }
  return UnrestrictedNetworkMonitor();
}

class UnrestrictedNetworkMonitor implements NetworkMonitor {
  @override
  Future<NetworkConnection> current() async => NetworkConnection.wifi;

  @override
  Stream<NetworkConnection> get changes =>
      const Stream<NetworkConnection>.empty();
}

class MethodChannelNetworkMonitor implements NetworkMonitor {
  MethodChannelNetworkMonitor({
    MethodChannel channel = const MethodChannel(kNetworkChannel),
    EventChannel changesChannel = const EventChannel(kNetworkChangesChannel),
  })  : _channel = channel,
        _changesChannel = changesChannel;

  final MethodChannel _channel;
  final EventChannel _changesChannel;

  @override
  Future<NetworkConnection> current() async {
    try {
      return parseNetworkConnection(
          await _channel.invokeMethod<String>('current'));
    } on MissingPluginException {
      return NetworkConnection.wifi;
    } catch (error) {
      logger.w('Failed to read the network state: $error');
      return NetworkConnection.other;
    }
  }

  @override
  Stream<NetworkConnection> get changes => _changesChannel
      .receiveBroadcastStream()
      .map((dynamic value) => parseNetworkConnection(value as String?));
}

NetworkConnection parseNetworkConnection(String? value) {
  switch (value) {
    case 'wifi':
      return NetworkConnection.wifi;
    case 'cellular':
      return NetworkConnection.cellular;
    case 'offline':
      return NetworkConnection.offline;
    default:
      return NetworkConnection.other;
  }
}
