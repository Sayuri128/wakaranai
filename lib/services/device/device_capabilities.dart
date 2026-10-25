import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wakaranai/main.dart';

enum OnDeviceAiIssue { notAndroid, androidTooOld, not64Bit, lowMemory }

class DeviceInfo {
  const DeviceInfo({
    required this.sdkInt,
    required this.totalRamBytes,
    required this.abis,
    required this.model,
  });

  final int sdkInt;
  final int totalRamBytes;
  final List<String> abis;
  final String model;

  double get totalRamGb => totalRamBytes / (1 << 30);
}

class OnDeviceAiSupport {
  const OnDeviceAiSupport({
    required this.issues,
    this.device,
    this.minRamGb = defaultMinRamGb,
  });

  final List<OnDeviceAiIssue> issues;
  final DeviceInfo? device;
  final double minRamGb;

  bool get supported => issues.isEmpty;

  static const int minSdk = 30;
  static const double defaultMinRamGb = 7;
  static const String requiredAbi = 'arm64-v8a';

  static OnDeviceAiSupport evaluate(
    DeviceInfo device, {
    double minRamGb = defaultMinRamGb,
  }) {
    return OnDeviceAiSupport(
      device: device,
      minRamGb: minRamGb,
      issues: <OnDeviceAiIssue>[
        if (device.sdkInt < minSdk) OnDeviceAiIssue.androidTooOld,
        if (!device.abis.contains(requiredAbi)) OnDeviceAiIssue.not64Bit,
        if (device.totalRamGb < minRamGb) OnDeviceAiIssue.lowMemory,
      ],
    );
  }
}

class DeviceCapabilities {
  static const MethodChannel _channel = MethodChannel('wakaranai/device');

  static Future<DeviceInfo?>? _device;

  static Future<OnDeviceAiSupport> onDeviceAi({
    double minRamGb = OnDeviceAiSupport.defaultMinRamGb,
  }) async {
    final DeviceInfo? device = await (_device ??= _loadDevice());
    if (device == null) {
      return _unsupportedPlatform;
    }
    return OnDeviceAiSupport.evaluate(device, minRamGb: minRamGb);
  }

  static const OnDeviceAiSupport _unsupportedPlatform = OnDeviceAiSupport(
    issues: <OnDeviceAiIssue>[OnDeviceAiIssue.notAndroid],
  );

  static Future<DeviceInfo?> _loadDevice() async {
    if (!Platform.isAndroid) {
      return null;
    }
    try {
      final Map<dynamic, dynamic>? info = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('deviceInfo');
      return _parseDeviceInfo(info ?? const <dynamic, dynamic>{});
    } catch (e) {
      logger.w('Device info unavailable: $e');
      return null;
    }
  }

  static DeviceInfo _parseDeviceInfo(Map<dynamic, dynamic> info) {
    final num? totalRam = info['totalRam'] as num?;
    final List<dynamic> abis =
        info['abis'] as List<dynamic>? ?? const <dynamic>[];
    return DeviceInfo(
      sdkInt: info['sdkInt'] as int? ?? 0,
      totalRamBytes: totalRam?.toInt() ?? 0,
      abis: abis.cast<String>(),
      model: info['model'] as String? ?? '',
    );
  }
}
