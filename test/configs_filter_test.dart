import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter.dart';

ExtensionDomain _extension(
  String uid, {
  int type = 0,
  String language = 'English',
  List<String>? kinds,
  String? pricing,
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
      if (pricing != null) 'pricing': pricing,
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
    expect(
      effectiveContentKinds(_extension('ranobe', type: 2).config),
      <String>['novel'],
    );
    expect(
      effectiveContentKinds(_extension('librivox', type: 3).config),
      <String>['audiobook'],
    );
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

  test('lists only the pricings present, in free, partial, paid order', () {
    expect(availablePricings(extensions), <String>['free']);
    final List<BaseExtension> mixed = <BaseExtension>[
      _extension('vod', pricing: 'paid'),
      ...extensions,
      _extension('remanga', pricing: 'partial'),
    ];
    expect(availablePricings(mixed), <String>['free', 'partial', 'paid']);
  });

  test('filters by pricing, treating a missing pricing as free', () {
    final List<BaseExtension> mixed = <BaseExtension>[
      _extension('vod', pricing: 'paid'),
      _extension('remanga', pricing: 'partial'),
      _extension('dex'),
    ];
    const ConfigsFilter free = ConfigsFilter(pricing: 'free');
    expect(mixed.where(free.matches).map((BaseExtension e) => e.config.uid), <String>['dex']);
    final ConfigsFilter paid = const ConfigsFilter(language: 'English').withPricing('paid');
    expect(paid.language, 'English');
    expect(mixed.where(paid.matches).map((BaseExtension e) => e.config.uid), <String>['vod']);
  });

  test('maps languages to short codes and recognises the multi-language label', () {
    expect(languageCode('Русский'), 'RU');
    expect(languageCode(' Українська '), 'UK');
    expect(languageCode('English'), 'EN');
    expect(languageCode('Esperanto'), 'ES');
    expect(languageCode('vi'), 'VI');
    expect(isMultiLanguage('Multi'), isTrue);
    expect(isMultiLanguage('English'), isFalse);
  });

  test('gives each pricing its own icon', () {
    expect(pricingIcon('free'), Icons.money_off_rounded);
    expect(pricingIcon('partial'), Icons.toll_rounded);
    expect(pricingIcon('paid'), Icons.paid_rounded);
  });
}
