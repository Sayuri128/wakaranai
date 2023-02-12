import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:wakaranai/models/github/repository/content/github_repository_content.dart';

part 'github_configs_repository.g.dart';

@RestApi(baseUrl: "https://api.github.com/")
abstract class GithubConfigsRepository {
  static const String MANGA_DIRECTORY = 'manga';
  static const String ANIME_DIRECTORY = 'anime';

  factory GithubConfigsRepository(Dio dio) = _GithubConfigsRepository;

  @GET('/repos/{org}/{repo}/contents/scripts/$MANGA_DIRECTORY')
  Future<List<GithubRepositoryContent>> getMangaDirectories(
      @Path() String org, @Path() String repo,
      {@Query("ref") String branch = 'master',
      @Header("max-age") int maxAge = 300});

  @GET('/repos/{org}/{repo}/contents/scripts/$ANIME_DIRECTORY')
  Future<List<GithubRepositoryContent>> getAnimeDirectories(
      @Path() String org, @Path() String repo,
      {@Query("ref") String branch = 'master',
      @Header("max-age") int maxAge = 300});

  @GET("/repos/{org}/{repo}/contents/scripts/{directory}/{concrete}")
  Future<List<GithubRepositoryContent>> getConcreteContent(
      {@Path() required String org,
      @Path() required String repo,
      @Path() required String directory,
      @Path() required String concrete,
      @Header("max-age") int maxAge = 300});
}
