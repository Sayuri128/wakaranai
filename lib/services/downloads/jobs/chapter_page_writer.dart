import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/main.dart';

class ChapterPageWriter {
  ChapterPageWriter({
    required Dio dio,
    required DownloadThrottle throttle,
    required DownloadWait wait,
  })  : _dio = dio,
        _throttle = throttle,
        _wait = wait;

  static const int _pageAttempts = 3;
  static const int _rateLimitAttempts = 6;

  final Dio _dio;
  final DownloadThrottle _throttle;
  final DownloadWait _wait;

  Future<void> write({
    required String url,
    required File file,
    required Map<String, String> headers,
    required String extensionUid,
    required CancelToken cancelToken,
  }) async {
    if (url.startsWith('data:')) {
      final Uint8List bytes = base64Decode(url.split(',').last);
      if (bytes.isEmpty) {
        throw StateError('Empty inline page data');
      }
      await file.writeAsBytes(bytes);
      return;
    }

    Object? lastError;
    int failures = 0;
    int rateLimits = 0;

    while (failures < _pageAttempts && rateLimits < _rateLimitAttempts) {
      try {
        final Response<List<int>> response = await _dio.get<List<int>>(
          url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.bytes,
            headers: headers,
          ),
        );

        final List<int>? data = response.data;
        if (data == null || data.isEmpty) {
          throw StateError('Empty response for $url');
        }

        await file.writeAsBytes(data);
        return;
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) {
          rethrow;
        }
        lastError = e;
        if (_isRateLimited(e)) {
          rateLimits++;
          _throttle.rateLimited(extensionUid);
          final String? retryAfter = (e as DioException)
              .response
              ?.headers
              .value(HttpHeaders.retryAfterHeader);
          logger.w('Rate limited on $url, attempt $rateLimits');
          await waitIfPositive(
            _wait,
            _throttle.retryWait(rateLimits, retryAfterHeader: retryAfter),
          );
          continue;
        }
        failures++;
        if (failures < _pageAttempts) {
          await waitIfPositive(_wait, Duration(milliseconds: 300 * failures));
        }
      }
    }

    throw StateError('Failed to download $url: $lastError');
  }

  bool _isRateLimited(Object error) {
    if (error is! DioException) {
      return false;
    }
    final int? status = error.response?.statusCode;
    return status == HttpStatus.tooManyRequests ||
        status == HttpStatus.serviceUnavailable;
  }
}
