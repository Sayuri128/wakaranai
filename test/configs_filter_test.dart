import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter.dart';

ExtensionDomain _extension(
  String uid, {
  int type = 0,
  String language = 'English',
  List<String>? kinds,
}) {
  return ExtensionDomain(
    id: 0,
    config: ConfigInfo.fromJson(<String, dynamic>{
      'name': uid,
      'uid': uid,
      'logoUrl': '',
      'type': type,
      'nsfw': false,
      'language': language,
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
      if (kinds != null) 'contentKinds': kinds,
    }),
    sourceCode: '',
    revision: 'r',
    createdAt: DateTime(2026),
  );
}

void main() {
  final List<BaseExtension> extensions = <BaseExtension>[
    _extension('dex'),
    _extension('flix', type: 1, language: 'Українська', kinds: <String>['movie', 'series', 'anime']),
    _extension('tube', type: 1, language: 'Українська'),
  ];

  test('falls back to the extension type when no kinds are declared', () {
    expect(effectiveContentKinds(extensions[0].config), <String>['manga']);
    expect(effectiveContentKinds(extensions[2].config), <String>['anime']);
  });

  test('lists kinds in a stable order and languages alphabetically', () {
    expect(availableContentKinds(extensions), <String>['anime', 'movie', 'series', 'manga']);
    expect(availableLanguages(extensions), <String>['English', 'Українська']);
  });

  test('filters by kind and language together', () {
    const ConfigsFilter movies = ConfigsFilter(kind: 'movie');
    expect(extensions.where(movies.matches).map((BaseExtension e) => e.config.uid), <String>['flix']);
    const ConfigsFilter ukrainianAnime = ConfigsFilter(kind: 'anime', language: 'Українська');
    expect(
      extensions.where(ukrainianAnime.matches).map((BaseExtension e) => e.config.uid),
      <String>['flix', 'tube'],
    );
  });
}
