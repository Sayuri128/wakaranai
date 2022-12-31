import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakaranai/blocs/history/history_cubit.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/ui/app_view.dart';

import 'blocs/auth/authentication_cubit.dart';

final bool debug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await dotenv.load(fileName: '.env');

  runApp(const WakaranaiApp());
}

class WakaranaiApp extends StatefulWidget {
  const WakaranaiApp({Key? key}) : super(key: key);

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  @override
  State<WakaranaiApp> createState() => _WakaranaiAppState();
}

class _WakaranaiAppState extends State<WakaranaiApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(lazy: false, create: (context) => AuthenticationCubit()),
      BlocProvider<RemoteConfigsCubit>(
        create: (context) => RemoteConfigsCubit()..getConfigs(),
      ),
      BlocProvider(create: (context) => LocalConfigsCubit()..init()),
      BlocProvider(create: (context) => SettingsCubit()..init()),
      BlocProvider(create: (context) => HistoryCubit()..init())
    ], child: const AppView());
  }
}
