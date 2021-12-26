import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/ui/app_view.dart';

import 'blocs/nhentai/cache/image/image_cache_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
          lazy: false,
          create: (context) => AuthenticationCubit()..authorize('armatura@gmail.com', '1234')),
      BlocProvider(lazy: false, create: (context) => ImageCacheCubit(isPrimary: true)..getAll())
    ], child: const AppView());
  }
}
