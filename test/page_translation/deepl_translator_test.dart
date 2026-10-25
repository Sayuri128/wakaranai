import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

void main() {
  test('free keys use the free API host', () {
    expect(deepLBaseUrl('abc-123:fx'), 'https://api-free.deepl.com');
    expect(deepLBaseUrl('abc-123'), 'https://api.deepl.com');
  });

  test('targets that need a regional variant are mapped', () {
    expect(deepLTargetCode(PageLanguage.english), 'EN-US');
    expect(deepLTargetCode(const PageLanguage('pt', 'Portuguese')), 'PT-BR');
    expect(deepLTargetCode(PageLanguage.chinese), 'ZH-HANS');
    expect(deepLTargetCode(const PageLanguage('uk', 'Ukrainian')), 'UK');
    expect(deepLSourceCode(PageLanguage.english), 'EN');
  });

  test('the request carries the whole page as unbilled context', () {
    final Map<String, Object> request = buildDeepLRequest(
      <String>['What kinda pro gets spooked?', 'By rumors?'],
      from: PageLanguage.english,
      to: const PageLanguage('uk', 'Ukrainian'),
      context: 'What kinda pro gets spooked?\nBy rumors?',
    );

    expect(request['source_lang'], 'EN');
    expect(request['target_lang'], 'UK');
    expect(request['text'], hasLength(2));
    expect(request['context'], contains('rumors'));
  });

  test('missing translations come back empty', () {
    final List<String> translations = parseDeepLTranslations(<String, dynamic>{
      'translations': <Map<String, dynamic>>[
        <String, dynamic>{'text': ' Що це за профі? '},
      ],
    }, 2);

    expect(translations, <String>['Що це за профі?', '']);
  });

  test('usage share is safe without a limit', () {
    const DeepLUsage usage = DeepLUsage(characterCount: 10, characterLimit: 0);
    expect(usage.usedShare, 0);
    expect(
      const DeepLUsage(
        characterCount: 250000,
        characterLimit: 500000,
      ).usedShare,
      0.5,
    );
  });
}
