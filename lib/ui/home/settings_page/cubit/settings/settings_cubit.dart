import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/data/domain/import_export/import_export_model.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
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

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
      {required this.remoteConfigsCubit,
      required this.mangaActivityHistoryCubit,
      required this.animeActivityHistoryCubit,
      required this.database})
      : super(SettingsInitial());

  final WakaranaiDatabase database;
  final MangaActivityHistoryCubit mangaActivityHistoryCubit;
  final AnimeActivityHistoryCubit animeActivityHistoryCubit;

  AnimeEpisodeActivityRepository get animeEpisodeActivityRepository =>
      animeActivityHistoryCubit.animeEpisodeActivityRepository;

  ChapterActivityRepository get chapterActivityRepository =>
      mangaActivityHistoryCubit.chapterActivityRepository;

  static const int importExportVersion = 1;

  // static final DefaultConfigsServiceItem = ConfigsSourceItem(
  //     baseUrl:
  //         '${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG}/${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY}',
  //     name: S.current.github_configs_source_type,
  //     type: ConfigsSourceType.GIT_HUB);

  final RemoteConfigsCubit remoteConfigsCubit;

  final SettingsService _settingsService = SettingsService();

  void init() async {
    emit(
      SettingsInitialized(
        defaultMode: await _settingsService.getDefaultReaderMode(),
      ),
    );
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

  void importActivityHistory(BuildContext context) async {
    final state = this.state;
    if (state is SettingsInitialized) {
      emit(state.copyWith(loading: true));

      try {
        final pickResult = await FilePicker.platform.pickFiles(
          allowedExtensions: ["json"],
          allowMultiple: false,
          type: FileType.custom,
        );

        if (pickResult == null) return;
        if (!pickResult.isSinglePick) return;
        if (pickResult.files.isEmpty) return;

        final file = pickResult.files[0];

        final str = await file.xFile.readAsString();

        final data = ImportExportMode.fromJson(jsonDecode(str));

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
          message: S.current.settings_import_activity_history_success(
              importedElements, numberOfElements),
        );

        animeActivityHistoryCubit.init();
        mangaActivityHistoryCubit.init();
      } catch (e) {
        logger.e(e);
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.settings_import_activity_history_error,
        );
      } finally {
        emit(state.copyWith(loading: false));
      }
    }
  }

  void exportActivityHistory(BuildContext context) async {
    final state = this.state;
    if (state is SettingsInitialized) {
      emit(state.copyWith(loading: true));

      try {
        // Prepare the export data structure
        final exportData = ImportExportMode(
            exportedAt: DateTime.now(),
            version: importExportVersion,
            mangaChapterActivities: await chapterActivityRepository.getAll(),
            animeEpisodeActivities:
                await animeEpisodeActivityRepository.getAll());

        await FileSaver.instance.saveAs(
          name: 'wakaranai_export_${DateTime.now().toIso8601String()}',
          bytes: utf8.encode(jsonEncode(exportData.toJson())),
          ext: 'json',
          mimeType: MimeType.json,
        );

        SnackBars.showSnackBar(
          context: context,
          message: S.current.settings_export_activity_history_success,
        );
      } catch (e) {
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.settings_export_activity_history_error,
        );
      } finally {
        emit(state.copyWith(loading: false));
      }
    }
  }
}
