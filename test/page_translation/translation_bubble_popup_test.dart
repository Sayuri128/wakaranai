import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_bubble_popup.dart';

const TranslatedBubble _bubble = TranslatedBubble(
  textBox: Rect.fromLTRB(10, 10, 60, 40),
  layoutBox: Rect.fromLTRB(0, 0, 70, 50),
  fillColor: 0xFFFFFFFF,
  erase: true,
  source: 'WHAT IS THIS?',
  translation: 'Що це?',
);

void main() {
  setUpAll(() => S.load(const Locale('en')));

  testWidgets('tapping a bubble shows the original, the translation and a '
      'retranslate action', (WidgetTester tester) async {
    final List<String> retranslated = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () => showTranslationBubblePopup(
                  context,
                  bubbleArea: const Rect.fromLTRB(40, 40, 200, 120),
                  bubble: _bubble,
                  onRetranslate: (String source) async {
                    retranslated.add(source);
                    return 'Що це таке?';
                  },
                  onEdit: () {},
                ),
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('WHAT IS THIS?'), findsOneWidget);
    expect(find.text('Що це?'), findsOneWidget);

    await tester.tap(find.text(S.current.page_translation_retranslate));
    await tester.pumpAndSettle();

    expect(retranslated, <String>['WHAT IS THIS?']);
    expect(find.text('Що це таке?'), findsOneWidget);
  });
}
