import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/my_extension_sources_page.dart';
import 'package:wakaranai/ui/home/downloads_page/download_reader_launcher.dart';
import 'package:wakaranai/ui/home/downloads_page/downloads_page.dart';
import 'package:wakaranai/ui/home/updates_page/updates_page.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/home/stats_page/cubit/stats_cubit.dart';
import 'package:wakaranai/ui/home/stats_page/stats_page.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/splashscreen/splashscreen_view.dart';
import 'package:wakaranai/utils/app_colors.dart';

import '../main.dart';
import 'home/home_view.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final HeroController _heroController = HeroController();

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

        return _buildApp(themeState);
      },
    );
  }

  Widget _buildApp(ThemeState themeState) {
    return MaterialApp(
      theme: themeState.palette.toThemeData(),
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
          Routes.webBrowser: (BuildContext context) =>
              WebBrowserPage(data: settings.arguments as WebBrowserData),
          Routes.iframeAnimePlayer: (BuildContext context) => AnimeIframePlayer(
              data: settings.arguments as AnimeIframePlayerData),
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
          Routes.downloads: (BuildContext context) => const DownloadsPage(),
          Routes.updates: (BuildContext context) => const UpdatesPage(),
          Routes.downloadReader: (BuildContext context) =>
              DownloadReaderLauncher(
                  data: settings.arguments as DownloadReaderData),
          Routes.myExtensionSources: (BuildContext context) =>
              const MyExtensionSourcesPage(),
          Routes.addExtensionSource: (BuildContext context) => AddExtensionPage(
              arguments: settings.arguments as AddExtensionPageArguments)
        };

        return CupertinoPageRoute(builder: routes[settings.name]!);
      },
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
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
    );
  }
}
