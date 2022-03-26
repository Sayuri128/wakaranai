import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/chapter/chapter.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit({required this.apiClient}) : super(ChapterViewInit());

  final ApiClient apiClient;

  void init(Chapter chapter) async {
    if (apiClient.needCollectChapterData()) {
      chapter = await apiClient.makeGetChapterRequest(chapter: chapter);
    }

    emit(ChapterViewInitialized(
        chapter: chapter,
        currentPage: 1,
        totalPages: chapter.pages.length,
        controlsVisible: true));
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
}
