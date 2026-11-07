import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_any/multiple_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_any/one_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_any/multiple_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_any/one_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_selection.dart';
import 'package:wakaranai/ui/services/filters/gallery_filters_sheet.dart';

final GalleryFilterMultipleOfMultiple _genres = GalleryFilterMultipleOfMultiple(
  paramName: 'Genres',
  param: 'genres',
  type: GalleryFilterType.MULTIPLE_OF_MULTIPLE,
  values: <List<String>>[
    List<String>.generate(20, (int index) => 'g$index'),
  ],
  labels: <List<String>>[
    List<String>.generate(20, (int index) => 'Genre $index'),
  ],
);

final GalleryFilterMultipleOfMultiple _grouped = GalleryFilterMultipleOfMultiple(
  paramName: 'Type',
  param: 'types',
  type: GalleryFilterType.MULTIPLE_OF_MULTIPLE,
  values: <List<String>>[
    <String>['manga', 'manhwa'],
    <String>['oel'],
  ],
  labels: <List<String>>[
    <String>['Manga', 'Manhwa'],
    <String>['OEL'],
  ],
);

const GalleryFilterOneOfMultiple _status = GalleryFilterOneOfMultiple(
  paramName: 'Status',
  param: 'status',
  type: GalleryFilterType.ONE_OF_MULTIPLE,
  values: <String>['ongoing', 'completed'],
  labels: <String>['Ongoing', 'Completed'],
);

final GalleryFilterSwitcher _matchAll = GalleryFilterSwitcher(
  paramName: 'Match all',
  param: 'mode',
  type: GalleryFilterType.SWITCHER,
  onValue: 'AND',
  offValue: 'OR',
);

const GalleryFilterRange _year = GalleryFilterRange(
  paramName: 'Year',
  param: 'year',
  type: GalleryFilterType.RANGE,
  paramMin: 'year_min',
  paramMax: 'year_max',
  min: 1930,
);

const GalleryFilterRange _rating = GalleryFilterRange(
  paramName: 'Rating',
  param: 'rating',
  type: GalleryFilterType.RANGE,
  paramMin: 'rating_min',
  paramMax: 'rating_max',
  min: 0,
  max: 10,
);

const GalleryFilterOneOfAny _author = GalleryFilterOneOfAny(
  paramName: 'Author',
  param: 'author',
  type: GalleryFilterType.ONE_OF_ANY,
);

const GalleryFilterMultipleOfAny _exclude = GalleryFilterMultipleOfAny(
  paramName: 'Exclude',
  param: 'exclude',
  type: GalleryFilterType.MULTIPLE_OF_ANY,
);

List<GalleryFilter> _filters() => <GalleryFilter>[
      _genres,
      _grouped,
      _status,
      _matchAll,
      _year,
      _rating,
      _author,
      _exclude,
    ];

Map<String, dynamic> _json(Map<String, FilterData> data) {
  return data.map(
    (String key, FilterData value) =>
        MapEntry<String, dynamic>(key, value.toJson()),
  );
}

Map<String, FilterData> _fullSelection() => <String, FilterData>{
      'genres': FilterDataMultipleOfMultiple(
        selected: <List<String>>[
          <String>['g4', 'g1'],
        ],
        filter: _genres,
      ),
      'types': FilterDataMultipleOfMultiple(
        selected: <List<String>>[
          <String>[],
          <String>['oel'],
        ],
        filter: _grouped,
      ),
      'status': const FilterDataOneOfMultiple(
        selected: 'completed',
        filter: _status,
      ),
      'mode': FilterDataSwitcher(on: true, filter: _matchAll),
      'year': const FilterDataRange(from: '2015', filter: _year),
      'rating': const FilterDataRange(from: '3', to: '8', filter: _rating),
      'author': const FilterDataOneOfAny(selected: 'Oda', filter: _author),
      'exclude': const FilterDataMultipleOfAny(
        selected: <String>['gore', 'ntr'],
        filter: _exclude,
      ),
    };

class _SheetHarness {
  Map<String, FilterData>? result;
  bool closed = false;
}

Future<_SheetHarness> _openSheet(
  WidgetTester tester, {
  List<GalleryFilter>? filters,
  Map<String, FilterData> current = const <String, FilterData>{},
}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final _SheetHarness harness = _SheetHarness();
  await tester.pumpWidget(_app(Builder(
    builder: (BuildContext context) => Center(
      child: ElevatedButton(
        onPressed: () async {
          harness.result = await showGalleryFiltersSheet(
            context,
            filters: filters ?? _filters(),
            current: current,
          );
          harness.closed = true;
        },
        child: const Text('open'),
      ),
    ),
  )));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return harness;
}

Widget _app(Widget body) {
  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: body),
  );
}

Future<void> _apply(WidgetTester tester) async {
  await tester.tap(find.text('Apply'));
  await tester.pumpAndSettle();
}

