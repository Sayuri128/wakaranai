import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/ui/app_view.dart';

import 'blocs/auth/authentication_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await dotenv.load(fileName: '.env');

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
          create: (context) =>
              AuthenticationCubit()..authorize('armatura@gmail.com', '1234')),
      BlocProvider<RemoteConfigsCubit>(
        create: (context) => RemoteConfigsCubit()..getConfigs(),
      ),
      BlocProvider(create: (context) => LocalConfigsCubit()..init()),
      BlocProvider(create: (context) => SettingsCubit()..init())
    ], child: const AppView());
  }
}
