part of 'nhentai_galleries_cubit.dart';

abstract class NHentaiGalleriesState extends Equatable {
  const NHentaiGalleriesState();
}

class NHentaiGalleriesInitial extends NHentaiGalleriesState {
  @override
  List<Object> get props => [];
}

class NHentaiGalleriesReceived extends NHentaiGalleriesState {
  final List<Doujinshi> doujinshis;

  @override
  List<Object?> get props => [doujinshis];

  const NHentaiGalleriesReceived({
    required this.doujinshis,
  });
}

class NHentaiGalleriesLoading extends NHentaiGalleriesState {
  @override
  List<Object?> get props => [];
}
