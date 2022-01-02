import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/concrete_viewer.dart';
import 'package:wakaranai/ui/service_viewer/service_viewer.dart';
import 'package:wakaranai/ui/splashscreen/splashscreen_view.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/chapter/chapter.dart';

import '../main.dart';
import 'home/home_view.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      navigatorKey: MyApp.navigatorKey,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      routes: {
        Routes.splashScreen: (context) => const SplashScreen(),
        Routes.home: (context) => const HomeView()
      },
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          Routes.serviceViewer: (context) => ServiceView(
                apiClient: settings.arguments as ApiClient,
              ),
          Routes.concreteViewer: (context) =>
              ConcreteViewer(data: settings.arguments as ConcreteViewerData),
          Routes.chapterViewer: (context) => ChapterViewer(chapter: settings.arguments as Chapter)
        };

        return MaterialPageRoute(builder: routes[settings.name]!);
      },
      builder: (context, child) => BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            Future.delayed(const Duration(seconds: 0), () {
              if (state is AuthenticationAuthenticated) {
                MyApp.navigator?.pushNamedAndRemoveUntil(Routes.home, (route) => false);
              }
            });
          },
          child: child!),
    );
  }
}
