import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/chapter/chapter.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit({required this.apiClient, required this.settingsCubit})
      : super(ChapterViewInit());

  final SettingsCubit settingsCubit;

  final ApiClient apiClient;

  void init(Chapter chapter) async {
    final pages = await apiClient.getPages(uid: chapter.uid);

    emit(ChapterViewInitialized(
        pages: pages,
        currentPage: 1,
        totalPages: pages.value.length,
        controlsVisible: true,
        mode: settingsCubit.state is SettingsInitialized
            ? (settingsCubit.state as SettingsInitialized).defaultMode
            : ChapterViewMode.RIGHT_TO_LEFT));
  }

  void onPageChanged(int index) {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(currentPage: index));
    }
  }

  void onChangeVisibility() {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(
          controlsVisible: !(state as ChapterViewInitialized).controlsVisible));
    }
  }

  void onModeChanged(ChapterViewMode mode) {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(mode: mode));
    }
  }
}
