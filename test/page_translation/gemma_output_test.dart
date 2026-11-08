import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/llm_prompt.dart';

void main() {
  test('a clean JSON array is used as is', () {
    expect(parseTranslations('["Один", "Два", "Три"]', 3), <String>[
      'Один',
      'Два',
      'Три',
    ]);
  });

  test('JSON wrapped in prose or a code fence is extracted', () {
    expect(
      parseTranslations(
        'Here you go:\n```json\n["Один", "Два", "Три"]\n```',
        3,
      ),
      <String>['Один', 'Два', 'Три'],
    );
  });

  test('missing bubbles in a short array are left empty, not copied', () {
    expect(parseTranslations('["Один", ""]', 3), <String?>['Один', null, null]);
  });

  test('a numbered list is accepted when there is no JSON', () {
    expect(parseTranslations('1. Один\n2) Два\n3. Три', 3), <String>[
      'Один',
      'Два',
      'Три',
    ]);
  });

  test('unusable output gives no translations', () {
    expect(parseTranslations('I cannot help with that.', 3), <String?>[
      null,
      null,
      null,
    ]);
  });

  test('an answer that repeats the source is recognised as untranslated', () {
    expect(isUntranslatedEcho("WHAT'S THIS?!", "What's this?"), isTrue);
    expect(isUntranslatedEcho('WHAT IS THIS?', 'Що це?'), isFalse);
  });
}
