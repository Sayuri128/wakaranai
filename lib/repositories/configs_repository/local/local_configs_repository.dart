import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'local_configs_repository.g.dart';

@RestApi(baseUrl: String.fromEnvironment('LOCAL_REPOSITORY_URL'))
abstract class LocalConfigsRepository {
  factory LocalConfigsRepository(Dio dio, {String baseUrl}) = _LocalConfigsRepository;

  @GET('/script/manga')
  Future<List<String>> getMangaConfigs();
}
