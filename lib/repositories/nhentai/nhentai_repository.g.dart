// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhentai_repository.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _NHentaiRepository implements NHentaiRepository {
  _NHentaiRepository(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://nhentai.net/api/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<Gallery> getGallery(page) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Gallery>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/galleries/all',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = Gallery.fromJson(_result.data!);
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
