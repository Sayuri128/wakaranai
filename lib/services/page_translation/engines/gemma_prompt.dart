import 'dart:convert';

import 'package:wakaranai/services/page_translation/page_language.dart';

const String gemmaEngineId = 'gemma';

String buildGemmaPrompt(
  List<String> texts, {
  required PageLanguage from,
  required PageLanguage to,
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
    ..writeln()
    ..writeln('Bubbles:');
  for (int i = 0; i < texts.length; i++) {
    buffer.writeln('${i + 1}. ${texts[i]}');
  }
  return buffer.toString();
}

final RegExp _numberedLine = RegExp(r'^\s*(\d+)[.)]\s*(.+)$', multiLine: true);

List<String> parseTranslations(String output, List<String> fallback) {
  final List<String>? items = _parseJsonArray(output);
  if (items == null) {
    return _parseNumberedLines(output, fallback);
  }
  if (items.length >= fallback.length) {
    return items.sublist(0, fallback.length);
  }
  return <String>[...items, ...fallback.sublist(items.length)];
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

List<String> _parseNumberedLines(String output, List<String> fallback) {
  final Map<int, String> numbered = <int, String>{};
  for (final RegExpMatch match in _numberedLine.allMatches(output)) {
    numbered[int.parse(match[1]!)] = match[2]!.trim();
  }
  return <String>[
    for (int i = 0; i < fallback.length; i++) numbered[i + 1] ?? fallback[i],
  ];
}
