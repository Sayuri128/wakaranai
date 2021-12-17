import 'package:bloc/bloc.dart';

part 'source_view_state.dart';

class SourceViewCubit extends Cubit<SourceViewState> {
  SourceViewCubit(SourceViewState initialState) : super(initialState);

  void onPageChanged(int index) => emit(state.copyWith(currentPage: index));

  void onChangeVisibility() => emit(state.copyWith(controlsVisible: !state.controlsVisible));
}
