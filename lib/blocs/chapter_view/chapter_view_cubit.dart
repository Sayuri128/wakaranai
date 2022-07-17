import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/chapter/chapter.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit({required this.apiClient}) : super(ChapterViewInit());

  final ApiClient apiClient;

  void init(Chapter chapter) async {
    print(chapter.uid);
    final pages = await apiClient.getPages(uid: chapter.uid);

    emit(ChapterViewInitialized(
        pages: pages,
        currentPage: 1,
        totalPages: pages.value.length,
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
