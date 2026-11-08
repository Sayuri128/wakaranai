import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auto_backup/auto_backup_cubit.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/blocs/app_language/app_language_cubit.dart';
import 'package:wakaranai/services/app_language/app_language.dart';
import 'package:wakaranai/ui/widgets/locale_rebuild_scope.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/my_extension_sources_page.dart';
import 'package:wakaranai/ui/home/downloads_page/download_reader_launcher.dart';
import 'package:wakaranai/ui/home/updates_page/updates_page.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/home/stats_page/cubit/stats_cubit.dart';
import 'package:wakaranai/ui/home/stats_page/stats_page.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/novel_concrete_viewer.dart';
import 'package:wakaranai/ui/discover/discover_screen.dart';
import 'package:wakaranai/ui/global_search/global_search_arguments.dart';
import 'package:wakaranai/ui/global_search/global_search_page.dart';
import 'package:wakaranai/ui/migration/migration_arguments.dart';
import 'package:wakaranai/ui/migration/migration_preview_page.dart';
import 'package:wakaranai/ui/migration/migration_search_page.dart';
import 'package:wakaranai/ui/services/novel/novel_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader.dart';
import 'package:wakaranai/ui/splashscreen/splashscreen_view.dart';
import 'package:wakaranai/utils/app_colors.dart';

import '../main.dart';
import 'home/settings_page/language_packs_page.dart';
import 'home/settings_page/translation_models_page.dart';
import 'home/settings_page/page_translation_settings_page.dart';
import 'home/home_view.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  final HeroController _heroController = HeroController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (Duration _) => context.read<AutoBackupCubit>().backUpIfDue(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    _resyncBackgroundWrites();
  }

  void _resyncBackgroundWrites() {
    context.read<LibraryCubit>().init();
    context.read<LibraryUpdatesCubit>().init();
    context.read<DownloadManagerCubit>().init();
    unawaited(context.read<AutoDownloadSettingsCubit>().load());
    context.read<MangaActivityHistoryCubit>().init(silent: true);
    context.read<AnimeActivityHistoryCubit>().init(silent: true);
    context.read<AutoBackupCubit>().backUpIfDue();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (BuildContext context, ThemeState themeState) {
        AppColors.apply(themeState.palette);

        final Brightness brightness = themeState.palette.brightness;
        final Brightness iconBrightness = brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          statusBarBrightness: brightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: iconBrightness,
          systemNavigationBarContrastEnforced: false,
        ));

        return BlocBuilder<AppLanguageCubit, AppLanguage>(
          builder: (BuildContext context, AppLanguage language) {
            return _buildApp(themeState, language);
          },
        );
      },
    );
  }

  Widget _buildApp(ThemeState themeState, AppLanguage language) {
    return MaterialApp(
      theme: themeState.palette.toThemeData(),
      locale: language.locale,
      debugShowCheckedModeBanner: false,
      navigatorKey: WakaranaiApp.navigatorKey,
      localizationsDelegates: const <LocalizationsDelegate>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      navigatorObservers: <NavigatorObserver>[_heroController],
      routes: <String, WidgetBuilder>{
        Routes.splashScreen: (BuildContext context) => const SplashScreen(),
        Routes.home: (BuildContext context) => HomeView(),
      },
      onGenerateRoute: (RouteSettings settings) {
        final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
          Routes.mangaServiceViewer: (BuildContext context) => MangaServiceView(
                data: settings.arguments as MangaServiceViewData,
              ),
          Routes.animeServiceViewer: (BuildContext context) =>
              AnimeServiceViewer(
                  data: settings.arguments as AnimeServiceViewerData),
          Routes.mangaConcreteViewer: (BuildContext context) =>
              MangaConcreteViewer(
                  data: settings.arguments as MangaConcreteViewerData),
          Routes.animeConcreteViewer: (BuildContext context) =>
              AnimeConcreteViewer(
                  data: settings.arguments as AnimeConcreteViewerData),
          Routes.chapterViewer: (BuildContext context) =>
              ChapterViewer(data: settings.arguments as ChapterViewerData),
          Routes.novelServiceViewer: (BuildContext context) =>
              NovelServiceView(
                  data: settings.arguments as NovelServiceViewData),
          Routes.novelConcreteViewer: (BuildContext context) =>
              NovelConcreteViewer(
                  data: settings.arguments as NovelConcreteViewerData),
          Routes.novelReader: (BuildContext context) =>
              NovelReader(data: settings.arguments as NovelReaderData),
          Routes.webBrowser: (BuildContext context) =>
              WebBrowserPage(data: settings.arguments as WebBrowserData),
          Routes.iframeAnimePlayer: (BuildContext context) => AnimeIframePlayer(
              data: settings.arguments as AnimeIframePlayerData),
          Routes.nativeAnimePlayer: (BuildContext context) => NativePlayer(
              data: settings.arguments as NativePlayerData),
          Routes.libraryConcreteViewer: (BuildContext context) =>
              LibraryConcreteViewer(
                  data: settings.arguments as LibraryConcreteViewerData),
          Routes.readingStatistics: (BuildContext context) =>
              BlocProvider<StatsCubit>(
                create: (BuildContext context) => StatsCubit(
                  chapterActivityRepository: RepositoryProvider.of(context),
                  animeEpisodeActivityRepository:
                      RepositoryProvider.of(context),
                  concreteDataRepository: RepositoryProvider.of(context),
                  extensionResolver: ExtensionResolver(
                    extensionRepository: context.read<ExtensionRepository>(),
                    extensionSourceRepository:
                        context.read<ExtensionSourceRepository>(),
                  ),
                )..init(),
                child: const StatsPage(),
              ),
          Routes.updates: (BuildContext context) => const UpdatesPage(),
          Routes.pageTranslationSettings: (BuildContext context) =>
              const PageTranslationSettingsPage(),
          Routes.languagePacks: (BuildContext context) =>
              const LanguagePacksPage(),
          Routes.translationModels: (BuildContext context) =>
              const TranslationModelsPage(),
          Routes.downloadReader: (BuildContext context) =>
              DownloadReaderLauncher(
                  data: settings.arguments as DownloadReaderData),
          Routes.myExtensionSources: (BuildContext context) =>
              const MyExtensionSourcesPage(),
          Routes.addExtensionSource: (BuildContext context) => AddExtensionPage(
              arguments: settings.arguments as AddExtensionPageArguments),
          Routes.globalSearch: (BuildContext context) => GlobalSearchPage(
              arguments: settings.arguments as GlobalSearchArguments),
          Routes.discover: (BuildContext context) => const DiscoverScreen(),
          Routes.migration: (BuildContext context) => MigrationSearchPage(
              arguments: settings.arguments as MigrationSearchArguments),
          Routes.migrationPreview: (BuildContext context) =>
              MigrationPreviewPage(
                  arguments: settings.arguments as MigrationPreviewArguments),
        };

        return CupertinoPageRoute(builder: routes[settings.name]!);
      },
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: LocaleRebuildScope(
          child: BlocListener<AuthenticationCubit, AuthenticationState>(
              listener: (BuildContext context, AuthenticationState state) {
                Future.delayed(const Duration(seconds: 0), () {
                  if (state is AuthenticationAuthenticated) {
                    WakaranaiApp.navigator?.pushNamedAndRemoveUntil(
                        Routes.home, (Route route) => false);
                  }
                });
              },
              child: child!),
        ),
      ),
    );
  }
}
