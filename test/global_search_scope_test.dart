import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/global_search/global_search_preferences.dart';
import 'package:wakaranai/services/global_search/global_search_scope.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';

ConfigInfo _config(
  String uid, {
  String? name,
  bool nsfw = false,
  bool searchAvailable = true,
  int type = 0,
}) {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': name ?? uid,
    'uid': uid,
    'logoUrl': '',
    'type': type,
    'nsfw': nsfw,
    'language': 'en',
    'version': 1,
    'filters': <dynamic>[],
    'searchAvailable': searchAvailable,
  });
}

GlobalSearchSource _installed(
  String uid, {
  String? name,
  bool nsfw = false,
  bool searchAvailable = true,
}) {
  return GlobalSearchSource(
    extension: ExtensionDomain(
      id: 0,
      config: _config(
        uid,
        name: name,
        nsfw: nsfw,
        searchAvailable: searchAvailable,
      ),
      sourceCode: '',
      createdAt: DateTime(2026),
    ),
  );
}

GlobalSearchSource _remote(String uid, {int? apiVersion}) {
  return GlobalSearchSource(
    extension: RemoteConfig(
      path: 'manga/$uid',
      config: _config(uid),
      apiVersion: apiVersion,
    ),
  );
}

List<String> _uids(List<GlobalSearchSource> sources) {
  return sources.map((GlobalSearchSource source) => source.uid).toList();
}

void main() {
  group('GlobalSearchScopeRules', () {
    test('skips sources without search', () {
      const GlobalSearchScopeRules rules = GlobalSearchScopeRules();
      expect(rules.allows(_config('a', searchAvailable: false)), isFalse);
      expect(rules.allows(_config('b')), isTrue);
    });

    test('allows nsfw only when shown and titles are not hidden', () {
      final ConfigInfo adult = _config('adult', nsfw: true);
      expect(const GlobalSearchScopeRules().allows(adult), isFalse);
      expect(
        const GlobalSearchScopeRules(showNsfw: true).allows(adult),
        isTrue,
      );
      expect(
        const GlobalSearchScopeRules(showNsfw: true, hideNsfwTitles: true)
            .allows(adult),
        isFalse,
      );
    });

    test('keeps only sources of the required type', () {
      const GlobalSearchScopeRules rules =
          GlobalSearchScopeRules(type: ConfigInfoType.ANIME);
      expect(rules.allows(_config('manga')), isFalse);
      expect(rules.allows(_config('anime', type: 1)), isTrue);
    });
  });

  group('GlobalSearchScope', () {
    test('merge keeps the first source per uid and drops too-new remotes', () {
      final GlobalSearchSource installed = _installed('a', name: 'Installed');
      final List<GlobalSearchSource> merged = GlobalSearchScope.merge(
        <List<GlobalSearchSource>>[
          <GlobalSearchSource>[installed],
          <GlobalSearchSource>[
            _remote('a'),
            _remote('b'),
            _remote('future', apiVersion: 99),
          ],
        ],
      );
      expect(_uids(merged), <String>['a', 'b']);
      expect(merged.first.isInstalled, isTrue);
    });

    test('default scope is pinned plus used sources that allow search', () {
      final List<GlobalSearchSource> catalog = <GlobalSearchSource>[
        _installed('used', name: 'Zeta'),
        _installed('pinned', name: 'Beta'),
        _installed('other', name: 'Alpha'),
        _installed('no-search', searchAvailable: false),
        _installed('adult', nsfw: true),
      ];
      final List<GlobalSearchSource> scope = GlobalSearchScope.resolve(
        catalog: catalog,
        stored: null,
        pinned: <String>['pinned'],
        used: <String>{'used', 'no-search', 'adult'},
        rules: const GlobalSearchScopeRules(),
      );
      expect(_uids(scope), <String>['pinned', 'used']);
    });

    test('a stored selection replaces the default', () {
      final List<GlobalSearchSource> catalog = <GlobalSearchSource>[
        _installed('a'),
        _installed('b'),
        _installed('c'),
      ];
      final List<GlobalSearchSource> scope = GlobalSearchScope.resolve(
        catalog: catalog,
        stored: <String>['c', 'missing'],
        pinned: <String>['a'],
        used: <String>{'a', 'b'},
        rules: const GlobalSearchScopeRules(),
      );
      expect(_uids(scope), <String>['c']);
    });

    test('orders pinned sources first, then by name', () {
      final List<GlobalSearchSource> ordered = GlobalSearchScope.ordered(
        <GlobalSearchSource>[
          _installed('c', name: 'charlie'),
          _installed('a', name: 'Alpha'),
          _installed('p2', name: 'Zulu'),
          _installed('p1', name: 'Yankee'),
        ],
        pinned: <String>['p2', 'p1'],
      );
      expect(_uids(ordered), <String>['p2', 'p1', 'a', 'c']);
    });
  });

  group('GlobalSearchPreferences', () {
    test('history keeps the latest ten unique queries', () {
      List<String> history = const <String>[];
      for (int index = 0; index < 12; index++) {
        history = GlobalSearchPreferences.withQuery(history, 'query $index');
      }
      history = GlobalSearchPreferences.withQuery(history, ' QUERY 5 ');
      expect(history.length, GlobalSearchPreferences.historyLimit);
      expect(history.first, 'QUERY 5');
      expect(
        history.where((String item) => item.toLowerCase() == 'query 5'),
        hasLength(1),
      );
      expect(history.contains('query 0'), isFalse);
    });

    test('blank queries are not remembered', () {
      expect(
        GlobalSearchPreferences.withQuery(<String>['a'], '   '),
        <String>['a'],
      );
    });

    test('scope round-trips and can be reset', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const GlobalSearchPreferences preferences = GlobalSearchPreferences();
      expect(await preferences.readScope(), isNull);
      await preferences.writeScope(<String>['a', 'b']);
      expect(await preferences.readScope(), <String>['a', 'b']);
      await preferences.writeScope(null);
      expect(await preferences.readScope(), isNull);
    });

    test('a migration scope is stored apart and keeps no history', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const GlobalSearchPreferences migration = GlobalSearchPreferences(
        scopeStorageKey: GlobalSearchPreferences.migrationScopeKey,
        keepsHistory: false,
      );
      await migration.writeScope(<String>['m']);
      await migration.writeHistory(<String>['naruto']);
      expect(await const GlobalSearchPreferences().readScope(), isNull);
      expect(await migration.readScope(), <String>['m']);
      expect(await migration.readHistory(), isEmpty);
    });
  });
}
