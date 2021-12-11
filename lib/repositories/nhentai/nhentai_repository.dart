import 'package:dio/dio.dart';
import 'package:h_reader/models/nhentai/gallery/gallery.dart';
import 'package:h_reader/services/nhentai/nhentai_service.dart';

class NHentaiRepository {
  final NHentaiService nHentaiService;

  NHentaiRepository() : nHentaiService = NHentaiService(Dio());

  Future<Gallery> getGallery(int page) async {
    return await nHentaiService.getGallery(page);
  }
}
