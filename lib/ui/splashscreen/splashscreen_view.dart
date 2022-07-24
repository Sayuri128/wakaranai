import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wakaranai/blocs/auth/authentication_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthenticationCubit>().authorize('email', 'password');
    return Scaffold(
      body: Container(
        color: AppColors.primary,
      ),
    );
  }
}
