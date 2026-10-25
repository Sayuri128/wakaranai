import 'dart:convert';

import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

String buildTranslationPrompt(
  List<String> texts, {
  required PageLanguage from,
  required PageLanguage to,
  List<GlossaryEntry> glossary = const <GlossaryEntry>[],
}) {
  final StringBuffer buffer = StringBuffer()
    ..writeln(
      'You are a professional manga translator. Translate the speech bubbles '
      'of one comic page from ${from.name} to ${to.name}.',
    )
    ..writeln(
      'The source text was read by OCR from hand-lettered comic fonts and may '
      'contain recognition mistakes (for example U read as W or A, missing '
      'apostrophes, words split by hyphens). Silently correct them using the '
      'context of the whole page.',
    )
    ..writeln(
      'Translate naturally and idiomatically, keep the tone, slang and '
      'interjections, and keep each translation short enough to fit its '
      'bubble. Do not add notes.',
    )
    ..writeln(
      'Answer with ONLY a JSON array of ${texts.length} strings: one '
      'translation per bubble, in the same order.',
    )
    ..writeln();
  if (glossary.isNotEmpty) {
    buffer.writeln('Always translate these names and terms exactly as given:');
    for (final GlossaryEntry entry in glossary) {
      buffer.writeln('- ${entry.source.trim()} → ${entry.target.trim()}');
    }
    buffer.writeln();
  }
  buffer.writeln('Bubbles:');
  for (int i = 0; i < texts.length; i++) {
    buffer.writeln('${i + 1}. ${texts[i]}');
  }
  return buffer.toString();
}

final RegExp _numberedLine = RegExp(r'^\s*(\d+)[.)]\s*(.+)$', multiLine: true);

List<String?> parseTranslations(String output, int count) {
  final List<String>? items = _parseJsonArray(output);
  if (items == null) {
    return _parseNumberedLines(output, count);
  }
  return <String?>[
    for (int i = 0; i < count; i++)
      if (i < items.length && items[i].isNotEmpty) items[i] else null,
  ];
}

final RegExp _nonLetters = RegExp(r'[^\p{L}]+', unicode: true);

bool isUntranslatedEcho(String source, String translation) {
  final String sourceLetters = source.toLowerCase().replaceAll(_nonLetters, '');
  final String translationLetters = translation.toLowerCase().replaceAll(
    _nonLetters,
    '',
  );
  return sourceLetters.isNotEmpty && sourceLetters == translationLetters;
}

List<String>? _parseJsonArray(String output) {
  final int start = output.indexOf('[');
  final int end = output.lastIndexOf(']');
  if (start < 0 || end <= start) {
    return null;
  }
  try {
    final List<dynamic> decoded =
        jsonDecode(output.substring(start, end + 1)) as List<dynamic>;
    return decoded.map((dynamic item) {
      if (item is String) {
        return item.trim();
      }
      return '$item';
    }).toList();
  } catch (_) {
    return null;
  }
}

List<String?> _parseNumberedLines(String output, int count) {
  final Map<int, String> numbered = <int, String>{};
  for (final RegExpMatch match in _numberedLine.allMatches(output)) {
    numbered[int.parse(match[1]!)] = match[2]!.trim();
  }
  return <String?>[for (int i = 0; i < count; i++) numbered[i + 1]];
}
