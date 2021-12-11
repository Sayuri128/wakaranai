part of 'nhentai_galleries_cubit.dart';

abstract class NHentaiGalleriesState extends Equatable {
  const NHentaiGalleriesState();
}

class NHentaiGalleriesInitial extends NHentaiGalleriesState {
  @override
  List<Object> get props => [];
}

class NHentaiGalleriesReceived extends NHentaiGalleriesState {

  final List<Doujinshi> doujishis;

  @override
  List<Object?> get props => [doujishis];

  const NHentaiGalleriesReceived({
    required this.doujishis,
  });
}
