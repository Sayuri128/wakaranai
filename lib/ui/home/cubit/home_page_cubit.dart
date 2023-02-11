import 'package:bloc/bloc.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageState(currentPage: 0));

  void changePage(int index) {
    emit(state.copyWith(currentPage: index));
  }
}
