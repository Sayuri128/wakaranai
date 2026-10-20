import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

abstract class OcrTextCorrector {
  String correct(String text);
}

const Map<String, List<String>> _comicConfusions = <String, List<String>>{
  'w': <String>['u', 'n'],
  'j': <String>['u'],
  'a': <String>['u'],
  'h': <String>['u', 'n'],
  'v': <String>['u'],
  'n': <String>['u', 'h'],
  'u': <String>['n', 'v'],
  'ii': <String>['u'],
  'vv': <String>['w'],
  'rn': <String>['m'],
  'm': <String>['rn', 'u'],
  'cl': <String>['d'],
  'c': <String>['e'],
  'e': <String>['c'],
  'l': <String>['i', 't'],
  'i': <String>['l'],
  '0': <String>['o'],
  '1': <String>['l', 'i'],
  '5': <String>['s'],
  '2': <String>['z'],
  'dd': <String>["'d"],
  'nt': <String>["n't"],
  'ts': <String>["t's"],
  'im': <String>["i'm"],
  'll': <String>["'ll"],
  're': <String>["'re"],
  've': <String>["'ve"],
};

const List<String> _englishContractions = <String>[
  "don't",
  "didn't",
  "doesn't",
  "isn't",
  "wasn't",
  "weren't",
  "aren't",
  "haven't",
  "hasn't",
  "hadn't",
  "couldn't",
  "wouldn't",
  "shouldn't",
  "won't",
  "can't",
  "ain't",
  "mustn't",
  "needn't",
  "i'm",
  "i'd",
  "i'll",
  "i've",
  "you're",
  "you'd",
  "you'll",
  "you've",
  "he's",
  "he'd",
  "he'll",
  "she's",
  "she'd",
  "she'll",
  "it's",
  "it'd",
  "it'll",
  "we're",
  "we'd",
  "we'll",
  "we've",
  "they're",
  "they'd",
  "they'll",
  "they've",
  "that's",
  "that'd",
  "that'll",
  "there's",
  "what's",
  "who's",
  "let's",
  "here's",
  "where's",
  "how's",
];

const Set<String> _realWordsWithoutApostrophe = <String>{
  'its',
  'were',
  'well',
  'ill',
  'wed',
  'hell',
  'shell',
  'cant',
  'wont',
  'id',
  'lets',
  'shed',
  'hed',
  'whos',
  'hes',
  'shes',
  'whats',
  'heres',
};

class WordListCorrector implements OcrTextCorrector {
  WordListCorrector(this._ranks, {this.maxEdits = 2})
    : _restore = _contractionsToRestore(_ranks);

  factory WordListCorrector.fromWordList(String content) {
    final Map<String, int> ranks = <String, int>{};
    int rank = 0;
    for (final String line in content.split('\n')) {
      final String word = line.trim();
      if (word.isEmpty || ranks.containsKey(word)) {
        continue;
      }
      rank++;
      ranks[word] = rank;
    }
    for (final String contraction in _englishContractions) {
      final String stem = contraction.split("'").first;
      ranks.putIfAbsent(
        contraction,
        () => ranks[stem] ?? _unknownContractionRank,
      );
    }
    return WordListCorrector(ranks);
  }

  final Map<String, int> _ranks;
  final Map<String, String> _restore;
  final int maxEdits;

  static const int _unknownContractionRank = 100;
  static const int _rareRank = 10000;
  static const int _rareMargin = 100;

  static final RegExp _token = RegExp(r"[A-Za-z0-9]+(?:['’][A-Za-z]+)*");
  static final RegExp _hyphenated = RegExp(r'\b([A-Za-z0-9]+)-([A-Za-z]+)\b');
  static final RegExp _hasLetter = RegExp('[A-Za-z]');

  static Map<String, String> _contractionsToRestore(Map<String, int> ranks) {
    final Map<String, String> restore = <String, String>{};
    for (final String contraction in _englishContractions) {
      final String withoutApostrophe = contraction.replaceAll("'", '');
      final bool known = ranks.containsKey(contraction);
      final bool ambiguous = _realWordsWithoutApostrophe.contains(
        withoutApostrophe,
      );
      if (known && !ambiguous) {
        restore[withoutApostrophe] = contraction;
      }
    }
    return restore;
  }

