import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/app_language/app_language_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/app_language_preferences.dart';
import 'package:wakaranai/services/app_language/app_language.dart';
import 'package:wakaranai/services/app_language/background_strings.dart';
import 'package:wakaranai/services/import_export/exported_preferences.dart';
import 'package:wakaranai/ui/widgets/locale_rebuild_scope.dart';

class _CurrentStringsLabel extends StatelessWidget {
  const _CurrentStringsLabel();

  @override
  Widget build(BuildContext context) {
    return Text(S.current.home_navigation_bar_library_title);
  }
}

Widget _app(AppLanguageCubit cubit) {
  return BlocProvider<AppLanguageCubit>.value(
    value: cubit,
    child: BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (BuildContext context, AppLanguage language) {
        return MaterialApp(
          locale: language.locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: (BuildContext context, Widget? child) {
            return LocaleRebuildScope(child: child!);
          },
          home: const Scaffold(body: _CurrentStringsLabel()),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('stored values map back to languages, unknown values mean system', () {
    expect(AppLanguage.fromStorage('en'), AppLanguage.english);
    expect(AppLanguage.fromStorage('uk'), AppLanguage.ukrainian);
    expect(AppLanguage.fromStorage('system'), AppLanguage.system);
    expect(AppLanguage.fromStorage(null), AppLanguage.system);
    expect(AppLanguage.fromStorage('fr'), AppLanguage.system);
  });

  test('system language follows the first supported device locale', () {
    expect(
      resolveAppLocale(AppLanguage.system, const <Locale>[
        Locale('de', 'DE'),
        Locale('uk', 'UA'),
      ]),
      const Locale('uk'),
    );
    expect(
      resolveAppLocale(AppLanguage.system, const <Locale>[Locale('fr')]),
      const Locale('en'),
    );
    expect(
      resolveAppLocale(AppLanguage.english, const <Locale>[Locale('uk')]),
      const Locale('en'),
    );
  });

  test('the cubit persists the chosen language', () async {
    final AppLanguageCubit cubit = AppLanguageCubit();

    await cubit.changeLanguage(AppLanguage.ukrainian);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppLanguagePreferences.languageKey), 'uk');

    final AppLanguageCubit restored = AppLanguageCubit();
    await restored.init();
    expect(restored.state, AppLanguage.ukrainian);

    await cubit.close();
    await restored.close();
  });

  test('the app language is part of exported preferences', () {
    expect(
      ExportedPreferences.isExportable(AppLanguagePreferences.languageKey),
      isTrue,
    );
  });

  test('background strings use the saved language over the device one',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppLanguagePreferences.languageKey: 'uk',
    });

    final S strings = await loadBackgroundStrings(
      systemLocales: const <Locale>[Locale('en', 'US')],
    );

    expect(strings.home_navigation_bar_library_title, 'Бібліотека');
    await S.load(const Locale('en'));
  });

  test('background strings fall back to the device language', () async {
    final S strings = await loadBackgroundStrings(
      systemLocales: const <Locale>[Locale('uk', 'UA')],
      fallbackLocaleName: 'en',
    );

    expect(strings.home_navigation_bar_library_title, 'Бібліотека');
    await S.load(const Locale('en'));
  });

  testWidgets('switching the language rebuilds widgets reading S.current',
      (WidgetTester tester) async {
    final AppLanguageCubit cubit =
        AppLanguageCubit(initialLanguage: AppLanguage.english);
    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsOneWidget);

    await cubit.changeLanguage(AppLanguage.ukrainian);
    await tester.pumpAndSettle();
    expect(find.text('Бібліотека'), findsOneWidget);

    await cubit.changeLanguage(AppLanguage.english);
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsOneWidget);

    await cubit.close();
  });
}
