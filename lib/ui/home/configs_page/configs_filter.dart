import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/content_kinds/content_kinds.dart';
import 'package:capyscript/modules/waka_models/models/config_info/source_pricing/source_pricing.dart';
import 'package:capyscript/modules/waka_models/models/config_info/source_type/source_type.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/generated/l10n.dart';

List<String> effectiveContentKinds(ConfigInfo config) {
  if (config.contentKinds.isNotEmpty) {
    return config.contentKinds;
  }
  if (config.type == ConfigInfoType.MANGA) {
    return const <String>[ContentKinds.manga];
  }
  if (config.type == ConfigInfoType.NOVEL) {
    return const <String>[ContentKinds.novel];
  }
  if (config.type == ConfigInfoType.AUDIO) {
    return const <String>[ContentKinds.audiobook];
  }
  return const <String>[ContentKinds.anime];
}

class ConfigsFilter {
  const ConfigsFilter({this.kind, this.language, this.pricing, this.sourceType});

  final String? kind;
  final String? language;
  final String? pricing;
  final String? sourceType;

  bool get isEmpty =>
      kind == null && language == null && pricing == null && sourceType == null;

  bool matches(BaseExtension extension) {
    final ConfigInfo config = extension.config;
    final String? selectedKind = kind;
    if (selectedKind != null &&
        !effectiveContentKinds(config).contains(selectedKind)) {
      return false;
    }
    final String? selectedLanguage = language;
    if (selectedLanguage != null && config.language.trim() != selectedLanguage) {
      return false;
    }
    final String? selectedPricing = pricing;
    if (selectedPricing != null && config.pricing != selectedPricing) {
      return false;
    }
    final String? selectedSourceType = sourceType;
    if (selectedSourceType != null && config.sourceType != selectedSourceType) {
      return false;
    }
    return true;
  }

  ConfigsFilter withKind(String? value) {
    return ConfigsFilter(
      kind: value,
      language: language,
      pricing: pricing,
      sourceType: sourceType,
    );
  }

  ConfigsFilter withLanguage(String? value) {
    return ConfigsFilter(
      kind: kind,
      language: value,
      pricing: pricing,
      sourceType: sourceType,
    );
  }

  ConfigsFilter withPricing(String? value) {
    return ConfigsFilter(
      kind: kind,
      language: language,
      pricing: value,
      sourceType: sourceType,
    );
  }

  ConfigsFilter withSourceType(String? value) {
    return ConfigsFilter(
      kind: kind,
      language: language,
      pricing: pricing,
      sourceType: value,
    );
  }
}

List<String> availableContentKinds(Iterable<BaseExtension> extensions) {
  final Set<String> kinds = <String>{};
  for (final BaseExtension extension in extensions) {
    kinds.addAll(effectiveContentKinds(extension.config));
  }
  final List<String> ordered = <String>[
    for (final String known in ContentKinds.known)
      if (kinds.contains(known)) known,
  ];
  final List<String> unknown = kinds
      .where((String kind) => !ContentKinds.known.contains(kind))
      .toList()
    ..sort();
  return <String>[...ordered, ...unknown];
}

List<String> availableLanguages(Iterable<BaseExtension> extensions) {
  final Set<String> languages = <String>{};
  for (final BaseExtension extension in extensions) {
    final String language = extension.config.language.trim();
    if (language.isNotEmpty) {
      languages.add(language);
    }
  }
  return languages.toList()..sort();
}

List<String> availablePricings(Iterable<BaseExtension> extensions) {
  final Set<String> pricings = <String>{
    for (final BaseExtension extension in extensions) extension.config.pricing,
  };
  return <String>[
    for (final String known in SourcePricing.known)
      if (pricings.contains(known)) known,
  ];
}

String pricingLabel(String pricing) {
  switch (pricing) {
    case SourcePricing.partial:
      return S.current.source_pricing_partial;
    case SourcePricing.paid:
      return S.current.source_pricing_paid;
  }
  return S.current.source_pricing_free;
}

List<String> availableSourceTypes(Iterable<BaseExtension> extensions) {
  final Set<String> types = <String>{
    for (final BaseExtension extension in extensions) extension.config.sourceType,
  };
  return <String>[
    for (final String known in SourceType.known)
      if (types.contains(known)) known,
  ];
}

