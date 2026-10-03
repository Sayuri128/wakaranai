import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';

class ProtectorStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static String sessionKey(ConfigInfo config) =>
      config.protectorConfig?.sessionGroup ?? 'protector_${config.uid}';

  Future<ProtectorStorageItem?> getItemForConfig(ConfigInfo config) async {
    final String key = sessionKey(config);
    final ProtectorStorageItem? item = await getItem(uid: key);
    if (item != null) return item;

    final ProtectorStorageItem? legacy = await _latestLegacyItem(config);
    if (legacy == null) return null;

    final ProtectorStorageItem migrated =
        ProtectorStorageItem(uid: key, data: legacy.data);
    await saveItem(item: migrated);
    return migrated;
  }

  Future<ProtectorStorageItem?> _latestLegacyItem(ConfigInfo config) async {
    final RegExp legacyKey =
        RegExp('^${RegExp.escape(config.name)}_(\\d+)\$');
    final Map<String, String> all;
    try {
      all = await _secureStorage.readAll();
    } catch (e) {
      return null;
    }

    int? latestVersion;
    String? latestRaw;
    for (final MapEntry<String, String> entry in all.entries) {
      final RegExpMatch? match = legacyKey.firstMatch(entry.key);
      if (match == null) continue;
      final int version = int.parse(match.group(1)!);
      if (latestVersion == null || version > latestVersion) {
        latestVersion = version;
        latestRaw = entry.value;
      }
    }
    if (latestRaw == null) return null;

    try {
      return ProtectorStorageItem.fromJson(jsonDecode(latestRaw));
    } catch (e) {
      return null;
    }
  }

  Future<ProtectorStorageItem?> getItem({required String uid}) async {
    try {
      final String? possibleItem = await _secureStorage.read(key: uid);

      if (possibleItem == null) {
        return null;
      }

      return ProtectorStorageItem.fromJson(jsonDecode(possibleItem));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveItem({required ProtectorStorageItem item}) async {
    await _secureStorage.write(key: item.uid, value: jsonEncode(item.toJson()));
  }

  Future<void> clear() async {
    final Map<String, String> all = await _secureStorage.readAll();

    for (final MapEntry<String, String> entry in all.entries) {
      if (!_isProtectorItem(entry.value)) continue;
      await _secureStorage.delete(key: entry.key);
    }
  }

  bool _isProtectorItem(String raw) {
    try {
      ProtectorStorageItem.fromJson(jsonDecode(raw));
      return true;
    } catch (e) {
      return false;
    }
  }
}
