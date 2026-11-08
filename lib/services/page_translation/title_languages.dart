import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class TitleLanguages extends Equatable {
  const TitleLanguages({
    required this.source,
    required this.target,
    this.glossary = const <GlossaryEntry>[],
  });

  final PageLanguage source;
  final PageLanguage target;
  final List<GlossaryEntry> glossary;

  Set<PageLanguage> get packs => <PageLanguage>{source, target};

  TitleLanguages copyWith({
    PageLanguage? source,
    PageLanguage? target,
    List<GlossaryEntry>? glossary,
  }) {
    return TitleLanguages(
      source: source ?? this.source,
      target: target ?? this.target,
      glossary: glossary ?? this.glossary,
    );
  }

  String encode() {
    return jsonEncode(<String, Object>{
      'source': source.code,
      'target': target.code,
      'glossary': <List<String>>[
        for (final GlossaryEntry entry in glossary) entry.toJson(),
      ],
    });
  }

  static TitleLanguages? decode(String? value) {
    if (value == null) {
      return null;
    }
    if (value.startsWith('{')) {
      return _decodeJson(value);
    }
    return _decodeLegacy(value);
  }

  static TitleLanguages? _decodeJson(String value) {
    final Object? json;
    try {
      json = jsonDecode(value);
    } on FormatException {
      return null;
    }
    if (json is! Map<String, dynamic>) {
      return null;
    }
    final PageLanguage? source = PageLanguage.sourceByCode(
      json['source'] as String?,
    );
    final PageLanguage? target = PageLanguage.targetByCode(
      json['target'] as String?,
    );
    if (source == null || target == null) {
      return null;
    }
    final List<dynamic> entries =
        json['glossary'] as List<dynamic>? ?? const <dynamic>[];
    return TitleLanguages(
      source: source,
      target: target,
      glossary: <GlossaryEntry>[
        for (final Object? entry in entries) ?GlossaryEntry.fromJson(entry),
      ],
    );
  }

  static TitleLanguages? _decodeLegacy(String value) {
    final List<String> parts = value.split('>');
    if (parts.length != 2) {
      return null;
    }
    final PageLanguage? source = PageLanguage.sourceByCode(parts[0]);
    final PageLanguage? target = PageLanguage.targetByCode(parts[1]);
    if (source == null || target == null) {
      return null;
    }
    return TitleLanguages(source: source, target: target);
  }

  @override
  List<Object?> get props => <Object?>[source.code, target.code, glossary];
}
