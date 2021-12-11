import 'package:flutter/material.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:provider/src/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthenticationCubit>().authorize('email', 'password');
    return Scaffold(
      body: Container(
        color: AppColors.accentGreen,
      ),
    );
  }
}
