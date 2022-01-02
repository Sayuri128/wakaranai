import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:wakaranai/models/github/repository/content/github_repository_content.dart';

part 'configs_repository.g.dart';

@RestApi(baseUrl: "https://api.github.com/")
abstract class ConfigsRepository {
  static const String MANGA_DIRECTORY = 'manga';

  factory ConfigsRepository(Dio dio) = _ConfigsRepository;

  @GET('/repos/{org}/{repo}/contents/$MANGA_DIRECTORY')
  Future<List<GithubRepositoryContent>> getMangaConfigs(@Path() String org, @Path() String repo);
}
