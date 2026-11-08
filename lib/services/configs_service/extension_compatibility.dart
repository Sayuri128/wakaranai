import 'dart:math' as math;

import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/utils/installed_app_version.dart';

enum ExtensionIncompatibility { apiVersion, minAppVersion }

class ExtensionCompatibility {
  const ExtensionCompatibility._({
    this.incompatibility,
    required this.requiredApiVersion,
    required this.supportedApiVersion,
    this.requiredAppVersion,
    this.currentAppVersion,
  });

  final ExtensionIncompatibility? incompatibility;
  final int requiredApiVersion;
  final int supportedApiVersion;
  final String? requiredAppVersion;
  final String? currentAppVersion;

  bool get isCompatible => incompatibility == null;

  bool get requiresNewerApp => incompatibility != null;

  static int effectiveApiVersion(ConfigInfo config, {int? entryApiVersion}) {
    return math.max(
      config.apiVersion,
      entryApiVersion ?? legacyExtensionApiVersion,
    );
  }

  static String? effectiveMinAppVersion(
    ConfigInfo config, {
    String? entryMinAppVersion,
  }) {
    final String? configValue = _nonBlank(config.minAppVersion);
    if (configValue != null) {
      return configValue;
    }
    return _nonBlank(entryMinAppVersion);
  }

  static ExtensionCompatibility check(
    ConfigInfo config, {
    int? entryApiVersion,
    String? entryMinAppVersion,
    int supportedApiVersion = capyscriptApiVersion,
    String? appVersion,
  }) {
    return evaluate(
      apiVersion: effectiveApiVersion(config, entryApiVersion: entryApiVersion),
      minAppVersion: effectiveMinAppVersion(
        config,
        entryMinAppVersion: entryMinAppVersion,
      ),
      supportedApiVersion: supportedApiVersion,
      appVersion: appVersion,
    );
  }

  static ExtensionCompatibility evaluate({
    required int apiVersion,
    String? minAppVersion,
    int supportedApiVersion = capyscriptApiVersion,
    String? appVersion,
  }) {
    final String? currentAppVersion =
        appVersion ?? InstalledAppVersion.current;
    final ExtensionIncompatibility? incompatibility = _findIncompatibility(
      apiVersion: apiVersion,
      minAppVersion: minAppVersion,
      supportedApiVersion: supportedApiVersion,
      currentAppVersion: currentAppVersion,
    );
    return ExtensionCompatibility._(
      incompatibility: incompatibility,
      requiredApiVersion: apiVersion,
      supportedApiVersion: supportedApiVersion,
      requiredAppVersion: minAppVersion,
      currentAppVersion: currentAppVersion,
    );
  }

  static ExtensionIncompatibility? _findIncompatibility({
    required int apiVersion,
    required String? minAppVersion,
    required int supportedApiVersion,
    required String? currentAppVersion,
  }) {
    if (apiVersion > supportedApiVersion) {
      return ExtensionIncompatibility.apiVersion;
    }
    if (_isAppTooOld(minAppVersion, currentAppVersion)) {
      return ExtensionIncompatibility.minAppVersion;
    }
    return null;
  }

  static bool _isAppTooOld(String? minAppVersion, String? currentAppVersion) {
    final AppVersion? required = AppVersion.tryParse(minAppVersion);
    final AppVersion? current = AppVersion.tryParse(currentAppVersion);
    if (required == null || current == null) {
      return false;
    }
    return current < required;
  }


  static String? _nonBlank(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class ExtensionRequiresNewerAppException implements Exception {
  const ExtensionRequiresNewerAppException({
    required this.extensionName,
    required this.compatibility,
  });

  final String extensionName;
  final ExtensionCompatibility compatibility;

  @override
  String toString() {
    return 'Extension $extensionName requires a newer app version';
  }
}
