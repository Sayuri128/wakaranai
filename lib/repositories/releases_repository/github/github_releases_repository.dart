import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';

part 'github_releases_repository.g.dart';

@RestApi(baseUrl: "https://api.github.com/")
abstract class GithubReleasesRepository {
  factory GithubReleasesRepository(Dio dio) = _GithubReleasesRepository;

  @GET("repos/{org}/{repo}/releases/latest")
  Future<GithubReleaseResponseModel> getLatestRelease({
    @Path() required String org,
    @Path() required String repo,
    @Header("max-age") int maxAge = 300,
    @Header("accept") String accept = "application/json",
  });
}
