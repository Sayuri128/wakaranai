import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/home/activity_history_page/acitvity_history_page.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/library_page/library_home_page.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';

class _SilentNotifications extends DownloadNotificationService {
  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> showComplete(int count) async {}

  @override
  Future<void> cancelProgress() async {}
}

Widget _app(WakaranaiDatabase database, Widget Function() page,
    List<BlocProvider<dynamic>> Function(BuildContext context) blocs) {
  return MaterialApp(
    home: _repositories(
      database,
      child: Builder(
        builder: (BuildContext context) => MultiBlocProvider(
          providers: blocs(context),
          child: page(),
        ),
      ),
    ),
  );
}

Widget _repositories(WakaranaiDatabase database, {required Widget child}) {
  return MultiRepositoryProvider(
    providers: <RepositoryProvider<dynamic>>[
      RepositoryProvider<ExtensionRepository>(
          create: (_) => ExtensionRepository(database: database)),
      RepositoryProvider<ExtensionSourceRepository>(
          create: (_) => ExtensionSourceRepository(database: database)),
      RepositoryProvider<ConcreteDataRepository>(
          create: (_) => ConcreteDataRepository(database: database)),
      RepositoryProvider<ChapterActivityRepository>(
          create: (_) => ChapterActivityRepository(database: database)),
      RepositoryProvider<AnimeEpisodeActivityRepository>(
          create: (_) => AnimeEpisodeActivityRepository(database: database)),
      RepositoryProvider<DownloadRepository>(
          create: (_) => DownloadRepository(database: database)),
    ],
    child: child,
  );
}

Rect _indicatorRect(WidgetTester tester) {
  return tester.getRect(find.descendant(
    of: find.byType(SegmentedTabs),
    matching: find.byWidgetPredicate((Widget widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).borderRadius ==
            BorderRadius.circular(10)),
  ));
}

Future<void> _settle(WidgetTester tester) async {
  for (int frame = 0; frame < 20; frame++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late WakaranaiDatabase database;

  setUpAll(() async {
    await S.load(const Locale('en'));
    await initializeDateFormatting('en');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = WakaranaiDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('history renders its two tabs and switches pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(
      database,
      () => const ActivityHistoryPage(),
      (BuildContext context) => <BlocProvider<dynamic>>[
        BlocProvider<MangaActivityHistoryCubit>(
          create: (_) => MangaActivityHistoryCubit(
            extensionRepository: context.read<ExtensionRepository>(),
            concreteDataRepository: context.read<ConcreteDataRepository>(),
            chapterActivityRepository:
                context.read<ChapterActivityRepository>(),
          )..init(),
        ),
        BlocProvider<AnimeActivityHistoryCubit>(
          create: (_) => AnimeActivityHistoryCubit(
            extensionRepository: context.read<ExtensionRepository>(),
            concreteDataRepository: context.read<ConcreteDataRepository>(),
            animeEpisodeActivityRepository:
                context.read<AnimeEpisodeActivityRepository>(),
          )..init(),
        ),
      ],
    ));
    await _settle(tester);

    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('Anime'), findsOneWidget);
    expect(find.textContaining('Start reading manga'), findsOneWidget);
    final double mangaLeft = _indicatorRect(tester).left;

    await tester.tap(find.text('Anime'));
    await _settle(tester);

    expect(find.textContaining('Start watching anime'), findsOneWidget);
    expect(_indicatorRect(tester).left, greaterThan(mangaLeft));
  });

  testWidgets('library renders its two tabs and switches pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(
      database,
      () => const LibraryHomePage(),
      (BuildContext context) => <BlocProvider<dynamic>>[
        BlocProvider<LibraryCubit>(
          create: (_) => LibraryCubit(
            libraryEntryRepository: LibraryEntryRepository(database: database),
            categoryRepository: CategoryRepository(database: database),
            libraryUpdateRepository:
                LibraryUpdateRepository(database: database),
            extensionResolver: ExtensionResolver(
              extensionRepository: ExtensionRepository(database: database),
              extensionSourceRepository:
                  ExtensionSourceRepository(database: database),
            ),
          ),
        ),
        BlocProvider<LibraryUpdatesCubit>(
          create: (_) => LibraryUpdatesCubit(
            libraryEntryRepository: LibraryEntryRepository(database: database),
            libraryUpdateRepository:
                LibraryUpdateRepository(database: database),
            concreteDataRepository: ConcreteDataRepository(database: database),
            extensionRepository: ExtensionRepository(database: database),
          ),
        ),
        BlocProvider<LibraryLayoutCubit>(create: (_) => LibraryLayoutCubit()),
        BlocProvider<DownloadManagerCubit>(
          create: (_) => DownloadManagerCubit(
            downloadRepository: DownloadRepository(database: database),
            notificationService: _SilentNotifications(),
          ),
        ),
        BlocProvider<ChapterTranslationCubit>(
          create: (_) => ChapterTranslationCubit(
            backendFactory: (_) => throw UnimplementedError(),
            ensureReady: (_) async => false,
          ),
        ),
      ],
    ));
    await _settle(tester);

    expect(find.text('Titles'), findsOneWidget);
    expect(find.text('Downloads'), findsWidgets);
    final double titlesLeft = _indicatorRect(tester).left;

    await tester.tap(find
        .descendant(
          of: find.byType(SegmentedTabs),
          matching: find.text('Downloads'),
        )
        .first);
    await _settle(tester);

    expect(_indicatorRect(tester).left, greaterThan(titlesLeft));
    final PageView pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 1);
  });
}
