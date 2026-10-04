import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';

MangaConcreteView _view({
  List<String> authors = const <String>[],
  List<String> artists = const <String>[],
  int? year,
  num? rating,
  String? url,
}) =>
    MangaConcreteView(
      uid: 'u',
      cover: '',
      title: 'Title',
      alternativeTitles: const <String>[],
      description: '',
      tags: const <String>[],
      status: MangaStatus.ONGOING,
      groups: const [],
      authors: authors,
      artists: artists,
      year: year,
      rating: rating,
      url: url,
    );

Future<void> _pump(WidgetTester tester, MangaConcreteView view) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: ConcreteMetadataRow(view: view)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('has no content without metadata', () {
    expect(ConcreteMetadataRow.hasContent(_view()), isFalse);
    expect(ConcreteMetadataRow.hasContent(_view(year: 2001)), isTrue);
  });

  testWidgets('shows authors, distinct artists, year, rating and a website link',
      (WidgetTester tester) async {
    await _pump(
      tester,
      _view(
        authors: <String>['Oda'],
        artists: <String>['Oda', 'Someone'],
        year: 1997,
        rating: 9,
        url: 'https://example.com',
      ),
    );

    expect(find.text('By Oda'), findsOneWidget);
    expect(find.text('Art by Someone'), findsOneWidget);
    expect(find.text('1997'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Open website'), findsOneWidget);
  });

  testWidgets('hides artists that are also authors and formats ratings',
      (WidgetTester tester) async {
    await _pump(
      tester,
      _view(authors: <String>['Oda'], artists: <String>['Oda'], rating: 8.66),
    );

    expect(find.textContaining('Art by'), findsNothing);
    expect(find.text('8.7'), findsOneWidget);
    expect(find.text('Open website'), findsNothing);
  });
}
