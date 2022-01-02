import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit(ChapterViewState initialState) : super(initialState);

  void onPageChanged(int index) => emit(state.copyWith(currentPage: index));

  void onChangeVisibility() => emit(state.copyWith(controlsVisible: !state.controlsVisible));
}
