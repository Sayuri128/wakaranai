import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_sheet.dart';

const String _uid = 'ext-sheet';

ConfigInfo _config() => ConfigInfo.fromJson(<String, dynamic>{
      'name': 'Sheet Source',
      'uid': _uid,
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
      'preferences': <dynamic>[
        <String, dynamic>{
          'key': 'adult',
          'type': 'toggle',
          'title': 'Show adult titles',
          'summary': 'Includes 18+ results',
        },
        <String, dynamic>{
          'key': 'lang',
          'type': 'select',
          'title': 'Language',
          'default': 'en',
          'options': <dynamic>[
            <String, dynamic>{'value': 'en', 'label': 'English'},
            <String, dynamic>{'value': 'ja', 'label': 'Japanese'},
          ],
        },
        <String, dynamic>{
          'key': 'genres',
          'type': 'multiselect',
          'title': 'Genres',
          'options': <dynamic>[
            <String, dynamic>{'value': 'action', 'label': 'Action'},
            <String, dynamic>{'value': 'drama', 'label': 'Drama'},
          ],
        },
        <String, dynamic>{
          'key': 'token',
          'type': 'text',
          'title': 'Token',
        },
        <String, dynamic>{
          'key': 'pageSize',
          'type': 'number',
          'title': 'Page size',
          'default': 20,
        },
      ],
      'requestPolicy': <String, dynamic>{
        'mirrors': <String>['https://one.example.com', 'https://two.example.com/'],
      },
    });

ConfigInfo _paginatedConfig() => ConfigInfo.fromJson(<String, dynamic>{
      'name': 'Paged Source',
      'uid': _uid,
      'logoUrl': '',
      'type': 0,
      'nsfw': false,
      'language': 'en',
      'version': 1,
      'filters': <dynamic>[],
      'searchAvailable': true,
      'pagination': <String, dynamic>{
        'pageSizes': <int>[20, 50, 100],
        'defaultPageSize': 20,
      },
    });

