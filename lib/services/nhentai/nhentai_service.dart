
import 'package:dio/dio.dart';
import 'package:h_reader/models/nhentai/gallery/gallery.dart';
import 'package:h_reader/repositories/nhentai/nhentai_repository.dart';

class NHentaiService {

  final NHentaiRepository nHentaiRepository = NHentaiRepository(Dio());

  Future<Gallery> getGallery(int page) async {
    return await nHentaiRepository.getGallery(page);
  }

}
