import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/repositories/nhentai/nhentai_repository.dart';

part 'nhentai_galleries_state.dart';

class NHentaiGalleriesCubit extends Cubit<NHentaiGalleriesState> {
  NHentaiGalleriesCubit() : super(NHentaiGalleriesInitial());

  final NHentaiRepository _nHentaiRepository = NHentaiRepository();

  void requestGallery(int page) async {
    emit(NHentaiGalleriesLoading());
    Future.delayed(Duration(milliseconds: 100), () async {
      emit(
          NHentaiGalleriesReceived(doujinshis: (await _nHentaiRepository.getGallery(page)).result));
    });
  }
}