Future<void> _pumpHost(
  WidgetTester tester,
  ExtensionPreferencesStore store,
  void Function(bool changed) onClosed, {
  ConfigInfo? config,
}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                onClosed(await showExtensionSettingsSheet(
                  context,
                  config: config ?? _config(),
                  store: store,
                ));
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  late ExtensionPreferencesStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    store = ExtensionPreferencesStore();
  });

  testWidgets('renders a control for every preference type and the mirror',
      (WidgetTester tester) async {
    await _pumpHost(tester, store, (bool changed) {});

    expect(find.text('Extension settings'), findsOneWidget);
    expect(find.text('Sheet Source'), findsOneWidget);
    expect(find.text('Mirror'), findsOneWidget);
    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('one.example.com'), findsOneWidget);
    expect(find.text('two.example.com'), findsOneWidget);
    expect(find.text('Show adult titles'), findsOneWidget);
    expect(find.text('Includes 18+ results'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, '20'), findsOneWidget);
    expect(find.text('Reset to defaults'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    expect(find.textContaining('per page'), findsNothing);
  });

  testWidgets('declared pagination adds a page size row with the default',
      (WidgetTester tester) async {
    await _pumpHost(tester, store, (bool changed) {},
        config: _paginatedConfig());

    expect(find.text('Page size'), findsOneWidget);
    expect(find.text('20 per page (default)'), findsOneWidget);
    expect(find.text('50 per page'), findsOneWidget);
    expect(find.text('100 per page'), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('20 per page (default)'),
          matching: find.byType(Row),
        ),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Reset to default'), findsNothing);
  });

  testWidgets('choosing a page size stores it and the default clears it',
      (WidgetTester tester) async {
    bool? closedWithChanges;
    await _pumpHost(tester, store, (bool changed) {
      closedWithChanges = changed;
    }, config: _paginatedConfig());

    await tester.tap(find.text('50 per page'));
    await tester.pumpAndSettle();

    expect(await store.read(_uid, ExtensionPreference.pageSizeKey), 50);
    expect(find.byTooltip('Reset to default'), findsOneWidget);

    await tester.tap(find.text('20 per page (default)'));
    await tester.pumpAndSettle();

    expect(await store.readAll(_uid), isEmpty);
    expect(find.byTooltip('Reset to default'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(closedWithChanges, isTrue);
  });

  testWidgets('a stored page size can be reset to the default',
      (WidgetTester tester) async {
    await store.write(_uid, ExtensionPreference.pageSizeKey, 100);
    await _pumpHost(tester, store, (bool changed) {},
        config: _paginatedConfig());

    await tester.tap(find.byTooltip('Reset to default'));
    await tester.pumpAndSettle();

    expect(await store.read(_uid, ExtensionPreference.pageSizeKey), isNull);
  });

  testWidgets('edits are stored per type and reported as changes',
      (WidgetTester tester) async {
    bool? closedWithChanges;
    await _pumpHost(tester, store, (bool changed) {
      closedWithChanges = changed;
    });

    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Japanese'));
    await tester.tap(find.text('Drama'));
    await tester.tap(find.text('two.example.com'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Token'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, '20'), '35');
    await tester.pumpAndSettle();

    expect(await store.readAll(_uid), <String, Object>{
      'adult': true,
      'lang': 'ja',
      'genres': <String>['drama'],
      ExtensionPreference.mirrorKey: 'https://two.example.com/',
      'token': 'abc',
      'pageSize': 35,
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(closedWithChanges, isTrue);
  });

  testWidgets('invalid numbers show an error and are not stored',
      (WidgetTester tester) async {
    await _pumpHost(tester, store, (bool changed) {});

    await tester.enterText(find.widgetWithText(TextFormField, '20'), '1x');
    await tester.pumpAndSettle();

    expect(find.text('Enter a number'), findsOneWidget);
    expect(await store.read(_uid, 'pageSize'), isNull);
  });

  testWidgets('clearing a number field falls back to the default',
      (WidgetTester tester) async {
    await _pumpHost(tester, store, (bool changed) {});

    final Finder pageSize = find.widgetWithText(TextFormField, 'Page size');
    await tester.enterText(pageSize, '1');
    await tester.enterText(pageSize, '12');
    await tester.pumpAndSettle();
    expect(await store.read(_uid, 'pageSize'), 12);

    await tester.enterText(pageSize, '1');
    await tester.enterText(pageSize, '');
    await tester.pumpAndSettle();

    expect(await store.read(_uid, 'pageSize'), isNull);
    expect(find.text('Enter a number'), findsNothing);
  });

  testWidgets('clearing a text field removes the stored value',
      (WidgetTester tester) async {
    await store.write(_uid, 'token', 'abc');
    await _pumpHost(tester, store, (bool changed) {});

    await tester.enterText(find.widgetWithText(TextFormField, 'abc'), '');
    await tester.pumpAndSettle();

    expect(await store.readAll(_uid), isNot(contains('token')));
  });

  testWidgets('a single preference can be reset to its default',
      (WidgetTester tester) async {
    await store.write(_uid, 'lang', 'ja');
    await store.write(_uid, 'adult', true);
    await _pumpHost(tester, store, (bool changed) {});

    await tester.tap(find.byTooltip('Reset to default'));
    await tester.pumpAndSettle();

    expect(await store.readAll(_uid), <String, Object>{'adult': true});
    expect(find.byTooltip('Reset to default'), findsNothing);
  });

  testWidgets('reset to defaults clears stored values',
      (WidgetTester tester) async {
    await store.write(_uid, 'lang', 'ja');
    await store.write(_uid, 'pageSize', 50);
    await _pumpHost(tester, store, (bool changed) {});

    expect(find.widgetWithText(TextFormField, '50'), findsOneWidget);

    await tester.tap(find.text('Reset to defaults'));
    await tester.pumpAndSettle();

    expect(await store.readAll(_uid), isEmpty);
    expect(find.widgetWithText(TextFormField, '20'), findsOneWidget);
  });

  testWidgets('closing without edits reports no change',
      (WidgetTester tester) async {
    bool? closedWithChanges;
    await _pumpHost(tester, store, (bool changed) {
      closedWithChanges = changed;
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(closedWithChanges, isFalse);
  });
}
