import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:wakaranai/services/page_translation/bubble_analyzer.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_service.dart';

BubbleLayout _layout(Rect box) => BubbleLayout(
  textBox: box,
  layoutBox: box,
  fillColor: 0xFFFFFFFF,
  erase: true,
);

void main() {
  test('regular pages are processed as one tile', () {
    expect(pageTiles(900, 1300), <PageTile>[const PageTile(0, 1300)]);
  });

  test('tall strips are split into overlapping tiles covering the page', () {
    final List<PageTile> tiles = pageTiles(800, 10000);

    expect(tiles.first.top, 0);
    expect(tiles.last.top + tiles.last.height, 10000);
    for (int i = 1; i < tiles.length; i++) {
      expect(tiles[i].top, lessThan(tiles[i - 1].top + tiles[i - 1].height));
      expect(tiles[i].height, lessThanOrEqualTo(1600));
    }
  });

  test('bubbles found twice in overlapping tiles are kept once', () {
    final List<BubbleLayout> kept = dropDuplicateBubbles(<BubbleLayout>[
      _layout(const Rect.fromLTWH(10, 10, 100, 50)),
      _layout(const Rect.fromLTWH(12, 12, 96, 46)),
      _layout(const Rect.fromLTWH(10, 300, 100, 50)),
    ]);

    expect(kept, hasLength(2));
  });

  test('results survive a JSON round trip', () {
    const PageTranslationResult result = PageTranslationResult(
      width: 800,
      height: 1200,
      bubbles: <TranslatedBubble>[
        TranslatedBubble(
          textBox: Rect.fromLTRB(1, 2, 3, 4),
          layoutBox: Rect.fromLTRB(0, 1, 5, 6),
          fillColor: 0xFFFEFEFE,
          erase: false,
          source: 'こんにちは',
          translation: 'Hello',
        ),
      ],
    );

    final PageTranslationResult decoded = PageTranslationResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
    );

    expect(decoded.width, 800);
    expect(decoded.height, 1200);
    final TranslatedBubble bubble = decoded.bubbles.single;
    expect(bubble.textBox, const Rect.fromLTRB(1, 2, 3, 4));
    expect(bubble.layoutBox, const Rect.fromLTRB(0, 1, 5, 6));
    expect(bubble.fillColor, 0xFFFEFEFE);
    expect(bubble.erase, isFalse);
    expect(bubble.source, 'こんにちは');
    expect(bubble.translation, 'Hello');
  });

  test('every offered language is supported by on-device translation', () {
    final Set<String> supported = TranslateLanguage.values
        .map((TranslateLanguage l) => l.bcpCode)
        .toSet();
    for (final PageLanguage language in <PageLanguage>[
      ...PageLanguage.sources,
      ...PageLanguage.targets,
    ]) {
      expect(supported, contains(language.code), reason: language.name);
    }
  });
}
