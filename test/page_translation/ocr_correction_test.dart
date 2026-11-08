import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/ocr_correction.dart';

void main() {
  final WordListCorrector corrector = WordListCorrector.fromWordList(
    File('assets/dictionaries/en_words.txt').readAsStringSync(),
  );

  test('comic-font misreads seen on real pages are repaired', () {
    expect(
      corrector.correct('SWEET-TALK HER INTO WORKING FOR WS AGAIN.'),
      'SWEET-TALK HER INTO WORKING FOR US AGAIN.',
    );
    expect(
      corrector.correct('Oh, and I want free lanch!'),
      'Oh, and I want free lunch!',
    );
    expect(corrector.correct('Qait messing around!'), 'Quit messing around!');
    expect(corrector.correct('Where I jwst stand'), 'Where I just stand');
  });

  test('common real words are never replaced', () {
    const String text = 'What was that bat, wait, the hat and was a hut';
    expect(corrector.correct(text), text);
  });

  test('names, numbers and slang contractions are left alone', () {
    const String text = "Nighthawk owes 500 yen, somethin' 'kay?";
    expect(corrector.correct(text), text);
  });

  test('letter case of the original word is kept', () {
    expect(corrector.correct('ws'), 'us');
    expect(corrector.correct('Ws'), 'Us');
    expect(corrector.correct('WS'), 'US');
  });

  test('words split by a hyphen at a line break are merged when real', () {
    expect(
      corrector.correct("THATDD BE BAD FOR BJSI-NESS."),
      "THAT'D BE BAD FOR BUSINESS.",
    );
    expect(corrector.correct('SWEET-TALK HER'), 'SWEET-TALK HER');
  });

  test('lost apostrophes and other glyph misreads are restored', () {
    expect(
      corrector.correct('I didnt hear the tap.'),
      "I didn't hear the tap.",
    );
    expect(corrector.correct('Dombt it.'), 'Doubt it.');
    expect(corrector.correct('"THE RETHRW OF"'), '"THE RETURN OF"');
    expect(corrector.correct('STRONG 2ERO'), 'STRONG ZERO');
    expect(
      corrector.correct('Well, im sure youre right'),
      "Well, I'm sure you're right",
    );
    expect(corrector.correct('its fine, well see'), 'its fine, well see');
  });
}
