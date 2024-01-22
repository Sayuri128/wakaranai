import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:wakaranai/models/configs_repo/configs_response/repo_configs_response.dart';
import 'package:wakaranai/models/remote_script/remote_script.dart';

part 'local_configs_repository.g.dart';

@RestApi(baseUrl: String.fromEnvironment('LOCAL_REPOSITORY_URL'))
abstract class LocalConfigsRepository {
  factory LocalConfigsRepository(Dio dio, {String baseUrl}) =
      _LocalConfigsRepository;

  @GET('/configs')
  Future<RepoConfigsResponse> getConfigs(@Query("category") String category);

  @GET("/script")
  Future<RemoteScript> getScript(@Query("path") String path);
}
