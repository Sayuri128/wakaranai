import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';

void main() {
  testWidgets('a title without a cover shows its name and stays tappable', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            height: 180,
            child: GalleryViewCard(
              uid: 'work',
              headers: const <String, String>{},
              cover: '',
              title: 'Untitled work',
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Untitled work'), findsOneWidget);
    expect(find.byType(Ink), findsNothing);
    await tester.tap(find.text('Untitled work'));
    expect(taps, 1);
  });
}
