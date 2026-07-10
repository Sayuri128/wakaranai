import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/github_response_model.dart';

class GithubConfigsRepository {
  static const String mangaDirectory = 'manga';
  static const String animeDirectory = 'anime';

  GithubConfigsRepository(this._dio);

  final Dio _dio;

  static const String _baseUrl = 'https://github.com/';

  Future<GithubResponseModel> getDirectories(
    String org,
    String repo, {
    required String directory,
    String branch = 'main',
    int maxAge = 300,
    String accept = 'application/json',
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '$_baseUrl$org/$repo/tree/$branch/$directory',
      options: Options(
        headers: <String, dynamic>{'max-age': maxAge, 'accept': accept},
        responseType: ResponseType.json,
      ),
    );
    return GithubResponseModel.fromJson(response.data!);
  }

  Future<String> getConcreteContent({
    required String org,
    required String repo,
    required String concrete,
    String branch = 'main',
    int maxAge = 300,
    String accept = 'application/json',
  }) async {
    final Response<String> response = await _dio.get<String>(
      '$_baseUrl$org/$repo/raw/$branch/$concrete',
      options: Options(
        headers: <String, dynamic>{'max-age': maxAge, 'accept': accept},
        responseType: ResponseType.plain,
      ),
    );
    return response.data!;
  }
}
