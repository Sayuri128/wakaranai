part of 'home_page_cubit.dart';

class HomePageState {
  final int currentPage;

  const HomePageState({
    required this.currentPage,
  });

  HomePageState copyWith({
    int? currentPage,
  }) {
    return HomePageState(
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
