import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

class ExtensionPreferencesStore {
  ExtensionPreferencesStore({SharedPreferencesLoader? loadPreferences})
      : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  static ExtensionPreferencesStore instance = ExtensionPreferencesStore();

  static const String keyPrefix = 'EXT_PREF_';
  static const String _separator = '::';

  static String extensionPrefix(String extensionUid) {
    return '$keyPrefix$extensionUid$_separator';
  }

  static String storageKey(String extensionUid, String key) {
    return '${extensionPrefix(extensionUid)}$key';
  }

  final SharedPreferencesLoader _loadPreferences;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();
  SharedPreferences? _preferences;

  Stream<String> get changes => _changes.stream;

  Stream<String> changesFor(String extensionUid) {
    return changes.where((String changedUid) => changedUid == extensionUid);
  }

  Future<SharedPreferences> _load() async {
    return _preferences ??= await _loadPreferences();
  }

  Future<Object?> read(String extensionUid, String key) async {
    final SharedPreferences preferences = await _load();
    return preferences.get(storageKey(extensionUid, key));
  }

  Future<Map<String, Object>> readAll(String extensionUid) async {
    final SharedPreferences preferences = await _load();
    final String prefix = extensionPrefix(extensionUid);
    final Map<String, Object> values = <String, Object>{};
    for (final String storedKey in preferences.getKeys()) {
      if (!storedKey.startsWith(prefix)) {
        continue;
      }
      final Object? value = preferences.get(storedKey);
      if (value != null) {
        values[storedKey.substring(prefix.length)] = value;
      }
    }
    return values;
  }

  Future<void> write(String extensionUid, String key, Object value) async {
    final SharedPreferences preferences = await _load();
    await _writeTyped(preferences, storageKey(extensionUid, key), value);
    _notify(extensionUid);
  }

  Future<void> remove(String extensionUid, String key) async {
    final SharedPreferences preferences = await _load();
    await preferences.remove(storageKey(extensionUid, key));
    _notify(extensionUid);
  }

  Future<void> clearExtension(String extensionUid) async {
    final SharedPreferences preferences = await _load();
    final String prefix = extensionPrefix(extensionUid);
    final List<String> keys = preferences
        .getKeys()
        .where((String storedKey) => storedKey.startsWith(prefix))
        .toList();
    for (final String storedKey in keys) {
      await preferences.remove(storedKey);
    }
    _notify(extensionUid);
  }

  Future<void> _writeTyped(
    SharedPreferences preferences,
    String storedKey,
    Object value,
  ) async {
    if (value is bool) {
      await preferences.setBool(storedKey, value);
      return;
    }
    if (value is int) {
      await preferences.setInt(storedKey, value);
      return;
    }
    if (value is double) {
      await preferences.setDouble(storedKey, value);
      return;
    }
    if (value is String) {
      await preferences.setString(storedKey, value);
      return;
    }
    if (value is List) {
      await preferences.setStringList(
        storedKey,
        value.map((Object? item) => item.toString()).toList(),
      );
      return;
    }
    throw ArgumentError.value(
      value,
      'value',
      'unsupported extension preference type ${value.runtimeType}',
    );
  }

  void _notify(String extensionUid) {
    if (_changes.isClosed) {
      return;
    }
    _changes.add(extensionUid);
  }
}
