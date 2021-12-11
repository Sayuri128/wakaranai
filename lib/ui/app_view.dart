import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/main.dart';
import 'package:h_reader/ui/home/home_view.dart';
import 'package:h_reader/ui/routes.dart';
import 'package:h_reader/ui/splashscreen/splashscreen_view.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      routes: {
        Routes.splashScreen: (context) => const SplashScreen(),
        Routes.home: (context) => const HomeView()
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
