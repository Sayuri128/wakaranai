import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_pagination/gallery_pagination.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';

bool hasExtensionSettings(ConfigInfo config) {
  return editablePreferences(config).isNotEmpty ||
      extensionMirrors(config).isNotEmpty ||
      config.pagination != null;
}

bool _isReservedPreferenceKey(String key) {
  return key == ExtensionPreference.mirrorKey ||
      key == ExtensionPreference.pageSizeKey;
}

List<String> extensionMirrors(ConfigInfo config) {
  final List<String> mirrors = <String>[];
  for (final String mirror in config.requestPolicy?.mirrors ?? <String>[]) {
    final String trimmed = mirror.trim();
    if (trimmed.isNotEmpty && !mirrors.contains(trimmed)) {
      mirrors.add(trimmed);
    }
  }
  return mirrors;
}

List<ExtensionPreference> editablePreferences(ConfigInfo config) {
  return config.preferences
      .where((ExtensionPreference preference) =>
          !_isReservedPreferenceKey(preference.key))
      .toList();
}

class ExtensionPreferenceValues {
  const ExtensionPreferenceValues._();

  static Object? sanitize(ExtensionPreference definition, Object? stored) {
    switch (definition.type) {
      case ExtensionPreferenceType.toggle:
        return stored is bool ? stored : null;
      case ExtensionPreferenceType.select:
        return _sanitizeSelect(definition, stored);
      case ExtensionPreferenceType.multiselect:
        return _sanitizeMultiselect(definition, stored);
      case ExtensionPreferenceType.text:
        return _sanitizeText(stored);
      case ExtensionPreferenceType.number:
        return stored is num ? stored : null;
    }
  }

  static String? sanitizeMirror(List<String> mirrors, Object? stored) {
    if (stored is String && mirrors.contains(stored)) {
      return stored;
    }
    return null;
  }

  static int? sanitizePageSize(GalleryPagination? pagination, Object? stored) {
    if (pagination == null || stored is! int) {
      return null;
    }
    if (pagination.pageSizes.contains(stored)) {
      return stored;
    }
    return null;
  }

  static Object? effectiveValue(ExtensionPreference definition, Object? stored) {
    return sanitize(definition, stored) ?? definition.effectiveDefault;
  }

  static num? parseNumber(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final int? integer = int.tryParse(trimmed);
    if (integer != null) {
      return integer;
    }
    final double? decimal = double.tryParse(trimmed);
    if (decimal == null || !decimal.isFinite) {
      return null;
    }
    return decimal;
  }

  static String formatNumber(num value) {
    if (value is double && value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  static String? _sanitizeText(Object? stored) {
    if (stored is! String || stored.trim().isEmpty) {
      return null;
    }
    return stored;
  }

  static String? _sanitizeSelect(
    ExtensionPreference definition,
    Object? stored,
  ) {
    if (stored is! String) {
      return null;
    }
    if (definition.options.isEmpty || _hasOption(definition, stored)) {
      return stored;
    }
    return null;
  }

  static List<String>? _sanitizeMultiselect(
    ExtensionPreference definition,
    Object? stored,
  ) {
    if (stored is! List) {
      return null;
    }
    final List<String> values = stored.map((Object? item) => '$item').toList();
    if (definition.options.isEmpty) {
      return values;
    }
    return values
        .where((String value) => _hasOption(definition, value))
        .toList();
  }

  static bool _hasOption(ExtensionPreference definition, String value) {
    return definition.options
        .any((ExtensionPreferenceOption option) => option.value == value);
  }
}