  @override
  String correct(String text) {
    final String merged = text.replaceAllMapped(
      _hyphenated,
      _mergeHyphenatedWord,
    );
    return merged.replaceAllMapped(
      _token,
      (Match match) => _correctToken(match[0]!),
    );
  }

  String _mergeHyphenatedWord(Match match) {
    final String joined = match[1]! + match[2]!;
    final String? word = _bestWordFor(joined.toLowerCase());
    if (word == null) {
      return match[0]!;
    }
    return _matchCase(joined, word);
  }

  bool _isCorrectable(String token) {
    final bool hasApostrophe = token.contains("'") || token.contains('’');
    return token.length >= 2 && !hasApostrophe && _hasLetter.hasMatch(token);
  }

  String _correctToken(String token) {
    if (!_isCorrectable(token)) {
      return token;
    }
    final String? word = _bestWordFor(token.toLowerCase());
    if (word == null) {
      return token;
    }
    final String cased = _matchCase(token, word);
    if (cased.startsWith("i'")) {
      return 'I${cased.substring(1)}';
    }
    return cased;
  }

  String? _bestWordFor(String lower) {
    final String? restored = _restore[lower];
    if (restored != null) {
      return restored;
    }
    final int? rank = _ranks[lower];
    if (rank != null && rank <= _rareRank) {
      return lower;
    }

    String? best;
    int? bestRank;
    for (final String candidate in _confusionVariants(lower)) {
      final int? candidateRank = _ranks[candidate];
      if (candidateRank == null) {
        continue;
      }
      if (bestRank == null || candidateRank < bestRank) {
        best = candidate;
        bestRank = candidateRank;
      }
    }

    if (best == null || bestRank == null) {
      return rank == null ? null : lower;
    }
    if (rank == null) {
      return best;
    }
    final bool muchMoreCommon = bestRank * _rareMargin < rank;
    return muchMoreCommon ? best : lower;
  }

  Set<String> _confusionVariants(String word) {
    final Set<String> found = <String>{};

    void expand(String current, int from, int edits) {
      if (edits == maxEdits) {
        return;
      }
      for (int i = from; i < current.length; i++) {
        for (final MapEntry<String, List<String>> confusion
            in _comicConfusions.entries) {
          final String misread = confusion.key;
          if (!current.startsWith(misread, i)) {
            continue;
          }
          for (final String replacement in confusion.value) {
            final String before = current.substring(0, i);
            final String after = current.substring(i + misread.length);
            final String variant = before + replacement + after;
            if (found.add(variant)) {
              expand(variant, i + replacement.length, edits + 1);
            }
          }
        }
      }
    }

    expand(word, 0, 0);
    found.remove(word);
    return found;
  }

  static String _matchCase(String original, String replacement) {
    if (original == original.toUpperCase()) {
      return replacement.toUpperCase();
    }
    if (original[0] == original[0].toUpperCase()) {
      return replacement[0].toUpperCase() + replacement.substring(1);
    }
    return replacement;
  }
}

class OcrCorrectors {
  static const Map<String, String> _wordLists = <String, String>{
    'en': 'assets/dictionaries/en_words.txt',
  };

  static final Map<String, Future<OcrTextCorrector?>> _cache =
      <String, Future<OcrTextCorrector?>>{};

  static Future<OcrTextCorrector?> forLanguage(
    PageLanguage language, {
    AssetBundle? bundle,
  }) {
    final String? asset = _wordLists[language.code];
    if (asset == null) {
      return Future<OcrTextCorrector?>.value();
    }
    return _cache.putIfAbsent(language.code, () async {
      final String content = await (bundle ?? rootBundle).loadString(asset);
      return compute(_parseWordList, content);
    });
  }
}

WordListCorrector _parseWordList(String content) =>
    WordListCorrector.fromWordList(content);
