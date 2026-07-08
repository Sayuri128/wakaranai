import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_sheet.dart';

Future<Set<ExportSection>?> _open(
  WidgetTester tester, {
  required Set<ExportSection> available,
}) async {
  Set<ExportSection>? result;

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
                result = await showImportExportSheet(
                  context,
                  available: available,
                  title: 'Export data',
                  confirmLabel: 'Export',
                );
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

  return result;
}

int _checkedCount(WidgetTester tester) =>
    tester.widgetList(find.byIcon(Icons.check_circle_rounded)).length;

void main() {
  testWidgets('every section is selected by default', (WidgetTester tester) async {
    await _open(tester, available: ExportSection.values.toSet());

    expect(_checkedCount(tester), ExportSection.values.length);
    expect(find.byIcon(Icons.circle_outlined), findsNothing);
  });

  testWidgets('only available sections are offered', (WidgetTester tester) async {
    await _open(tester, available: <ExportSection>{
      ExportSection.history,
      ExportSection.settings,
    });

    expect(_checkedCount(tester), 2);
    expect(find.text(S.current.export_section_history), findsOneWidget);
    expect(find.text(S.current.export_section_settings), findsOneWidget);
    expect(find.text(S.current.export_section_library), findsNothing);
  });

  testWidgets('select all clears then re-selects everything',
      (WidgetTester tester) async {
    await _open(tester, available: ExportSection.values.toSet());

    await tester.tap(find.text(S.current.settings_export_select_all));
    await tester.pumpAndSettle();
    expect(_checkedCount(tester), 0);

    await tester.tap(find.text(S.current.settings_export_select_all));
    await tester.pumpAndSettle();
    expect(_checkedCount(tester), ExportSection.values.length);
  });

  testWidgets('confirm is disabled when nothing is selected',
      (WidgetTester tester) async {
    await _open(tester, available: ExportSection.values.toSet());

    await tester.tap(find.text(S.current.settings_export_select_all));
    await tester.pumpAndSettle();

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Export'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('tapping a row deselects it and confirm returns the rest',
      (WidgetTester tester) async {
    Set<ExportSection>? result;

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
                  result = await showImportExportSheet(
                    context,
                    available: ExportSection.values.toSet(),
                    title: 'Export data',
                    confirmLabel: 'Export',
                  );
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

    await tester.tap(find.text(S.current.export_section_settings));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Export'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.contains(ExportSection.settings), isFalse);
    expect(result!.length, ExportSection.values.length - 1);
  });
}
