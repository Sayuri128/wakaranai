import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';

class ProtectorStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static String sessionKey(ConfigInfo config) =>
      config.protectorConfig?.sessionGroup ??
      '${config.name}_${config.version}';

  static String _legacyKey(ConfigInfo config) =>
      '${config.name}_${config.version}';

  Future<ProtectorStorageItem?> getItemForConfig(ConfigInfo config) async {
    final String key = sessionKey(config);
    final ProtectorStorageItem? item = await getItem(uid: key);
    if (item != null) return item;

    final String legacyKey = _legacyKey(config);
    if (legacyKey == key) return null;

    final ProtectorStorageItem? legacy = await getItem(uid: legacyKey);
    if (legacy == null) return null;

    final ProtectorStorageItem migrated =
        ProtectorStorageItem(uid: key, data: legacy.data);
    await saveItem(item: migrated);
    return migrated;
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
    await _secureStorage.deleteAll();
  }
}