String sourceTypeLabel(String sourceType) {
  switch (sourceType) {
    case SourceType.selfHosted:
      return S.current.source_type_self_hosted;
    case SourceType.official:
      return S.current.source_type_official;
    case SourceType.local:
      return S.current.source_type_local;
  }
  return S.current.source_type_website;
}

IconData sourceTypeIcon(String sourceType) {
  switch (sourceType) {
    case SourceType.selfHosted:
      return Icons.dns_rounded;
    case SourceType.official:
      return Icons.verified_rounded;
    case SourceType.local:
      return Icons.smartphone_rounded;
  }
  return Icons.public_rounded;
}

IconData pricingIcon(String pricing) {
  switch (pricing) {
    case SourcePricing.partial:
      return Icons.toll_rounded;
    case SourcePricing.paid:
      return Icons.paid_rounded;
  }
  return Icons.money_off_rounded;
}

const Map<String, String> _languageCodes = <String, String>{
  'english': 'EN',
  'русский': 'RU',
  'українська': 'UK',
  '日本語': 'JA',
  '中文': 'ZH',
  '한국어': 'KO',
  'español': 'ES',
  'português': 'PT',
  'français': 'FR',
  'deutsch': 'DE',
  'italiano': 'IT',
  'polski': 'PL',
  'türkçe': 'TR',
  'tiếng việt': 'VI',
  'bahasa indonesia': 'ID',
};

bool isMultiLanguage(String language) {
  return language.trim().toLowerCase() == 'multi';
}

String languageCode(String language) {
  final String normalized = language.trim().toLowerCase();
  final String? known = _languageCodes[normalized];
  if (known != null) {
    return known;
  }
  final String trimmed = language.trim();
  if (trimmed.length <= 2) {
    return trimmed.toUpperCase();
  }
  return trimmed.substring(0, 2).toUpperCase();
}

String contentKindLabel(String kind) {
  switch (kind) {
    case ContentKinds.anime:
      return S.current.content_kind_anime;
    case ContentKinds.movie:
      return S.current.content_kind_movie;
    case ContentKinds.series:
      return S.current.content_kind_series;
    case ContentKinds.cartoon:
      return S.current.content_kind_cartoon;
    case ContentKinds.dorama:
      return S.current.content_kind_dorama;
    case ContentKinds.documentary:
      return S.current.content_kind_documentary;
    case ContentKinds.manga:
      return S.current.content_kind_manga;
    case ContentKinds.manhwa:
      return S.current.content_kind_manhwa;
    case ContentKinds.manhua:
      return S.current.content_kind_manhua;
    case ContentKinds.comic:
      return S.current.content_kind_comic;
    case ContentKinds.novel:
      return S.current.content_kind_novel;
    case ContentKinds.audiobook:
      return S.current.content_kind_audiobook;
  }
  if (kind.isEmpty) {
    return kind;
  }
  return kind[0].toUpperCase() + kind.substring(1);
}

class ConfigsFilterPreferences {
  static const String kindKey = 'CONFIGS_FILTER_KIND';
  static const String languageKey = 'CONFIGS_FILTER_LANGUAGE';
  static const String pricingKey = 'CONFIGS_FILTER_PRICING';
  static const String sourceTypeKey = 'CONFIGS_FILTER_SOURCE_TYPE';

  Future<ConfigsFilter> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return ConfigsFilter(
      kind: preferences.getString(kindKey),
      language: preferences.getString(languageKey),
      pricing: preferences.getString(pricingKey),
      sourceType: preferences.getString(sourceTypeKey),
    );
  }

  Future<void> write(ConfigsFilter filter) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await _writeOptional(preferences, kindKey, filter.kind);
    await _writeOptional(preferences, languageKey, filter.language);
    await _writeOptional(preferences, pricingKey, filter.pricing);
    await _writeOptional(preferences, sourceTypeKey, filter.sourceType);
  }

  Future<void> _writeOptional(
    SharedPreferences preferences,
    String key,
    String? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }
    await preferences.setString(key, value);
  }
}
