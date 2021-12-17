import 'package:dio/dio.dart';
import 'package:h_reader/models/nhentai/gallery/gallery.dart';
import 'package:retrofit/retrofit.dart';

part 'nhentai_repository.g.dart';

@RestApi(baseUrl: 'https://nhentai.net/api/')
abstract class NHentaiRepository {
  factory NHentaiRepository(Dio dio) = _NHentaiRepository;

  @GET('/galleries/all')
  Future<Gallery> getGallery(@Query('page') int page);
}
