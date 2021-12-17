import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/services/nhentai/nhentai_service.dart';

part 'nhentai_galleries_state.dart';

class NHentaiGalleriesCubit extends Cubit<NHentaiGalleriesState> {
  NHentaiGalleriesCubit() : super(NHentaiGalleriesInitial());

  final NHentaiService _nHentaiService = NHentaiService();

  void requestGallery(int page) async {
    emit(NHentaiGalleriesLoading());
    Future.delayed(const Duration(milliseconds: 100), () async {
      emit(
          NHentaiGalleriesReceived(doujinshis: (await _nHentaiService.getGallery(page)).result));
    });
  }
}
