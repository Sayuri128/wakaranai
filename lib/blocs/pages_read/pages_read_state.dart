part of 'pages_read_cubit.dart';

@immutable
abstract class PagesReadState {
  const PagesReadState();
}

class PagesReadInitial extends PagesReadState {}

class PagesReadInitialized extends PagesReadState {

  final List<PagesRead> pagesRead;

  const PagesReadInitialized({
    required this.pagesRead,
  });
}
