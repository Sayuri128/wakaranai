import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';
import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

const PageLanguage _ukrainian = PageLanguage('uk', 'Ukrainian');

const List<GlossaryEntry> _glossary = <GlossaryEntry>[
  GlossaryEntry(source: 'Kenji', target: 'Кендзі'),
  GlossaryEntry(source: 'Shibuya', target: 'Сібуя'),
];

void main() {
  test('title languages keep their glossary through storage', () {
    const TitleLanguages languages = TitleLanguages(
      source: PageLanguage.english,
      target: _ukrainian,
      glossary: _glossary,
    );

    final TitleLanguages? restored = TitleLanguages.decode(languages.encode());

    expect(restored, languages);
    expect(restored!.glossary, _glossary);
  });

  test('titles saved before glossaries still load', () {
    final TitleLanguages? restored = TitleLanguages.decode('en>uk');

    expect(restored?.source.code, 'en');
    expect(restored?.target.code, 'uk');
    expect(restored?.glossary, isEmpty);
  });

  test('only names that appear on the page are used', () {
    final List<GlossaryEntry> used = glossaryUsedIn(_glossary, <String>[
      'KENJI, wait!',
      'Where are you going?',
    ]);

    expect(used, <GlossaryEntry>[_glossary.first]);
  });

  test('the Gemma prompt lists the names to keep', () {
    final String prompt = buildGemmaPrompt(
      <String>['Kenji, wait!'],
      from: PageLanguage.english,
      to: _ukrainian,
      glossary: <GlossaryEntry>[_glossary.first],
    );

    expect(prompt, contains('Kenji → Кендзі'));
  });

  test('DeepL glossary entries are tab separated and skip blanks', () {
    final String entries = deepLGlossaryEntries(<GlossaryEntry>[
      ..._glossary,
      const GlossaryEntry(source: 'Mika', target: ' '),
    ]);

    expect(entries, 'Kenji\tКендзі\nShibuya\tСібуя');
  });
}
