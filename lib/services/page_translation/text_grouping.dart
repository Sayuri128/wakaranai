import 'dart:math';
import 'dart:ui';

import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class TextGroup {
  const TextGroup({required this.box, required this.text});

  final Rect box;
  final String text;
}

final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _whitespace = RegExp(r'\s+');

const double _blockReach = 0.8;

typedef BorderCheck = bool Function(Rect a, Rect b);

List<TextGroup> groupOcrBlocks(
  List<OcrBlock> blocks,
  PageLanguage language, {
  BorderCheck? hasBorderBetween,
}) {
  final List<OcrBlock> kept = blocks
      .where((OcrBlock block) => _letter.hasMatch(block.text))
      .where((OcrBlock block) => !block.box.isEmpty)
      .toList();
  if (kept.isEmpty) {
    return const <TextGroup>[];
  }

  final String joiner = language.usesSpaces ? ' ' : '';
  final List<TextGroup> groups = <TextGroup>[];
  final Iterable<List<OcrBlock>> clusters = _clusterNearbyBlocks(
    kept,
    hasBorderBetween,
  );
  for (final List<OcrBlock> cluster in clusters) {
    _sortInReadingOrder(cluster);
    final Rect box = cluster
        .map((OcrBlock block) => block.box)
        .reduce((Rect a, Rect b) => a.expandToInclude(b));
    final List<String> lines = <String>[
      for (final OcrBlock block in cluster)
        for (final String line in block.text.split('\n'))
          if (line.trim().isNotEmpty) line.trim(),
    ];
    final String joined = joinOcrLines(lines, joiner);
    final String text = normalizeOcrText(joined, language);
    if (looksLikeSoundEffect(text, language)) {
      continue;
    }
    groups.add(TextGroup(box: box, text: text));
  }
  groups.sort((TextGroup a, TextGroup b) => a.box.top.compareTo(b.box.top));
  return groups;
}

Iterable<List<OcrBlock>> _clusterNearbyBlocks(
  List<OcrBlock> blocks,
  BorderCheck? hasBorderBetween,
) {
  final _DisjointSets sets = _DisjointSets(blocks.length);
  final List<Rect> reach = blocks
      .map(
        (OcrBlock block) => block.box.inflate(_charSize(block) * _blockReach),
      )
      .toList();
  for (int i = 0; i < blocks.length; i++) {
    for (int j = i + 1; j < blocks.length; j++) {
      final bool sameDirection =
          _isVertical(blocks[i]) == _isVertical(blocks[j]);
      if (!sameDirection || !reach[i].overlaps(reach[j])) {
        continue;
      }
      final bool separated =
          hasBorderBetween?.call(blocks[i].box, blocks[j].box) ?? false;
      if (!separated) {
        sets.union(i, j);
      }
    }
  }

  final Map<int, List<OcrBlock>> clusters = <int, List<OcrBlock>>{};
  for (int i = 0; i < blocks.length; i++) {
    clusters.putIfAbsent(sets.find(i), () => <OcrBlock>[]).add(blocks[i]);
  }
  return clusters.values;
}

void _sortInReadingOrder(List<OcrBlock> cluster) {
  if (_isVertical(cluster.first)) {
    cluster.sort(
      (OcrBlock a, OcrBlock b) => b.box.right.compareTo(a.box.right),
    );
  } else {
    cluster.sort((OcrBlock a, OcrBlock b) => a.box.top.compareTo(b.box.top));
  }
}

class _DisjointSets {
  _DisjointSets(int size) : _parent = List<int>.generate(size, (int i) => i);

  final List<int> _parent;

  int find(int item) {
    int current = item;
    while (_parent[current] != current) {
      _parent[current] = _parent[_parent[current]];
      current = _parent[current];
    }
    return current;
  }

  void union(int a, int b) {
    _parent[find(a)] = find(b);
  }
}

final RegExp _latinLetter = RegExp('[A-Za-z]');
final RegExp _latinVowel = RegExp('[AEIOUYaeiouy]');

bool looksLikeSoundEffect(String text, PageLanguage language) {
  if (language.script != OcrScript.latin) {
    return false;
  }
  return _latinLetter.hasMatch(text) && !_latinVowel.hasMatch(text);
}

final RegExp _hyphenEnd = RegExp(r'\p{L}[-‐]$', unicode: true);
final RegExp _startsWithLetter = RegExp(r'^\p{L}', unicode: true);

String joinOcrLines(List<String> lines, String joiner) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    buffer.write(line);
    final bool last = i == lines.length - 1;
    if (last) {
      continue;
    }
    final bool wordContinues =
        joiner.isNotEmpty &&
        _hyphenEnd.hasMatch(line) &&
        _startsWithLetter.hasMatch(lines[i + 1]);
    if (!wordContinues) {
      buffer.write(joiner);
    }
  }
  return buffer.toString().replaceAll(_whitespace, ' ').trim();
}

final RegExp _upper = RegExp(r'\p{Lu}', unicode: true);
final RegExp _lower = RegExp(r'\p{Ll}', unicode: true);
final RegExp _sentenceStart = RegExp(
  r'(^|[.!?…]\s+|["“«(]\s*)(\p{Ll})',
  unicode: true,
);
const double _uppercaseShare = 0.8;
final RegExp _englishI = RegExp(r"\bi\b(?=$|[\s,.!?'’])");

String normalizeOcrText(String text, PageLanguage language) {
  if (language.script != OcrScript.latin) {
    return text;
  }
  final int upper = _upper.allMatches(text).length;
  final int lower = _lower.allMatches(text).length;
  final bool mostlyUppercase = upper >= (upper + lower) * _uppercaseShare;
  if (upper < 2 || !mostlyUppercase) {
    return text;
  }

  String result = text.toLowerCase().replaceAllMapped(
    _sentenceStart,
    (Match match) => '${match[1]}${match[2]!.toUpperCase()}',
  );
  if (language.code == 'en') {
    result = result.replaceAll(_englishI, 'I');
  }
  return result;
}

const double _verticalLineRatio = 1.3;

List<Rect> _lineBoxes(OcrBlock block) {
  if (block.lines.isEmpty) {
    return <Rect>[block.box];
  }
  return block.lines;
}

double _charSize(OcrBlock block) {
  final List<double> sizes = _lineBoxes(
    block,
  ).map((Rect line) => min(line.width, line.height)).toList();
  sizes.sort();
  return sizes[sizes.length ~/ 2];
}

bool _isVertical(OcrBlock block) {
  final List<Rect> lines = _lineBoxes(block);
  final int tallLines = lines
      .where((Rect line) => line.height > line.width * _verticalLineRatio)
      .length;
  return tallLines * 2 > lines.length;
}
