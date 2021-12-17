import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/auth/authentication_cubit.dart';
import 'package:h_reader/blocs/image_cache/image_cache_cubit.dart';
import 'package:h_reader/ui/app_view.dart';

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
      BlocProvider(create: (context) => ImageCacheCubit())
    ], child: const AppView());
  }
}
