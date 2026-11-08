import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';

class GlobalSearchScopeRules {
  const GlobalSearchScopeRules({
    this.showNsfw = false,
    this.hideNsfwTitles = false,
    this.type,
  });

  final bool showNsfw;
  final bool hideNsfwTitles;
  final ConfigInfoType? type;

  bool allows(ConfigInfo config) {
    if (!config.searchAvailable) {
      return false;
    }
    final ConfigInfoType? requiredType = type;
    if (requiredType != null && config.type != requiredType) {
      return false;
    }
    if (!config.nsfw) {
      return true;
    }
    return showNsfw && !hideNsfwTitles;
  }
}

class GlobalSearchScope {
  const GlobalSearchScope._();

  static List<GlobalSearchSource> merge(
    Iterable<Iterable<GlobalSearchSource>> groups,
  ) {
    final Map<String, GlobalSearchSource> byUid =
        <String, GlobalSearchSource>{};
    for (final Iterable<GlobalSearchSource> group in groups) {
      for (final GlobalSearchSource source in group) {
        if (byUid.containsKey(source.uid) || _needsNewerApp(source)) {
          continue;
        }
        byUid[source.uid] = source;
      }
    }
    return byUid.values.toList(growable: false);
  }

  static bool _needsNewerApp(GlobalSearchSource source) {
    final Object extension = source.extension;
    return extension is RemoteConfig &&
        extension.compatibility.requiresNewerApp;
  }

  static List<GlobalSearchSource> eligible(
    Iterable<GlobalSearchSource> catalog,
    GlobalSearchScopeRules rules,
  ) {
    return catalog
        .where((GlobalSearchSource source) => rules.allows(source.config))
        .toList(growable: false);
  }

  static Set<String> defaultUids({
    required Iterable<String> pinned,
    required Iterable<String> used,
  }) {
    return <String>{...pinned, ...used};
  }

  static List<GlobalSearchSource> resolve({
    required Iterable<GlobalSearchSource> catalog,
    required List<String>? stored,
    required List<String> pinned,
    required Iterable<String> used,
    required GlobalSearchScopeRules rules,
  }) {
    final Set<String> selected =
        stored?.toSet() ?? defaultUids(pinned: pinned, used: used);
    final List<GlobalSearchSource> chosen = eligible(catalog, rules)
        .where((GlobalSearchSource source) => selected.contains(source.uid))
        .toList();
    return ordered(chosen, pinned: pinned);
  }

  static List<GlobalSearchSource> ordered(
    Iterable<GlobalSearchSource> sources, {
    required List<String> pinned,
  }) {
    final List<GlobalSearchSource> result = List<GlobalSearchSource>.of(
      sources,
    );
    int rank(GlobalSearchSource source) {
      final int index = pinned.indexOf(source.uid);
      if (index < 0) {
        return pinned.length;
      }
      return index;
    }

    result.sort((GlobalSearchSource a, GlobalSearchSource b) {
      final int byPin = rank(a).compareTo(rank(b));
      if (byPin != 0) {
        return byPin;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }
}
