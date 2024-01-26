import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';

class ProtectorStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
