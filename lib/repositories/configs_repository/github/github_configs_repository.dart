import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:wakaranai/models/github/github_response_model.dart';

import '../../../models/github/release_response/github_release_response_model.dart';

part 'github_configs_repository.g.dart';

@RestApi(baseUrl: "https://github.com/")
abstract class GithubConfigsRepository {
  static const String mangaDirectory = 'manga';
  static const String animeDirectory = 'anime';

  factory GithubConfigsRepository(Dio dio) = _GithubConfigsRepository;

  @GET('/{org}/{repo}/tree/{branch}/{directory}')
  Future<GithubResponseModel> getDirectories(
    @Path() String org,
    @Path() String repo, {
    @Path() required String directory,
    @Path() String branch = 'master',
    @Header("max-age") int maxAge = 300,
    @Header("accept") String accept = "application/json",
  });

  @GET("/{org}/{repo}/raw/{branch}/{concrete}")
  Future<String> getConcreteContent({
    @Path() required String org,
    @Path() required String repo,
    @Path() required String concrete,
    @Path() String branch = 'master',
    @Header("max-age") int maxAge = 300,
    @Header("accept") String accept = "application/json",
  });
}
