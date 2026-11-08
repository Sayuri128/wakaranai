import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';

enum ConfigsLayout { cards, compact, grid }

enum ConfigsSort { listing, name }

const int kConfigsSearchThreshold = 10;

class ConfigsViewOptions {
  const ConfigsViewOptions({
    this.layout = ConfigsLayout.cards,
    this.sort = ConfigsSort.listing,
    this.pinned = const <String>[],
  });

  final ConfigsLayout layout;
  final ConfigsSort sort;
  final List<String> pinned;

  bool isPinned(String uid) => pinned.contains(uid);

  ConfigsViewOptions copyWith({
    ConfigsLayout? layout,
    ConfigsSort? sort,
    List<String>? pinned,
  }) {
    return ConfigsViewOptions(
      layout: layout ?? this.layout,
      sort: sort ?? this.sort,
      pinned: pinned ?? this.pinned,
    );
  }

  List<BaseExtension> sorted(List<BaseExtension> extensions) {
    if (sort == ConfigsSort.listing) {
      return extensions;
    }
    return List<BaseExtension>.of(extensions)
      ..sort((BaseExtension a, BaseExtension b) => a.config.name
          .trim()
          .toLowerCase()
          .compareTo(b.config.name.trim().toLowerCase()));
  }

  List<BaseExtension> pinnedIn(Iterable<BaseExtension> extensions) {
    final Map<String, BaseExtension> byUid = <String, BaseExtension>{
      for (final BaseExtension extension in extensions)
        extension.config.uid: extension,
    };
    final List<BaseExtension> result = <BaseExtension>[
      for (final String uid in pinned)
        if (byUid[uid] != null) byUid[uid]!,
    ];
    return sorted(result);
  }

  List<BaseExtension> unpinned(List<BaseExtension> extensions) {
    return sorted(extensions
        .where((BaseExtension extension) => !isPinned(extension.config.uid))
        .toList());
  }
}

bool matchesConfigsQuery(BaseExtension extension, String query) {
  final String needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return true;
  }
  return extension.config.name.toLowerCase().contains(needle) ||
      extension.config.language.toLowerCase().contains(needle);
}

class ConfigsViewOptionsCubit extends Cubit<ConfigsViewOptions> {
  ConfigsViewOptionsCubit() : super(const ConfigsViewOptions());

  static const String layoutKey = 'CONFIGS_LAYOUT';
  static const String sortKey = 'CONFIGS_SORT';
  static const String pinnedKey = 'CONFIGS_PINNED';

  Future<void> init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (isClosed) {
      return;
    }
    emit(ConfigsViewOptions(
      layout: _byName(
        ConfigsLayout.values,
        preferences.getString(layoutKey),
        ConfigsLayout.cards,
      ),
      sort: _byName(
        ConfigsSort.values,
        preferences.getString(sortKey),
        ConfigsSort.listing,
      ),
      pinned: _decodePinned(preferences.getString(pinnedKey)),
    ));
  }

  static Future<List<String>> readPinned() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _decodePinned(preferences.getString(pinnedKey));
  }

  Future<void> setLayout(ConfigsLayout layout) async {
    emit(state.copyWith(layout: layout));
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(layoutKey, layout.name);
  }

  Future<void> setSort(ConfigsSort sort) async {
    emit(state.copyWith(sort: sort));
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(sortKey, sort.name);
  }

  Future<void> togglePin(String uid) async {
    final List<String> pinned = List<String>.of(state.pinned);
    if (!pinned.remove(uid)) {
      pinned.add(uid);
    }
    emit(state.copyWith(pinned: List<String>.unmodifiable(pinned)));
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(pinnedKey, jsonEncode(pinned));
  }

  static List<String> _decodePinned(String? stored) {
    if (stored == null) {
      return const <String>[];
    }
    try {
      final Object? decoded = jsonDecode(stored);
      if (decoded is List) {
        return List<String>.unmodifiable(decoded.whereType<String>());
      }
    } on FormatException {
      return const <String>[];
    }
    return const <String>[];
  }

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
