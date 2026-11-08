import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';

class InstalledAppVersion {
  static String? _loaded;

  static Future<void> load({
    Future<PackageInfo> Function()? readPackageInfo,
  }) async {
    try {
      final PackageInfo info =
          await (readPackageInfo ?? PackageInfo.fromPlatform)();
      _loaded = normalize(info.version);
    } catch (error) {
      logger.w('Could not read the installed app version: $error');
    }
  }

  static String? get current {
    final String? loaded = _loaded;
    if (loaded != null) {
      return loaded;
    }
    return normalize(_envFallback());
  }

  static String? normalize(String? raw) {
    final AppVersion? parsed = AppVersion.tryParse(raw);
    if (parsed == null) {
      return null;
    }
    return parsed.toString();
  }

  static String? _envFallback() {
    try {
      final String value = Env.currentAppVersion.trim();
      if (value.isEmpty) {
        return null;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  static void reset() {
    _loaded = null;
  }
}
