import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';

void main() {
  const List<String> sources = <String>['ONE', 'TWO', 'THREE'];

  test('a clean JSON array is used as is', () {
    expect(parseTranslations('["Один", "Два", "Три"]', sources), <String>[
      'Один',
      'Два',
      'Три',
    ]);
  });

  test('JSON wrapped in prose or a code fence is extracted', () {
    expect(
      parseTranslations(
        'Here you go:\n```json\n["Один", "Два", "Три"]\n```',
        sources,
      ),
      <String>['Один', 'Два', 'Три'],
    );
  });

  test('a short array keeps the original text for missing bubbles', () {
    expect(parseTranslations('["Один"]', sources), <String>[
      'Один',
      'TWO',
      'THREE',
    ]);
  });

  test('a numbered list is accepted when there is no JSON', () {
    expect(parseTranslations('1. Один\n2) Два\n3. Три', sources), <String>[
      'Один',
      'Два',
      'Три',
    ]);
  });

  test('unusable output falls back to the source text', () {
    expect(parseTranslations('I cannot help with that.', sources), sources);
  });
}
