import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';

class GithubReleasesRepository {
  GithubReleasesRepository(this._dio);

  final Dio _dio;

  static const String _baseUrl = 'https://api.github.com/';

  Future<GithubReleaseResponseModel> getLatestRelease({
    required String org,
    required String repo,
    int maxAge = 300,
    String accept = 'application/json',
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${_baseUrl}repos/$org/$repo/releases/latest',
      options: Options(
        headers: <String, dynamic>{'max-age': maxAge, 'accept': accept},
        responseType: ResponseType.json,
      ),
    );
    return GithubReleaseResponseModel.fromJson(response.data!);
  }
}
