
import 'package:dio/dio.dart';
import 'package:h_reader/models/nhentai/gallery/gallery.dart';
import 'package:retrofit/http.dart';

part 'nhentai_service.g.dart';

@RestApi(baseUrl: 'https://nhentai.net/api/')
abstract class NHentaiService {

  factory NHentaiService(Dio dio) = _NHentaiService;

  @GET('/galleries/all')
  Future<Gallery> getGallery(@Query('page') int page);

}
