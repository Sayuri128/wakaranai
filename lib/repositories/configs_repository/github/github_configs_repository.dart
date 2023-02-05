import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:wakaranai/models/github/repository/content/github_repository_content.dart';

part 'github_configs_repository.g.dart';

@RestApi(baseUrl: "https://api.github.com/")
abstract class GithubConfigsRepository {
  static const String MANGA_DIRECTORY = 'manga';
  static const String ANIME_DIRECTOR = 'anime';

  factory GithubConfigsRepository(Dio dio) = _GithubConfigsRepository;

  @GET('/repos/{org}/{repo}/contents/scripts/$MANGA_DIRECTORY')
  Future<List<GithubRepositoryContent>> getMangaConfigs(@Path() String org, @Path() String repo);

  @GET('/repos/{org}/{repo}/contents/scripts/$ANIME_DIRECTOR')
  Future<List<GithubRepositoryContent>> getAnimeConfigs(@Path() String org, @Path() String repo);
}