Finder _sectionText(String section, String text) {
  return find.descendant(
    of: find.ancestor(of: find.text(section), matching: find.byType(Material))
        .first,
    matching: find.text(text),
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  group('GalleryFilterSelection', () {
    test('seeds every filter type and rebuilds the same data', () {
      final GalleryFilterSelection selection = GalleryFilterSelection(
        filters: _filters(),
        current: _fullSelection(),
      );

      expect(_json(selection.build()), _json(_fullSelection()));
      expect(selection.activeCount, 8);
    });

    test('keeps the tap order inside each group', () {
      final GalleryFilterSelection selection =
          GalleryFilterSelection(filters: _filters());
      final List<GalleryFilterOption> options =
          GalleryFilterSelection.optionsOf(_grouped);

      selection.toggleOption(_grouped, options[2]);
      selection.toggleOption(_grouped, options[1]);
      selection.toggleOption(_grouped, options[0]);

      final FilterDataMultipleOfMultiple data =
          selection.build()['types']! as FilterDataMultipleOfMultiple;
      expect(data.selected, <List<String>>[
        <String>['manhwa', 'manga'],
        <String>['oel'],
      ]);
    });

    test('drops filters that end up empty', () {
      final GalleryFilterSelection selection = GalleryFilterSelection(
        filters: _filters(),
        current: _fullSelection(),
      );
      final List<GalleryFilterOption> options =
          GalleryFilterSelection.optionsOf(_grouped);

      selection.toggleOption(_grouped, options[2]);
      selection.setText(_author, '   ');
      selection.setRangeFrom(_year, '');
      selection.setSwitch(_matchAll, false);
      selection.clearFilter(_exclude);

      expect(
        selection.build().keys,
        unorderedEquals(<String>['genres', 'status', 'rating']),
      );
    });
  });

  group('GalleryFiltersSheet', () {
    testWidgets('applying an untouched sheet returns the current data',
        (WidgetTester tester) async {
      final _SheetHarness harness =
          await _openSheet(tester, current: _fullSelection());

      expect(find.text('8 filters active'), findsOneWidget);
      await _apply(tester);

      expect(_json(harness.result!), _json(_fullSelection()));
    });

    testWidgets('builds filter data from chips, switch and text input',
        (WidgetTester tester) async {
      final _SheetHarness harness = await _openSheet(tester);

      expect(find.text('Showing everything'), findsOneWidget);
      await tester.tap(find.text('Genre 3'));
      await tester.tap(find.text('Genre 0'));
      await tester.tap(find.text('OEL'));
      await tester.tap(find.text('Ongoing'));
      await tester.tap(find.text('Match all'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter a value'),
        '  Oda ',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Type and add'),
        'gore',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('6 filters active'), findsOneWidget);
      await _apply(tester);

      expect(_json(harness.result!), <String, dynamic>{
        'genres': FilterDataMultipleOfMultiple(
          selected: <List<String>>[
            <String>['g3', 'g0'],
          ],
          filter: _genres,
        ).toJson(),
        'types': FilterDataMultipleOfMultiple(
          selected: <List<String>>[
            <String>[],
            <String>['oel'],
          ],
          filter: _grouped,
        ).toJson(),
        'status': const FilterDataOneOfMultiple(
          selected: 'ongoing',
          filter: _status,
        ).toJson(),
        'mode': FilterDataSwitcher(on: true, filter: _matchAll).toJson(),
        'author': const FilterDataOneOfAny(selected: 'Oda', filter: _author)
            .toJson(),
        'exclude': const FilterDataMultipleOfAny(
          selected: <String>['gore'],
          filter: _exclude,
        ).toJson(),
      });
    });

    testWidgets('single choice clears through Any or a second tap',
        (WidgetTester tester) async {
      final _SheetHarness harness = await _openSheet(tester);

      await tester.tap(find.text('Completed'));
      await tester.pump();
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(find.text('Showing everything'), findsOneWidget);

      await tester.tap(find.text('Ongoing'));
      await tester.pump();
      await tester.tap(_sectionText('Status', 'Any'));
      await tester.pump();
      await _apply(tester);

      expect(harness.result, isEmpty);
    });

    testWidgets('long option lists preview, expand and search',
        (WidgetTester tester) async {
      await _openSheet(
        tester,
        current: <String, FilterData>{
          'genres': FilterDataMultipleOfMultiple(
            selected: <List<String>>[
              <String>['g17'],
            ],
            filter: _genres,
          ),
        },
      );

      expect(find.text('Genre 9'), findsOneWidget);
      expect(find.text('Genre 10'), findsNothing);
      expect(find.text('Genre 17'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));

      await tester.tap(find.text('Show all 20'));
      await tester.pumpAndSettle();
      expect(find.text('Genre 10'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Search Genres'),
        'genre 1',
      );
      await tester.pumpAndSettle();
      expect(find.text('Genre 2'), findsNothing);
      expect(find.text('Genre 12'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'genre 1'),
        'zzz',
      );
      await tester.pumpAndSettle();
      expect(find.text('No matches'), findsOneWidget);

      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(find.text('Genre 10'), findsNothing);
      expect(find.text('Show all 20'), findsOneWidget);
    });

    testWidgets('the range slider writes bounds and clears at the ends',
        (WidgetTester tester) async {
      final _SheetHarness harness = await _openSheet(tester);

      expect(find.byType(RangeSlider), findsOneWidget);
      final RangeSlider slider =
          tester.widget<RangeSlider>(find.byType(RangeSlider));
      slider.onChanged!(const RangeValues(3, 10));
      await tester.pump();
      expect(find.widgetWithText(TextField, '3'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '1930'), '1999');
      await tester.pump();
      await _apply(tester);

      expect(_json(harness.result!), <String, dynamic>{
        'year': const FilterDataRange(from: '1999', filter: _year).toJson(),
        'rating': const FilterDataRange(from: '3', filter: _rating).toJson(),
      });
    });

    testWidgets('section clear and reset empty the selection',
        (WidgetTester tester) async {
      final _SheetHarness harness =
          await _openSheet(tester, current: _fullSelection());

      await tester.tap(_sectionText('Rating', 'Clear'));
      await tester.pump();
      expect(find.text('7 filters active'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('Showing everything'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2015'), findsNothing);
      await _apply(tester);

      expect(harness.result, isEmpty);
    });

    testWidgets('a source without filters shows an empty state',
        (WidgetTester tester) async {
      await _openSheet(tester, filters: <GalleryFilter>[]);

      expect(find.text('No filters'), findsOneWidget);
      expect(find.text('Apply'), findsNothing);
    });
  });
}
