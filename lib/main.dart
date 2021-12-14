import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/ui/app_view.dart';

import 'blocs/nhentai/caching_image/caching_image_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
          lazy: false,
          create: (context) => AuthenticationCubit()..authorize('armatura@gmail.com', '1234')),
      BlocProvider<CachingImageCubit>(create: (context) => CachingImageCubit()),
    ], child: const AppView());
  }
}
