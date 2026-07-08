import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/repository_providers.dart';
import 'package:wakaranai/services/background/background_tasks.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/ui/app_view.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';

import 'blocs/auth/authentication_cubit.dart';
import 'repositories/database/anime_episode_activity_repository.dart';
import 'repositories/database/chapter_activity_repository.dart';
import 'ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'ui/home/settings_page/cubit/settings/settings_cubit.dart';

const bool debug = true;

final Logger logger = Logger(
  filter: ProductionFilter(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await dotenv.load(fileName: '.env');

  if (!kIsWeb && Platform.isAndroid) {
    try {
      await Workmanager().initialize(backgroundCallbackDispatcher);
    } catch (e) {
      logger.w('Failed to initialize Workmanager: $e');
    }
  }

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
    return repositoryProviders(
      context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            lazy: false,
            create: (BuildContext context) => ThemeCubit()..init(),
          ),
          BlocProvider<LibraryCubit>(
            lazy: false,
            create: (BuildContext context) => LibraryCubit(
              libraryEntryRepository: RepositoryProvider.of(context),
              categoryRepository: RepositoryProvider.of(context),
              libraryUpdateRepository: RepositoryProvider.of(context),
            )..init(),
          ),
          BlocProvider<LibraryUpdatesCubit>(
            lazy: false,
            create: (BuildContext context) => LibraryUpdatesCubit(
              libraryEntryRepository: RepositoryProvider.of(context),
              libraryUpdateRepository: RepositoryProvider.of(context),
              concreteDataRepository: RepositoryProvider.of(context),
              extensionRepository: RepositoryProvider.of(context),
            )..init(),
          ),
          BlocProvider<DownloadManagerCubit>(
            lazy: false,
            create: (BuildContext context) => DownloadManagerCubit(
              downloadRepository: RepositoryProvider.of(context),
            )..init(),
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
            create: (BuildContext context) => RemoteConfigsCubit(
              extensionSourceRepository:
                  context.read<ExtensionSourceRepository>(),
            )..init(),
          ),
          BlocProvider(
            create: (BuildContext context) => MangaActivityHistoryCubit(
              chapterActivityRepository: RepositoryProvider.of(context),
              concreteDataRepository: RepositoryProvider.of(context),
              extensionRepository: RepositoryProvider.of(context),
            )..init(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => AnimeActivityHistoryCubit(
                extensionRepository: RepositoryProvider.of(context),
                concreteDataRepository: RepositoryProvider.of(context),
                animeEpisodeActivityRepository: RepositoryProvider.of(context))
              ..init(),
            lazy: false,
          ),
          BlocProvider<LatestReleaseCubit>(
            create: (BuildContext context) => LatestReleaseCubit()..init(),
            lazy: true,
          ),
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) => SettingsCubit(
                remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
                animeActivityHistoryCubit:
                    context.read<AnimeActivityHistoryCubit>(),
                mangaActivityHistoryCubit:
                    context.read<MangaActivityHistoryCubit>(),
                themeCubit: context.read<ThemeCubit>(),
                importExportService: ImportExportService(
                  concreteDataRepository: RepositoryProvider.of(context),
                  chapterActivityRepository: RepositoryProvider.of(context),
                  animeEpisodeActivityRepository:
                      RepositoryProvider.of(context),
                  categoryRepository: RepositoryProvider.of(context),
                  libraryEntryRepository: RepositoryProvider.of(context),
                  extensionSourceRepository: RepositoryProvider.of(context),
                ),
                database: context.read<WakaranaiDatabase>())
              ..init(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
