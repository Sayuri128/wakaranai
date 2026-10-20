import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_typesetter.dart';

void main() {
  test('the translation is sized to fill but not overflow its box', () {
    const Size box = Size(200, 120);
    final TextPainter painter = fitTranslation(
      'Where did you put the key I gave you yesterday?',
      box,
      color: Colors.black,
    );
    addTearDown(painter.dispose);

    expect(painter.height, lessThanOrEqualTo(box.height));
    expect(painter.width, lessThanOrEqualTo(box.width));
    expect(painter.height, greaterThan(box.height * 0.5));
  });

  test('a short word in a big bubble does not grow without bound', () {
    const Size box = Size(300, 300);
    final TextPainter painter = fitTranslation('Eh?', box, color: Colors.black);
    addTearDown(painter.dispose);

    expect(
      painter.preferredLineHeight,
      lessThanOrEqualTo(box.width * 0.6 * 1.2),
    );
    expect(painter.width, lessThanOrEqualTo(box.width));
  });

  test('text colour contrasts with the bubble fill', () {
    expect(translationTextColor(Colors.white), const Color(0xFF111111));
    expect(translationTextColor(Colors.black), Colors.white);
  });

  test('long words are never split across lines', () {
    const Size box = Size(90, 200);
    final TextPainter painter = fitTranslation(
      'Ви загинчуєте зі мною, вірно?',
      box,
      color: Colors.black,
    );
    addTearDown(painter.dispose);

    final TextPainter word = TextPainter(
      text: TextSpan(text: 'загинчуєте', style: painter.text!.style),
      textDirection: TextDirection.ltr,
    )..layout();
    addTearDown(word.dispose);

    expect(word.width, lessThanOrEqualTo(box.width + 0.5));
  });
}
