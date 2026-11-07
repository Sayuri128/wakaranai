import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/repositories/shared_pref/auto_backup_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/downloads_order_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/gallery_layout_preferences.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

class ExportedPreferences {
  static const List<String> keyPrefixes = <String>[
    'PLAYER_',
    'PAGE_TRANSLATION_',
  ];

  static const Set<String> exactKeys = <String>{
    SettingsService.videoPlayerPreferencePrefsKey,
    SettingsService.checkUpdatesPrefsKey,
    SettingsService.updateNotificationsPrefsKey,
    SettingsService.updateFrequencyPrefsKey,
    SettingsService.downloadWifiOnlyPrefsKey,
    GalleryLayoutPreferences.galleryKey,
    GalleryLayoutPreferences.libraryKey,
    DownloadsOrderPreferences.newestFirstKey,
    DownloadStoragePreferences.qualityKey,
    DownloadStoragePreferences.deleteAfterWatchingKey,
    AutoBackupPreferences.enabledKey,
  };

  static bool isExportable(String key) {
    if (exactKeys.contains(key)) {
      return true;
    }
    return keyPrefixes.any((String prefix) => key.startsWith(prefix));
  }

  static List<ExportPreference> collect(SharedPreferences preferences) {
    final List<String> keys =
        preferences.getKeys().where(isExportable).toList()..sort();
    final List<ExportPreference> entries = <ExportPreference>[];
    for (final String key in keys) {
      final ExportPreference? entry = _entryFor(key, preferences.get(key));
      if (entry != null) {
        entries.add(entry);
      }
    }
    return entries;
  }

  static Future<int> apply(
    SharedPreferences preferences,
    List<ExportPreference> entries,
  ) async {
    int applied = 0;
    for (final ExportPreference entry in entries) {
      if (!isExportable(entry.key)) {
        continue;
      }
      if (await _write(preferences, entry)) {
        applied++;
      }
    }
    return applied;
  }

  static ExportPreference? _entryFor(String key, Object? value) {
    if (value is bool) {
      return ExportPreference(
        key: key,
        type: ExportPreference.boolType,
        value: value,
      );
    }
    if (value is int) {
      return ExportPreference(
        key: key,
        type: ExportPreference.intType,
        value: value,
      );
    }
    if (value is double) {
      return ExportPreference(
        key: key,
        type: ExportPreference.doubleType,
        value: value,
      );
    }
    if (value is String) {
      return ExportPreference(
        key: key,
        type: ExportPreference.stringType,
        value: value,
      );
    }
    if (value is List) {
      return ExportPreference(
        key: key,
        type: ExportPreference.stringListType,
        value: value.map((Object? item) => item.toString()).toList(),
      );
    }
    return null;
  }

  static Future<bool> _write(
    SharedPreferences preferences,
    ExportPreference entry,
  ) async {
    final Object? value = entry.value;
    switch (entry.type) {
      case ExportPreference.boolType:
        if (value is bool) {
          return preferences.setBool(entry.key, value);
        }
        return false;
      case ExportPreference.intType:
        if (value is num) {
          return preferences.setInt(entry.key, value.toInt());
        }
        return false;
      case ExportPreference.doubleType:
        if (value is num) {
          return preferences.setDouble(entry.key, value.toDouble());
        }
        return false;
      case ExportPreference.stringType:
        if (value is String) {
          return preferences.setString(entry.key, value);
        }
        return false;
      case ExportPreference.stringListType:
        if (value is List && value.every((Object? item) => item is String)) {
          return preferences.setStringList(
            entry.key,
            value.cast<String>().toList(),
          );
        }
        return false;
      default:
        return false;
    }
  }
}
