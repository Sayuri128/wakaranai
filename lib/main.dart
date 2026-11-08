import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show LicenseEntry, LicenseEntryWithLineBreaks, LicenseRegistry, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/auto_backup/auto_backup_cubit.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/services/import_export/backup_files.dart';
import 'package:wakaranai/blocs/chapter_translation/translation_notification_service.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/blocs/novel_reader_preferences/novel_reader_preferences_cubit.dart';
import 'package:wakaranai/blocs/reader_preferences/reader_preferences_cubit.dart';
import 'package:wakaranai/blocs/trackers/trackers_cubit.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_storage_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/repositories/database/repository_providers.dart';
import 'package:wakaranai/services/background/background_tasks.dart';
import 'package:wakaranai/services/extension_preferences/extension_host_services.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/ui/app_view.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/cubit/home_page_cubit.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/downloads/storage/download_quality_reader.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_llm_translator.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/page_translation_service.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';
import 'package:wakaranai/utils/webview_user_agent.dart';

import 'blocs/auth/authentication_cubit.dart';
import 'ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'ui/home/settings_page/cubit/settings/settings_cubit.dart';

Stream<LicenseEntry> _bundledFontLicenses() async* {
  final String pangolin = await rootBundle.loadString('fonts/Pangolin-OFL.txt');
  yield LicenseEntryWithLineBreaks(<String>['Pangolin font'], pangolin);
}

