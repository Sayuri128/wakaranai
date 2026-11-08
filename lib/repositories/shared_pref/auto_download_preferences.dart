import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AutoDownloadScope { allTitles, selectedCategories }

const int kDefaultAutoDownloadMaxPerTitle = 5;
const int kAutoDownloadUnlimited = 0;
const List<int> kAutoDownloadMaxPerTitleChoices = <int>[1, 3, 5, 10, 0];

class AutoDownloadSettings {
  const AutoDownloadSettings({
    this.enabled = false,
    this.scope = AutoDownloadScope.allTitles,
    this.categoryIds = const <int>{},
    this.maxPerTitle = kDefaultAutoDownloadMaxPerTitle,
  });

  final bool enabled;
  final AutoDownloadScope scope;
  final Set<int> categoryIds;
  final int maxPerTitle;

  bool get unlimited => maxPerTitle <= kAutoDownloadUnlimited;

  AutoDownloadSettings copyWith({
    bool? enabled,
    AutoDownloadScope? scope,
    Set<int>? categoryIds,
    int? maxPerTitle,
  }) {
    return AutoDownloadSettings(
      enabled: enabled ?? this.enabled,
      scope: scope ?? this.scope,
      categoryIds: categoryIds ?? this.categoryIds,
      maxPerTitle: maxPerTitle ?? this.maxPerTitle,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AutoDownloadSettings &&
        other.enabled == enabled &&
        other.scope == scope &&
        other.maxPerTitle == maxPerTitle &&
        const SetEquality<int>().equals(other.categoryIds, categoryIds);
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        scope,
        maxPerTitle,
        const SetEquality<int>().hash(categoryIds),
      );
}

class AutoDownloadPreferences {
  static const String enabledKey = 'AUTO_DOWNLOAD_ENABLED';
  static const String scopeKey = 'AUTO_DOWNLOAD_SCOPE';
  static const String categoryIdsKey = 'AUTO_DOWNLOAD_CATEGORY_IDS';
  static const String maxPerTitleKey = 'AUTO_DOWNLOAD_MAX_PER_TITLE';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<AutoDownloadSettings> read({bool reload = false}) async {
    final SharedPreferences preferences = await _load();
    if (reload) {
      await preferences.reload();
    }
    return AutoDownloadSettings(
      enabled: preferences.getBool(enabledKey) ?? false,
      scope: _scopeOf(preferences.getString(scopeKey)),
      categoryIds: _categoryIdsOf(preferences.getStringList(categoryIdsKey)),
      maxPerTitle: _maxPerTitleOf(preferences.getInt(maxPerTitleKey)),
    );
  }

  Future<void> write(AutoDownloadSettings settings) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(enabledKey, settings.enabled);
    await preferences.setString(scopeKey, settings.scope.name);
    await preferences.setStringList(
      categoryIdsKey,
      (settings.categoryIds.toList()..sort())
          .map((int id) => id.toString())
          .toList(),
    );
    await preferences.setInt(maxPerTitleKey, settings.maxPerTitle);
  }

  static AutoDownloadScope _scopeOf(String? stored) {
    return AutoDownloadScope.values.firstWhereOrNull(
          (AutoDownloadScope scope) => scope.name == stored,
        ) ??
        AutoDownloadScope.allTitles;
  }

  static Set<int> _categoryIdsOf(List<String>? stored) {
    if (stored == null) {
      return const <int>{};
    }
    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  static int _maxPerTitleOf(int? stored) {
    if (stored == null || stored < kAutoDownloadUnlimited) {
      return kDefaultAutoDownloadMaxPerTitle;
    }
    return stored;
  }
}
