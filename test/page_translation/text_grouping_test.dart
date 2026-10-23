import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/text_grouping.dart';

OcrBlock _column(double x, String text) {
  final Rect box = Rect.fromLTWH(x, 100, 20, 120);
  return OcrBlock(box: box, text: text, lines: <Rect>[box]);
}

void main() {
  test('adjacent vertical columns merge and read right to left', () {
    final List<TextGroup> groups = groupOcrBlocks(<OcrBlock>[
      _column(100, 'に'),
      _column(124, 'ちは'),
      _column(148, 'こん'),
    ], PageLanguage.japanese);

    expect(groups, hasLength(1));
    expect(groups.single.text, 'こんちはに');
    expect(groups.single.box, const Rect.fromLTRB(100, 100, 168, 220));
  });

  test('distant blocks stay separate and are ordered top to bottom', () {
    final List<TextGroup> groups = groupOcrBlocks(<OcrBlock>[
      const OcrBlock(
        box: Rect.fromLTWH(10, 400, 200, 20),
        text: 'second\nline',
        lines: <Rect>[Rect.fromLTWH(10, 400, 200, 20)],
      ),
      const OcrBlock(
        box: Rect.fromLTWH(10, 10, 200, 20),
        text: 'first',
        lines: <Rect>[Rect.fromLTWH(10, 10, 200, 20)],
      ),
    ], PageLanguage.english);

    expect(groups.map((TextGroup g) => g.text), <String>[
      'first',
      'second line',
    ]);
  });

  test('nearby blocks with a border between them stay separate', () {
    final List<OcrBlock> blocks = <OcrBlock>[
      const OcrBlock(
        box: Rect.fromLTWH(10, 10, 200, 20),
        text: 'first',
        lines: <Rect>[Rect.fromLTWH(10, 10, 200, 20)],
      ),
      const OcrBlock(
        box: Rect.fromLTWH(10, 36, 200, 20),
        text: 'second',
        lines: <Rect>[Rect.fromLTWH(10, 36, 200, 20)],
      ),
    ];

    expect(groupOcrBlocks(blocks, PageLanguage.english), hasLength(1));
    expect(
      groupOcrBlocks(
        blocks,
        PageLanguage.english,
        hasBorderBetween: (Rect a, Rect b) => true,
      ),
      hasLength(2),
    );
  });

  test('blocks without letters are dropped', () {
    final List<TextGroup> groups = groupOcrBlocks(<OcrBlock>[
      const OcrBlock(
        box: Rect.fromLTWH(10, 10, 40, 20),
        text: '!!…',
        lines: <Rect>[],
      ),
      const OcrBlock(
        box: Rect.fromLTWH(10, 300, 40, 20),
        text: '12',
        lines: <Rect>[],
      ),
    ], PageLanguage.english);

    expect(groups, isEmpty);
  });

  test('hyphenated line breaks are joined without a space', () {
    expect(
      joinOcrLines(<String>['SOME-', "THIN'", 'WITH NO', 'KILLING,'], ' '),
      "SOME-THIN' WITH NO KILLING,",
    );
    expect(joinOcrLines(<String>['A -', 'B'], ' '), 'A - B');
    expect(joinOcrLines(<String>['SWEET-', 'TALK HER'], ' '), 'SWEET-TALK HER');
  });

  test('all-caps comic lettering is turned into sentence case', () {
    expect(
      normalizeOcrText(
        'OH, AND I WANT FREE LUNCH! I\'M DEAD SERIOUS.',
        PageLanguage.english,
      ),
      "Oh, and I want free lunch! I'm dead serious.",
    );
    expect(
      normalizeOcrText('Already Mixed Case', PageLanguage.english),
      'Already Mixed Case',
    );
    expect(normalizeOcrText('こんにちは', PageLanguage.japanese), 'こんにちは');
  });

  test('extension languages map to OCR source languages', () {
    expect(PageLanguage.sourceForExtension('English'), PageLanguage.english);
    expect(PageLanguage.sourceForExtension(' 日本語 '), PageLanguage.japanese);
    expect(PageLanguage.sourceForExtension('Русский'), isNull);
    expect(PageLanguage.sourceForExtension('Multi'), isNull);
    expect(PageLanguage.sourceForExtension(null), isNull);
  });

  test('vowel-less sound effects are not treated as dialogue', () {
    expect(looksLikeSoundEffect('PSHHHHH', PageLanguage.english), isTrue);
    expect(looksLikeSoundEffect('Hh', PageLanguage.english), isTrue);
    expect(looksLikeSoundEffect('DRIP', PageLanguage.english), isFalse);
    expect(looksLikeSoundEffect('...!', PageLanguage.english), isFalse);
    expect(looksLikeSoundEffect('ジョボボ', PageLanguage.japanese), isFalse);
  });
}
