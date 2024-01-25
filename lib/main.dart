import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/ui/app_view.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';

import 'blocs/auth/authentication_cubit.dart';
import 'ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'ui/home/settings/cubit/settings/settings_cubit.dart';

const bool debug = true;

final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await dotenv.load(fileName: '.env');

  runApp(const WakaranaiApp());
}

class WakaranaiApp extends StatefulWidget {
  const WakaranaiApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  @override
  State<WakaranaiApp> createState() => _WakaranaiAppState();
}

class _WakaranaiAppState extends State<WakaranaiApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<WakaranaiDatabase>(
          create: (context) => WakaranaiDatabase(),
          lazy: false,
        ),
        BlocProvider<HomePageCubit>(
          create: (BuildContext context) => HomePageCubit(),
        ),
        BlocProvider<AuthenticationCubit>(
          lazy: false,
          create: (BuildContext context) => AuthenticationCubit(),
        ),
        BlocProvider<RemoteConfigsCubit>(
          lazy: false,
          create: (BuildContext context) => RemoteConfigsCubit()..init(),
        ),
        BlocProvider<SettingsCubit>(
          create: (BuildContext context) => SettingsCubit(
            remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
          )..init(),
        ),
        BlocProvider<LatestReleaseCubit>(
          create: (BuildContext context) => LatestReleaseCubit()..init(),
          lazy: true,
        ),
      ],
      child: const AppView(),
    );
  }
}
