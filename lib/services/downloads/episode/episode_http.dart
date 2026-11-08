import 'dart:async';

import 'package:dio/dio.dart';
import 'package:wakaranai/utils/http_client.dart';

const Map<String, String> kEpisodeDefaultHeaders = <String, String>{
  'Accept': '*/*',
  'Accept-Language': 'en-US,en;q=0.9',
};

Map<String, String> mergeEpisodeHeaders(Map<String, String> sourceHeaders) {
  final Set<String> sourceNames = sourceHeaders.keys
      .map((String name) => name.toLowerCase())
      .toSet();
  return <String, String>{
    for (final MapEntry<String, String> entry in kEpisodeDefaultHeaders.entries)
      if (!sourceNames.contains(entry.key.toLowerCase()))
        entry.key: entry.value,
    ...sourceHeaders,
  };
}

class EpisodeHttpResponse {
  EpisodeHttpResponse({
    required this.statusCode,
    required Map<String, List<String>> headers,
    required this.body,
  }) : _headers = <String, List<String>>{
         for (final MapEntry<String, List<String>> entry in headers.entries)
           entry.key.toLowerCase(): entry.value,
       };

  final int statusCode;
  final Stream<List<int>> body;
  final Map<String, List<String>> _headers;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  String? header(String name) {
    final List<String>? values = _headers[name.toLowerCase()];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.join(', ');
  }

  int? get contentLength {
    final int? length = int.tryParse(header('content-length') ?? '');
    if (length == null || length < 0) {
      return null;
    }
    return length;
  }

  Future<void> discard() async {
    try {
      await body.listen(null, cancelOnError: true).cancel();
    } catch (_) {
      return;
    }
  }
}

abstract class EpisodeHttp {
  Future<EpisodeHttpResponse> get(
    String url, {
    required Map<String, String> headers,
    required CancelToken cancelToken,
  });
}

class DioEpisodeHttp implements EpisodeHttp {
  DioEpisodeHttp({Dio? dio}) : _dio = dio ?? createDio(acceptAllStatuses: true);

  final Dio _dio;

  @override
  Future<EpisodeHttpResponse> get(
    String url, {
    required Map<String, String> headers,
    required CancelToken cancelToken,
  }) async {
    final Response<ResponseBody> response = await _dio.get<ResponseBody>(
      url,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        validateStatus: (_) => true,
      ),
    );
    final ResponseBody? body = response.data;
    return EpisodeHttpResponse(
      statusCode: response.statusCode ?? body?.statusCode ?? 0,
      headers: response.headers.map,
      body: body?.stream ?? const Stream<List<int>>.empty(),
    );
  }
}
