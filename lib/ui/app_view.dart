import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/main.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/ui/home/doujinshi_view/doujinshi_source_view.dart';
import 'package:h_reader/ui/home/doujinshi_view/doujinshi_view.dart';
import 'package:h_reader/ui/home/home_view.dart';
import 'package:h_reader/ui/routes.dart';
import 'package:h_reader/ui/splashscreen/splashscreen_view.dart';

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
          Routes.doujinshiView: (BuildContext context) =>
              DoujinshiView(doujinshi: settings.arguments as Doujinshi),
          Routes.doujinshiSourceView: (BuildContext context) => DoujinshiSourceView(
                data: settings.arguments as DoujinshiSourceViewData,
              ),
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
