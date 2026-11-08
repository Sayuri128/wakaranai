import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GlobalSearchPreferences {
  const GlobalSearchPreferences({
    this.scopeStorageKey = scopeKey,
    this.keepsHistory = true,
  });

  static const String scopeKey = 'GLOBAL_SEARCH_SCOPE';
  static const String migrationScopeKey = 'MIGRATION_SEARCH_SCOPE';
  static const String historyKey = 'GLOBAL_SEARCH_HISTORY';
  static const int historyLimit = 10;

  final String scopeStorageKey;
  final bool keepsHistory;

  Future<List<String>?> readScope() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _decode(preferences.getString(scopeStorageKey));
  }

  Future<void> writeScope(List<String>? uids) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (uids == null) {
      await preferences.remove(scopeStorageKey);
      return;
    }
    await preferences.setString(scopeStorageKey, jsonEncode(uids));
  }

  Future<List<String>> readHistory() async {
    if (!keepsHistory) {
      return const <String>[];
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _decode(preferences.getString(historyKey)) ?? const <String>[];
  }

  Future<void> writeHistory(List<String> history) async {
    if (!keepsHistory) {
      return;
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (history.isEmpty) {
      await preferences.remove(historyKey);
      return;
    }
    await preferences.setString(historyKey, jsonEncode(history));
  }

  static List<String> withQuery(List<String> history, String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return history;
    }
    final String needle = trimmed.toLowerCase();
    final List<String> result = <String>[
      trimmed,
      ...history.where((String item) => item.toLowerCase() != needle),
    ];
    if (result.length > historyLimit) {
      return List<String>.unmodifiable(result.sublist(0, historyLimit));
    }
    return List<String>.unmodifiable(result);
  }

  static List<String> withoutQuery(List<String> history, String query) {
    return List<String>.unmodifiable(
      history.where((String item) => item != query),
    );
  }

  static List<String>? _decode(String? stored) {
    if (stored == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(stored);
      if (decoded is List) {
        return List<String>.unmodifiable(decoded.whereType<String>());
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
