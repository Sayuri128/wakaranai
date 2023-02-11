import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/splashscreen/splashscreen_view.dart';
import 'package:wakaranai/utils/text_styles.dart';

import '../main.dart';
import '../utils/app_colors.dart';
import 'home/home_view.dart';

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final HeroController _heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                  medium(size: 16, color: AppColors.mainWhite)),
              indicatorColor: AppColors.primary.withOpacity(0.9),
              iconTheme: MaterialStateProperty.all(
                  IconThemeData(color: AppColors.mainWhite))),
          dialogTheme:
              const DialogTheme(surfaceTintColor: AppColors.backgroundColor),
          cardTheme:
              const CardTheme(surfaceTintColor: AppColors.backgroundColor),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          })),
      debugShowCheckedModeBanner: false,
      navigatorKey: WakaranaiApp.navigatorKey,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      navigatorObservers: [_heroController],
      routes: {
        Routes.splashScreen: (context) => const SplashScreen(),
        Routes.home: (context) => const HomeView()
      },
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          Routes.mangaServiceViewer: (context) => MangaServiceView(
                data: settings.arguments as MangaServiceViewData,
              ),
          Routes.animeServiceViewer: (context) => AnimeServiceViewer(
              data: settings.arguments as AnimeServiceViewerData),
          Routes.mangaConcreteViewer: (context) => MangaConcreteViewer(
              data: settings.arguments as MangaConcreteViewerData),
          Routes.animeConcreteViewer: (context) => AnimeConcreteViewer(
              data: settings.arguments as AnimeConcreteViewerData),
          Routes.chapterViewer: (context) =>
              ChapterViewer(data: settings.arguments as ChapterViewerData),
          Routes.webBrowser: (context) =>
              WebBrowserPage(data: settings.arguments as WebBrowserData),
          Routes.iframeAnimePlayer: (context) => AnimeIframePlayer(
              data: settings.arguments as AnimeIframePlayerData)
        };

        return CupertinoPageRoute(builder: routes[settings.name]!);
      },
      builder: (context, child) =>
          BlocListener<AuthenticationCubit, AuthenticationState>(
              listener: (context, state) {
                Future.delayed(const Duration(seconds: 0), () {
                  if (state is AuthenticationAuthenticated) {
                    WakaranaiApp.navigator?.pushNamedAndRemoveUntil(
                        Routes.home, (route) => false);
                  }
                });
              },
              child: child!),
    );
  }
}
