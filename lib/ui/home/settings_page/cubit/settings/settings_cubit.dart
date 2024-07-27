import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.remoteConfigsCubit,
    required this.chapterActivityRepository,
    required this.animeEpisodeActivityRepository,
    required this.mangaActivityHistoryCubit,
    required this.animeActivityHistoryCubit,
  }) : super(SettingsInitial());

  final MangaActivityHistoryCubit mangaActivityHistoryCubit;
  final AnimeActivityHistoryCubit animeActivityHistoryCubit;

  final ChapterActivityRepository chapterActivityRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;

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
}
