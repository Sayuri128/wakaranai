// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configs_repository.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ConfigsRepository implements ConfigsRepository {
  _ConfigsRepository(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://api.github.com/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<GithubRepositoryContent>> getMangaConfigs(org, repo) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<List<dynamic>>(
        _setStreamType<List<GithubRepositoryContent>>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/repos/${org}/${repo}/contents/manga',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) =>
            GithubRepositoryContent.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
