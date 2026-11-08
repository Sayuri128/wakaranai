import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/library_entry_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/home/settings_page/auto_download_settings_tiles.dart';
import 'package:wakaranai/ui/services/widgets/concrete_auto_download_chip.dart';

class _TilesHost extends StatelessWidget {
  const _TilesHost();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoDownloadSettingsCubit, AutoDownloadSettings>(
      builder: (BuildContext context, AutoDownloadSettings settings) =>
          ListView(children: buildAutoDownloadSettingsTiles(context, settings)),
    );
  }
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  late WakaranaiDatabase database;
  late LibraryEntryRepository entries;
  late LibraryCubit library;
  late AutoDownloadSettingsCubit settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
    entries = LibraryEntryRepository(database: database);
    library = LibraryCubit(
      libraryEntryRepository: entries,
      categoryRepository: CategoryRepository(database: database),
      libraryUpdateRepository: LibraryUpdateRepository(database: database),
      extensionResolver: ExtensionResolver(
        extensionRepository: ExtensionRepository(database: database),
        extensionSourceRepository:
            ExtensionSourceRepository(database: database),
      ),
    );
    settings = AutoDownloadSettingsCubit();
  });

  tearDown(() async {
    await library.close();
    await settings.close();
    await database.close();
  });

  Widget host(Widget child) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LibraryCubit>.value(value: library),
        BlocProvider<AutoDownloadSettingsCubit>.value(value: settings),
      ],
      child: MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('the scope and limit rows appear once auto-download is on',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const _TilesHost()));
    await tester.pumpAndSettle();

    expect(find.text('Auto-download for'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(settings.state.enabled, isTrue);
    expect(find.text('Auto-download for'), findsOneWidget);
    expect(find.text('All library titles'), findsOneWidget);
    expect(find.text('Up to 5'), findsOneWidget);
    expect(
      (await AutoDownloadPreferences().read(reload: true)).enabled,
      isTrue,
    );
  });

  testWidgets('the title chip shows the effective state and its override',
      (WidgetTester tester) async {
    settings.setEnabled(true);
    await tester.runAsync(() async {
      await entries.create(LibraryEntryDomain(
        id: 0,
        uid: 'title',
        extensionUid: 'ext',
        title: 'Title',
        autoDownload: AutoDownloadOverride.never,
        createdAt: DateTime.now(),
      ));
      library.init();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    await tester.pumpWidget(
      host(ConcreteAutoDownloadChip(concreteUid: 'title')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auto-download off'), findsOneWidget);

    await tester.tap(find.text('Auto-download off'));
    await tester.pumpAndSettle();
    expect(find.text('Never'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Always'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('Auto-download on'), findsOneWidget);
  });
}