final Logger logger = Logger(
  filter: ProductionFilter(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<void> userAgentResolution = _resolveWebViewUserAgent();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await dotenv.load(fileName: '.env');
  Env.validate();

  LicenseRegistry.addLicense(_bundledFontLicenses);

  if (!kIsWeb && Platform.isAndroid) {
    try {
      await Workmanager().initialize(backgroundCallbackDispatcher);
    } catch (e) {
      logger.w('Failed to initialize Workmanager: $e');
    }
  }

  await userAgentResolution;

  final WakaranaiDatabase database = WakaranaiDatabase();
  configureExtensionHost(database);
  unawaited(_pruneExpiredExtensionStorage(database));

  runApp(WakaranaiApp(database: database));
}

Future<void> _pruneExpiredExtensionStorage(WakaranaiDatabase database) async {
  try {
    await ExtensionStorageRepository(database: database).pruneExpired();
  } catch (e) {
    logger.w('Failed to prune expired extension storage: $e');
  }
}

Future<void> _resolveWebViewUserAgent() async {
  if (kIsWeb || !Platform.isAndroid) {
    return;
  }
  try {
    await WebViewUserAgent.resolve();
  } catch (e) {
    logger.w('Failed to resolve the webview user agent: $e');
  }
}

class WakaranaiApp extends StatefulWidget {
  const WakaranaiApp({super.key, required this.database});

  final WakaranaiDatabase database;

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
      database: widget.database,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            lazy: false,
            create: (BuildContext context) => ThemeCubit()..init(),
          ),
          BlocProvider<GalleryLayoutCubit>(
            lazy: false,
            create: (BuildContext context) => GalleryLayoutCubit()..init(),
          ),
          BlocProvider<LibraryLayoutCubit>(
            lazy: false,
            create: (BuildContext context) => LibraryLayoutCubit()..init(),
          ),
          BlocProvider<LibraryCubit>(
            lazy: false,
            create: (BuildContext context) => LibraryCubit(
              libraryEntryRepository: RepositoryProvider.of(context),
              categoryRepository: RepositoryProvider.of(context),
              libraryUpdateRepository: RepositoryProvider.of(context),
              extensionResolver: ExtensionResolver(
                extensionRepository: context.read<ExtensionRepository>(),
                extensionSourceRepository:
                    context.read<ExtensionSourceRepository>(),
              ),
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
              extensionRepository: RepositoryProvider.of(context),
              readQualityPreference: defaultDownloadQualityPreferenceReader(),
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
              extensionRepository: context.read<ExtensionRepository>(),
            )..init(),
          ),
          BlocProvider<NsfwTitlesCubit>(
            lazy: false,
            create: (BuildContext context) => NsfwTitlesCubit(
              extensionRepository: context.read<ExtensionRepository>(),
              remoteConfigs: context.read<RemoteConfigsCubit>(),
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
          BlocProvider<TrackersCubit>(
            create: (BuildContext context) => TrackersCubit(
              sync: context.read<TrackerSyncService>(),
            )..init(),
            lazy: false,
          ),
          BlocProvider<ReaderPreferencesCubit>(
            create: (BuildContext context) => ReaderPreferencesCubit()..init(),
            lazy: false,
          ),
          BlocProvider<NovelReaderPreferencesCubit>(
            create: (BuildContext context) =>
                NovelReaderPreferencesCubit()..init(),
            lazy: false,
          ),
          BlocProvider<PageTranslationSettingsCubit>(
            create: (BuildContext context) =>
                PageTranslationSettingsCubit()..init(),
            lazy: false,
          ),
          BlocProvider<LanguagePacksCubit>(
            create: (BuildContext context) => LanguagePacksCubit(
              store: PageTranslationEngines.translatorById(null).models?.call(),
              wifiOnly: () =>
                  context.read<PageTranslationSettingsCubit>().state.wifiOnly,
            ),
          ),
          BlocProvider<OnDeviceModelCubit>(
            create: (BuildContext context) => OnDeviceModelCubit(
              store: OnDeviceModelFiles(),
              support: (OnDeviceModel variant) =>
                  DeviceCapabilities.onDeviceAi(minRamGb: variant.minRamGb),
            )
              ..init()
              ..followSelection(
                context
                    .read<PageTranslationSettingsCubit>()
                    .stream
                    .map(onDeviceModelOf),
                current: onDeviceModelOf(
                  context.read<PageTranslationSettingsCubit>().state,
                ),
              ),
            lazy: false,
          ),
          BlocProvider<AutoBackupCubit>(
            create: _createAutoBackup,
            lazy: false,
          ),
          BlocProvider<ChapterTranslationCubit>(
            create: _createTranslationQueue,
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
                libraryCubit: context.read<LibraryCubit>(),
                importExportService: ImportExportService(
                  concreteDataRepository: RepositoryProvider.of(context),
                  chapterActivityRepository: RepositoryProvider.of(context),
                  animeEpisodeActivityRepository:
                      RepositoryProvider.of(context),
                  categoryRepository: RepositoryProvider.of(context),
                  libraryEntryRepository: RepositoryProvider.of(context),
                  extensionSourceRepository: RepositoryProvider.of(context),
                  database: context.read<WakaranaiDatabase>(),
                ),
                database: context.read<WakaranaiDatabase>())
              ..init(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }

  AutoBackupCubit _createAutoBackup(BuildContext context) {
    final ImportExportService exporter = ImportExportService(
      concreteDataRepository: RepositoryProvider.of(context),
      chapterActivityRepository: RepositoryProvider.of(context),
      animeEpisodeActivityRepository: RepositoryProvider.of(context),
      categoryRepository: RepositoryProvider.of(context),
      libraryEntryRepository: RepositoryProvider.of(context),
      extensionSourceRepository: RepositoryProvider.of(context),
      database: context.read<WakaranaiDatabase>(),
    );
    return AutoBackupCubit(
      buildExport: (Set<ExportSection> sections) =>
          exporter.buildExport(sections),
      files: DownloadsBackupFiles(),
    )..init();
  }

  ChapterTranslationCubit _createTranslationQueue(BuildContext context) {
    late final ChapterTranslationCubit queue;
    final TranslationNotificationService notifications =
        TranslationNotificationService(
      onAction: (String action) {
        if (action == translationActionToggle) {
          queue.togglePause();
        } else if (action == translationActionCancel) {
          queue.cancelAll();
        }
      },
    );

    PageTranslationSettings currentSettings() {
      return effectiveTranslationSettings(
        context.read<PageTranslationSettingsCubit>().state,
        context.read<OnDeviceModelCubit>().state,
      );
    }

    queue = ChapterTranslationCubit(
      notifier: notifications,
      backendFactory: (TitleLanguages languages) => PageTranslationService(
        repository: context.read<PageTranslationRepository>(),
        settings: currentSettings(),
        languages: languages,
      ),
      ensureReady: (TitleLanguages languages) => ensureTranslationReady(
        settings: currentSettings(),
        packs: context.read<LanguagePacksCubit>(),
        gemma: context.read<OnDeviceModelCubit>(),
        languages: languages,
      ),
    );
    queue.watchDownloads(
      context.read<DownloadManagerCubit>().stream.map(_downloadSnapshots),
    );
    return queue;
  }

  static List<DownloadSnapshot> _downloadSnapshots(DownloadManagerState state) {
    return state.downloads
        .map(
          (DownloadDomain download) => DownloadSnapshot(
            key: download.uid,
            done: download.status == DownloadStatus.done,
            failed: download.status == DownloadStatus.failed,
            pages: DownloadFiles.localPagePaths(download),
          ),
        )
        .toList();
  }
}
