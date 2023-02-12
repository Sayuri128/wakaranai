import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/services/library_service/library_service.dart';
import 'package:wakaranai/services/local_anime_gallery_view_service/local_anime_gallery_view_service.dart';
import 'package:wakaranai/services/local_manga_gallery_view_service/local_manga_gallery_view_service.dart';
import 'package:wakaranai/ui/app_view.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';
import 'package:wakaranai/ui/home/library/cubit/library_page_cubit.dart';

import 'blocs/auth/authentication_cubit.dart';
import 'services/local_api_clients_service/local_api_clients_service.dart';
import 'services/local_config_info_service/local_config_info_service.dart';
import 'services/local_protector_config_service/local_protector_config_service.dart';

const bool debug = true;

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
      RepositoryProvider<LocalMangaGalleryViewService>(
        create: (context) => LocalMangaGalleryViewService(),
      ),
      RepositoryProvider<LocalAnimeGalleryViewService>(
        create: (context) => LocalAnimeGalleryViewService(),
      ),
      RepositoryProvider<LocalProtectorConfigService>(
          create: (context) => LocalProtectorConfigService()),
      RepositoryProvider<LocalConfigInfoService>(
          create: (context) => LocalConfigInfoService(
              localProtectorConfigService:
                  context.read<LocalProtectorConfigService>())),
      RepositoryProvider<LocalApiClientsService>(
          create: (context) => LocalApiClientsService(
              localConfigInfoService: context.read<LocalConfigInfoService>())),
      RepositoryProvider(
          create: (context) => LibraryService(
              localApiClientsService: context.read<LocalApiClientsService>(),
              localAnimeGalleryViewService:
                  context.read<LocalAnimeGalleryViewService>(),
              localMangaGalleryViewService: LocalMangaGalleryViewService())),
      BlocProvider<HomePageCubit>(create: (context) => HomePageCubit()),
      BlocProvider<LibraryPageCubit>(
        create: (context) =>
            LibraryPageCubit(libraryService: context.read<LibraryService>())
              ..init(),
      ),
      BlocProvider<AuthenticationCubit>(
          lazy: false, create: (context) => AuthenticationCubit()),
      BlocProvider<RemoteConfigsCubit>(
        lazy: false,
        create: (context) => RemoteConfigsCubit()..init(),
      ),
      BlocProvider<LocalConfigsCubit>(
          create: (context) => LocalConfigsCubit(
              localApiClientsService: context.read<LocalApiClientsService>(),
              remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
              libraryPageCubit: context.read<LibraryPageCubit>())
            ..init()),
      BlocProvider<ConfigsSourcesCubit>(
          create: (context) => ConfigsSourcesCubit()..getSources()),
      BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
              remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
              sourcesCubit: context.read<ConfigsSourcesCubit>())
            ..init()),
    ], child: const AppView());
  }
}
