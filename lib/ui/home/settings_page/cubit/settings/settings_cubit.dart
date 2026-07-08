import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/data/domain/import_export/import_export_model.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/services/import_export/import_export_notification_service.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/services/import_export/import_export_task.dart';
import 'package:wakaranai/services/import_export/import_task_store.dart';
import 'package:wakaranai/services/library_updates/library_update_notification_service.dart';
import 'package:wakaranai/services/library_updates/library_update_task.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/services/import_export/export_section_labels.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

// ignore: unused_import
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';

// ignore: unused_import
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';

part 'settings_state.dart';

class PickedImport {
  final ExportBundle? bundle;
  final ImportExportMode? legacy;
  final String? path;

  const PickedImport({this.bundle, this.legacy, this.path});
}

class ImportOutcome {
  final bool success;
  final int imported;
  final int total;
  final int skipped;

  const ImportOutcome({
    required this.success,
    this.imported = 0,
    this.total = 0,
    this.skipped = 0,
  });
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
      {required this.remoteConfigsCubit,
      required this.mangaActivityHistoryCubit,
      required this.animeActivityHistoryCubit,
      required this.importExportService,
      required this.themeCubit,
      required this.libraryCubit,
      required this.database,
      ImportExportNotificationService? notificationService})
      : notificationService =
            notificationService ?? ImportExportNotificationService(),
        super(SettingsInitial());

  final WakaranaiDatabase database;
  final ImportExportService importExportService;
  final ImportExportNotificationService notificationService;
  final ThemeCubit themeCubit;
  final LibraryCubit libraryCubit;
  final MangaActivityHistoryCubit mangaActivityHistoryCubit;
  final AnimeActivityHistoryCubit animeActivityHistoryCubit;

  AnimeEpisodeActivityRepository get animeEpisodeActivityRepository =>
      animeActivityHistoryCubit.animeEpisodeActivityRepository;

  ChapterActivityRepository get chapterActivityRepository =>
      mangaActivityHistoryCubit.chapterActivityRepository;


  // static final DefaultConfigsServiceItem = ConfigsSourceItem(
  //     baseUrl:
  //         '${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG}/${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY}',
  //     name: S.current.github_configs_source_type,
  //     type: ConfigsSourceType.GIT_HUB);

  final RemoteConfigsCubit remoteConfigsCubit;

  final SettingsService _settingsService = SettingsService();
  final ImportTaskStore importTaskStore = ImportTaskStore();

  Timer? _importWatcher;
  Set<ExportSection> _importedSections = <ExportSection>{};
  bool _resumeChecked = false;

  DateTime _lastProgressEmit = DateTime.fromMillisecondsSinceEpoch(0);

  void _onProgress(ImportExportProgress progress) {
    final state = this.state;
    if (state is! SettingsInitialized) return;

    final DateTime now = DateTime.now();
    final bool finished =
        progress.total > 0 && progress.processed >= progress.total;

    if (!finished &&
        now.difference(_lastProgressEmit) < const Duration(milliseconds: 60)) {
      return;
    }

    _lastProgressEmit = now;
    emit(state.copyWith(progress: progress));

    try {
      notificationService.showProgress(
        title: progress.exporting
            ? S.current.settings_export_progress_title
            : S.current.settings_import_progress_title,
        body: progress.section != null
            ? exportSectionTitle(progress.section!)
            : S.current.settings_progress_preparing,
        processed: progress.processed,
        total: progress.total,
      );
    } catch (e) {
      logger.w('Failed to publish transfer progress: $e');
    }
  }

  void init() async {
    emit(
      SettingsInitialized(
        defaultMode: await _settingsService.getDefaultReaderMode(),
        showNsfw: await _settingsService.getShowNsfw(),
        collectStatistics: await _settingsService.getCollectStatistics(),
        checkUpdates: await _settingsService.getCheckUpdates(),
        updateNotifications: await _settingsService.getUpdateNotifications(),
        updateFrequencyHours: await _settingsService.getUpdateFrequencyHours(),
      ),
    );

    if (!_resumeChecked && backgroundImportSupported) {
      _resumeChecked = true;
      await resumeImportWatcherIfNeeded();
    }
  }

  void onChangedShowNsfw(bool value) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    await _settingsService.setShowNsfw(value);
    emit(state.copyWith(showNsfw: value));
  }

  void onChangedCollectStatistics(bool value) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    await _settingsService.setCollectStatistics(value);
    emit(state.copyWith(collectStatistics: value));
  }

  bool get backgroundUpdatesSupported => !kIsWeb && Platform.isAndroid;

  void onChangedCheckUpdates(bool value) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    await _settingsService.setCheckUpdates(value);
    emit(state.copyWith(checkUpdates: value));
    await _rescheduleUpdateTask(
      enabled: value,
      frequencyHours: state.updateFrequencyHours,
    );
  }

  void onChangedUpdateNotifications(bool value) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    await _settingsService.setUpdateNotifications(value);
    emit(state.copyWith(updateNotifications: value));
    if (value) {
      await LibraryUpdateNotificationService().requestPermission();
    }
  }

  void onChangedUpdateFrequency(int hours) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    await _settingsService.setUpdateFrequencyHours(hours);
    emit(state.copyWith(updateFrequencyHours: hours));
    await _rescheduleUpdateTask(
      enabled: state.checkUpdates,
      frequencyHours: hours,
    );
  }

  Future<void> _rescheduleUpdateTask({
    required bool enabled,
    required int frequencyHours,
  }) async {
    if (!backgroundUpdatesSupported) return;

    try {
      if (!enabled) {
        await cancelLibraryUpdateTask();
        return;
      }

      await LibraryUpdateNotificationService().requestPermission();
      await registerLibraryUpdateTask(
        frequencyHours: frequencyHours,
        localeName: Intl.getCurrentLocale(),
      );
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
    }
  }

  Future<void> deleteActivityHistory(BuildContext context) async {
    final state = this.state;
    if (state is SettingsInitialized) {
      emit(state.copyWith(
        loading: true,
      ));
      try {
        await chapterActivityRepository.deleteAll();
        await animeEpisodeActivityRepository.deleteAll();

        SnackBars.showSnackBar(
          context: context,
          message: S.current.settings_clear_activity_history_dialog_success,
        );
      } catch (e) {
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.settings_clear_activity_history_dialog_error,
        );
      } finally {
        animeActivityHistoryCubit.init();
        mangaActivityHistoryCubit.init();
        emit(state.copyWith(
          loading: false,
        ));
      }
    }
  }

  void onChangedDefaultReadMode(ChapterViewMode mode) async {
    await _settingsService.setDefaultReaderMode(mode);
    emit((state as SettingsInitialized).copyWith(defaultMode: mode));
  }

  Future<PickedImport?> pickImport(BuildContext context) async {
    try {
      final pickResult = await FilePicker.platform.pickFiles(
        allowedExtensions: ["json"],
        allowMultiple: false,
        type: FileType.custom,
      );

      if (pickResult == null) return null;
      if (!pickResult.isSinglePick) return null;
      if (pickResult.files.isEmpty) return null;

      final str = await pickResult.files[0].xFile.readAsString();
      final Map<String, dynamic> json =
          jsonDecode(str) as Map<String, dynamic>;
      final int version = (json['version'] as num?)?.toInt() ?? 1;

      if (version >= ImportExportService.exportVersion) {
        return PickedImport(
          bundle: ExportBundle.fromJson(json),
          path: await _stagePendingImport(str),
        );
      }
      return PickedImport(legacy: ImportExportMode.fromJson(json));
    } catch (e) {
      logger.e(e);
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.settings_import_error,
      );
      return null;
    }
  }

  Future<String?> _stagePendingImport(String contents) async {
    try {
      final Directory docs = await getApplicationDocumentsDirectory();
      final File file = File(p.join(docs.path, 'pending_import.json'));
      await file.writeAsString(contents);
      return file.path;
    } catch (e) {
      logger.w('Failed to stage import file: $e');
      return null;
    }
  }

  bool get backgroundImportSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> importInBackground(
    ExportBundle bundle,
    Set<ExportSection> sections,
    String path,
  ) async {
    try {
      await notificationService.requestPermission();
      await importTaskStore.clear();
      await importTaskStore.setRunning();

      await Workmanager().registerOneOffTask(
        importTaskUniqueName,
        importTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: <String, dynamic>{
          importTaskPathKey: path,
          importTaskSectionsKey: encodeExportSections(sections),
          importTaskLocaleKey: Intl.getCurrentLocale(),
        },
      );

      _importedSections = sections;
      final state = this.state;
      if (state is SettingsInitialized) {
        emit(state.copyWith(loading: true, clearProgress: true));
      }
      _startImportWatcher();
      return true;
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      await importTaskStore.clear();
      return false;
    }
  }

  void _startImportWatcher() {
    _importWatcher?.cancel();
    _importWatcher = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => _pollImportTask(),
    );
  }

  Future<void> resumeImportWatcherIfNeeded() async {
    final ImportTaskSnapshot snapshot = await importTaskStore.read();
    if (snapshot.status == ImportTaskStatus.running) {
      final state = this.state;
      if (state is SettingsInitialized) {
        emit(state.copyWith(loading: true));
      }
      _startImportWatcher();
    } else if (snapshot.status == ImportTaskStatus.done ||
        snapshot.status == ImportTaskStatus.failed) {
      await _pollImportTask();
    }
  }

  Future<void> _pollImportTask() async {
    final ImportTaskSnapshot snapshot = await importTaskStore.read();
    final state = this.state;
    if (state is! SettingsInitialized) return;

    switch (snapshot.status) {
      case ImportTaskStatus.running:
        emit(state.copyWith(
          loading: true,
          progress: ImportExportProgress(
            section: snapshot.section,
            processed: snapshot.processed,
            total: snapshot.total,
            exporting: false,
          ),
        ));
        break;
      case ImportTaskStatus.done:
        _importWatcher?.cancel();
        _importWatcher = null;
        await importTaskStore.clear();
        await _refreshAfterImport(_importedSections);
        emit((this.state as SettingsInitialized).copyWith(
          loading: false,
          clearProgress: true,
          outcome: ImportOutcome(
            success: true,
            imported: snapshot.imported,
            total: snapshot.total,
            skipped: snapshot.skipped,
          ),
        ));
        break;
      case ImportTaskStatus.failed:
        _importWatcher?.cancel();
        _importWatcher = null;
        await importTaskStore.clear();
        emit(state.copyWith(
          loading: false,
          clearProgress: true,
          outcome: const ImportOutcome(success: false),
        ));
        break;
      case ImportTaskStatus.idle:
        _importWatcher?.cancel();
        _importWatcher = null;
        emit(state.copyWith(loading: false, clearProgress: true));
        break;
    }
  }

  Future<void> _refreshAfterImport(Set<ExportSection> sections) async {
    if (sections.contains(ExportSection.sources)) {
      remoteConfigsCubit.init();
    }
    if (sections.contains(ExportSection.library) ||
        sections.contains(ExportSection.categories)) {
      libraryCubit.init();
    }
    if (sections.contains(ExportSection.history)) {
      animeActivityHistoryCubit.init();
      mangaActivityHistoryCubit.init();
    }
    if (sections.contains(ExportSection.settings)) {
      await themeCubit.init();
      init();
    }
  }

  void clearOutcome() {
    final state = this.state;
    if (state is! SettingsInitialized) return;
    emit(state.copyWith(clearOutcome: true));
  }

  @override
  Future<void> close() {
    _importWatcher?.cancel();
    return super.close();
  }

  Future<void> importBundle(
    BuildContext context,
    ExportBundle bundle,
    Set<ExportSection> sections,
  ) async {
    final state = this.state;
    if (state is! SettingsInitialized) return;

    emit(state.copyWith(loading: true, clearProgress: true));
    bool settingsImported = false;

    try {
      await notificationService.requestPermission();

      final ImportResult result = await importExportService.applyImport(
        bundle,
        sections,
        onProgress: _onProgress,
      );

      await notificationService.showComplete(
        title: S.current.settings_import_notification_complete,
        body: S.current.settings_import_success(
            result.imported, result.total),
      );

      if (sections.contains(ExportSection.sources)) {
        remoteConfigsCubit.init();
      }
      if (sections.contains(ExportSection.history)) {
        animeActivityHistoryCubit.init();
        mangaActivityHistoryCubit.init();
      }
      if (sections.contains(ExportSection.settings)) {
        settingsImported = true;
        await themeCubit.init();
      }

      final String message = S.current.settings_import_success(
          result.imported, result.total);

      SnackBars.showSnackBar(
        context: context,
        message: result.skipped > 0
            ? '$message · ${S.current.settings_import_skipped(result.skipped)}'
            : message,
      );
    } catch (e) {
      logger.e(e);
      await notificationService.cancelProgress();
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.settings_import_error,
      );
    } finally {
      if (settingsImported) {
        init();
      } else {
        emit(state.copyWith(loading: false, clearProgress: true));
      }
    }
  }

  Future<void> importLegacy(BuildContext context, ImportExportMode data) async {
    final state = this.state;
    if (state is SettingsInitialized) {
      emit(state.copyWith(loading: true));

      try {
        final numberOfElements = data.mangaChapterActivities.length +
            data.animeEpisodeActivities.length;
        int importedElements = 0;

        if (data.version == 1) {
          for (final activity in data.animeEpisodeActivities) {
            final existing = await animeEpisodeActivityRepository
                .getByComplex<$AnimeEpisodeActivityTableTable>(
              [activity.concreteId, activity.uid],
              where: (tbl) => [
                tbl.concreteId,
                tbl.uid,
              ],
            );

            if (existing == null) {
              await animeEpisodeActivityRepository.create(activity);
            } else {
              activity.id = existing.id;
              await animeEpisodeActivityRepository.update(activity,
                  update: false);
            }
            importedElements += 1;
          }

          for (final activity in data.mangaChapterActivities) {
            final existing = await chapterActivityRepository
                .getByComplex<$ChapterActivityTableTable>(
              [activity.concreteId, activity.uid],
              where: (tbl) => [
                tbl.concreteId,
                tbl.uid,
              ],
            );

            if (existing == null) {
              await chapterActivityRepository.create(activity);
            } else {
              activity.id = existing.id;
              await chapterActivityRepository.update(
                activity,
                update: false,
              );
            }
            importedElements += 1;
          }
        }

        SnackBars.showSnackBar(
          context: context,
          message: S.current.settings_import_success(
              importedElements, numberOfElements),
        );

        animeActivityHistoryCubit.init();
        mangaActivityHistoryCubit.init();
      } catch (e) {
        logger.e(e);
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.settings_import_error,
        );
      } finally {
        emit(state.copyWith(loading: false, clearProgress: true));
      }
    }
  }

  Future<void> exportData(
      BuildContext context, Set<ExportSection> sections) async {
    final state = this.state;
    if (state is SettingsInitialized) {
      emit(state.copyWith(loading: true, clearProgress: true));

      try {
        await notificationService.requestPermission();

        final ExportBundle bundle = await importExportService.buildExport(
          sections,
          onProgress: _onProgress,
        );

        await FileSaver.instance.saveAs(
          name: 'wakaranai_export_${DateTime.now().toIso8601String()}',
          bytes: utf8.encode(jsonEncode(bundle.toJson())),
          ext: 'json',
          mimeType: MimeType.json,
        );

        await notificationService.showComplete(
          title: S.current.settings_export_notification_complete,
        );

        SnackBars.showSnackBar(
          context: context,
          message: S.current.settings_export_success,
        );
      } catch (e) {
        await notificationService.cancelProgress();
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.settings_export_error,
        );
      } finally {
        emit(state.copyWith(loading: false, clearProgress: true));
      }
    }
  }
}
