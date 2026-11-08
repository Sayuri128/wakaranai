import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/content_kinds/content_kinds.dart';
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
  const ConfigsFilter({this.kind, this.language});

  final String? kind;
  final String? language;

  bool get isEmpty => kind == null && language == null;

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
    return true;
  }

  ConfigsFilter withKind(String? value) {
    return ConfigsFilter(kind: value, language: language);
  }

  ConfigsFilter withLanguage(String? value) {
    return ConfigsFilter(kind: kind, language: value);
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

  Future<ConfigsFilter> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return ConfigsFilter(
      kind: preferences.getString(kindKey),
      language: preferences.getString(languageKey),
    );
  }

  Future<void> write(ConfigsFilter filter) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await _writeOptional(preferences, kindKey, filter.kind);
    await _writeOptional(preferences, languageKey, filter.language);
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
