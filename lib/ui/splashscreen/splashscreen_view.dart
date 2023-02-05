import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    context.read<AuthenticationCubit>().authorize('armatura@gmail.com', '1234');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, state) {
        Future.delayed(const Duration(seconds: 0), () {
          if (state is AuthenticationAuthenticated) {
            WakaranaiApp.navigator
                ?.pushNamedAndRemoveUntil(Routes.home, (route) => false);
          }
        });

        return Container(
          color: AppColors.primary,
        );
      }),
    );
  }
}
