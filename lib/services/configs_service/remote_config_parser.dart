import 'package:capyscript/capyscript_api_version.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';

class RemoteConfigParser {
  const RemoteConfigParser({
    this.supportedApiVersion = capyscriptApiVersion,
    this.appVersion,
  });

  final int supportedApiVersion;
  final String? appVersion;

  List<RemoteConfig> parseAll(Iterable<dynamic> entries) {
    final List<RemoteConfig> configs = <RemoteConfig>[];
    for (final dynamic entry in entries) {
      final RemoteConfig? parsed = parseEntry(entry);
      if (parsed != null) {
        configs.add(parsed);
      }
    }
    return configs;
  }

  RemoteConfig? parseEntry(dynamic entry) {
    if (entry is! Map) {
      logger.w('Skipping an extension entry that is not an object');
      return null;
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(entry);
    try {
      return RemoteConfig.fromJson(json);
    } catch (error) {
      final RemoteConfig? placeholder = _incompatiblePlaceholder(json);
      if (placeholder != null) {
        logger.i(
          'Listing ${placeholder.config.uid} as incompatible: '
          'it needs a newer app ($error)',
        );
        return placeholder;
      }
      logger.w('Skipping an unparseable extension entry ${_describe(json)}: $error');
      return null;
    }
  }

  RemoteConfig? _incompatiblePlaceholder(Map<String, dynamic> json) {
    final RemoteConfig? placeholder = _placeholderFrom(json);
    if (placeholder == null) {
      return null;
    }
    final ExtensionCompatibility compatibility = ExtensionCompatibility.check(
      placeholder.config,
      entryApiVersion: placeholder.apiVersion,
      entryMinAppVersion: placeholder.minAppVersion,
      supportedApiVersion: supportedApiVersion,
      appVersion: appVersion,
    );
    if (compatibility.isCompatible) {
      return null;
    }
    return placeholder;
  }

  static RemoteConfig? _placeholderFrom(Map<String, dynamic> json) {
    final Map<String, dynamic> rawConfig = _rawConfig(json);
    final String? path = _stringOrNull(json['path']);
    final String? uid = _stringOrNull(rawConfig['uid']);
    final ConfigInfoType? type = _typeOf(json, rawConfig, path);
    if (path == null || uid == null || type == null) {
      return null;
    }

    return RemoteConfig(
      path: path,
      revision: _stringOrNull(json['revision']),
      apiVersion: _intOrNull(json['apiVersion']),
      minAppVersion: _stringOrNull(json['minAppVersion']),
      config: ConfigInfo(
        uid: uid,
        name: _stringOrNull(rawConfig['name']) ?? uid,
        logoUrl: _stringOrNull(rawConfig['logoUrl']) ?? '',
        nsfw: rawConfig['nsfw'] == true,
        language: _stringOrNull(rawConfig['language']) ?? '',
        version: _intOrNull(rawConfig['version']) ?? 0,
        filters: const [],
        type: type,
        searchAvailable: false,
        apiVersion:
            _intOrNull(rawConfig['apiVersion']) ?? legacyExtensionApiVersion,
        minAppVersion: _stringOrNull(rawConfig['minAppVersion']),
      ),
    );
  }

  static Map<String, dynamic> _rawConfig(Map<String, dynamic> json) {
    final dynamic config = json['config'];
    if (config is Map) {
      return Map<String, dynamic>.from(config);
    }
    return <String, dynamic>{};
  }

  static ConfigInfoType? _typeOf(
    Map<String, dynamic> json,
    Map<String, dynamic> rawConfig,
    String? path,
  ) {
    final dynamic rawType = rawConfig['type'];
    if (rawType == 0) {
      return ConfigInfoType.MANGA;
    }
    if (rawType == 1) {
      return ConfigInfoType.ANIME;
    }
    if (rawType == 2) {
      return ConfigInfoType.NOVEL;
    }
    final String category =
        _stringOrNull(json['category']) ?? path?.split('/').first ?? '';
    if (category == 'manga') {
      return ConfigInfoType.MANGA;
    }
    if (category == 'anime') {
      return ConfigInfoType.ANIME;
    }
    if (category == 'novel' || category == 'novels') {
      return ConfigInfoType.NOVEL;
    }
    return null;
  }

  static String _describe(Map<String, dynamic> json) {
    final Map<String, dynamic> rawConfig = _rawConfig(json);
    return _stringOrNull(rawConfig['uid']) ??
        _stringOrNull(json['path']) ??
        '(unknown)';
  }

  static int? _intOrNull(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static String? _stringOrNull(dynamic value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
