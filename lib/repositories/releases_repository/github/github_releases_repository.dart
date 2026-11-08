import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';

class GithubReleasesRepository {
  GithubReleasesRepository(this._dio);

  final Dio _dio;

  static const String _baseUrl = 'https://api.github.com/';

  Future<GithubReleaseResponseModel> getLatestRelease({
    required String org,
    required String repo,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '${_baseUrl}repos/$org/$repo/releases/latest',
      options: Options(
        headers: <String, dynamic>{
          'accept': 'application/vnd.github+json',
          'x-github-api-version': '2022-11-28',
        },
        responseType: ResponseType.json,
      ),
    );
    return GithubReleaseResponseModel.fromJson(response.data!);
  }
}
