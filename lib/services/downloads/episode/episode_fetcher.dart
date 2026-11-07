import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/episode_http.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';

typedef EpisodeResponseHandler<T> =
    Future<T> Function(EpisodeHttpResponse response);

const Set<int> _expiredStatuses = <int>{401, 403, 410};
const Set<int> _rateLimitStatuses = <int>{429, 503};

class EpisodeProbeResult {
  const EpisodeProbeResult.hls(String this.playlistText);

  const EpisodeProbeResult.progressive() : playlistText = null;

  final String? playlistText;

  bool get isHls => playlistText != null;
}

class EpisodeFetcher {
  EpisodeFetcher({
    required EpisodeHttp http,
    required DownloadThrottle throttle,
    required this.throttleKey,
    required this.cancelToken,
    this.maxFailures = 3,
    this.maxRateLimits = 6,
    this.failureBackoff = const Duration(milliseconds: 500),
  }) : _http = http,
       _throttle = throttle;

  final EpisodeHttp _http;
  final DownloadThrottle _throttle;
  final String throttleKey;
  final CancelToken cancelToken;
  final int maxFailures;
  final int maxRateLimits;
  final Duration failureBackoff;
  bool _rateLimited = false;

  bool get wasRateLimited => _rateLimited;

  Future<T> send<T>({
    required String url,
    required Map<String, String> Function() headers,
    required EpisodeResponseHandler<T> onResponse,
    Set<int> acceptedStatuses = const <int>{},
  }) async {
    int failures = 0;
    int rateLimits = 0;
    while (true) {
      throwIfCancelled(cancelToken);
      await _wait(_throttle.pageDelay(throttleKey));
      throwIfCancelled(cancelToken);
      final _Attempt<T> attempt = await _attempt(
        url: url,
        headers: headers(),
        onResponse: onResponse,
        acceptedStatuses: acceptedStatuses,
      );
      if (attempt.isDone) {
        return attempt.value as T;
      }
      final String? retryAfter = attempt.retryAfter;
      if (attempt.isRateLimited) {
        rateLimits++;
        await _onRateLimited(url, rateLimits, retryAfter);
        continue;
      }
      failures++;
      if (failures >= maxFailures) {
        throw EpisodeDownloadFailure(url: url, cause: attempt.error);
      }
      logger.w(
        'Episode request failed ($failures/$maxFailures): '
        '$url ${attempt.error}',
      );
      await _wait(failureBackoff * failures);
    }
  }

  Future<_Attempt<T>> _attempt<T>({
    required String url,
    required Map<String, String> headers,
    required EpisodeResponseHandler<T> onResponse,
    required Set<int> acceptedStatuses,
  }) async {
    try {
      final EpisodeHttpResponse response = await _http.get(
        url,
        headers: headers,
        cancelToken: cancelToken,
      );
      final int status = response.statusCode;
      if (response.isSuccessful || acceptedStatuses.contains(status)) {
        return _Attempt<T>.done(await onResponse(response));
      }
      await response.discard();
      if (_expiredStatuses.contains(status)) {
        throw EpisodeSourceExpired(url: url, statusCode: status);
      }
      if (_rateLimitStatuses.contains(status)) {
        return _Attempt<T>.rateLimited(response.header('retry-after'));
      }
      return _Attempt<T>.failed(HttpException('HTTP $status'));
    } catch (error) {
      if (_isFatal(error)) {
        rethrow;
      }
      return _Attempt<T>.failed(error);
    }
  }

  Future<void> _onRateLimited(
    String url,
    int rateLimits,
    String? retryAfter,
  ) async {
    _rateLimited = true;
    _throttle.rateLimited(throttleKey);
    if (rateLimits >= maxRateLimits) {
      throw EpisodeDownloadFailure(url: url, cause: 'rate limited');
    }
    logger.w('Episode request rate limited ($rateLimits): $url');
    await _wait(_throttle.retryWait(rateLimits, retryAfterHeader: retryAfter));
  }

  bool _isFatal(Object error) {
    if (error is DioException && CancelToken.isCancel(error)) {
      return true;
    }
    return error is EpisodeSourceExpired ||
        error is UnsupportedEpisodeDownload ||
        error is EpisodeDownloadFailure;
  }

  Future<void> _wait(Duration duration) async {
    if (duration > Duration.zero) {
      await Future<void>.delayed(duration);
    }
    throwIfCancelled(cancelToken);
  }

  Future<Uint8List> fetchBytes(String url, Map<String, String> headers) {
    return send<Uint8List>(
      url: url,
      headers: () => headers,
      onResponse: (EpisodeHttpResponse response) =>
          readStreamFully(response.body, cancelToken: cancelToken),
    );
  }

  Future<String> fetchText(String url, Map<String, String> headers) async {
    return decodeText(await fetchBytes(url, headers));
  }

  Future<EpisodeProbeResult> probe(String url, Map<String, String> headers) {
    return send<EpisodeProbeResult>(
      url: url,
      headers: () => headers,
      onResponse: _probeResponse,
    );
  }

  Future<EpisodeProbeResult> _probeResponse(
    EpisodeHttpResponse response,
  ) async {
    final BytesBuilder head = BytesBuilder(copy: false);
    bool? hls;
    await for (final List<int> chunk in response.body) {
      throwIfCancelled(cancelToken);
      head.add(chunk);
      hls ??= _classifyHead(head.toBytes());
      if (hls == false) {
        break;
      }
    }
    final Uint8List bytes = head.takeBytes();
    if (hls == true || looksLikeHlsPlaylist(decodeText(bytes))) {
      return EpisodeProbeResult.hls(decodeText(bytes));
    }
    return const EpisodeProbeResult.progressive();
  }

  bool? _classifyHead(Uint8List bytes) {
    final String text = decodeText(bytes).replaceFirst('﻿', '');
    final String trimmed = text.trimLeft();
    if (trimmed.length < 7) {
      return bytes.length >= 64 ? false : null;
    }
    return trimmed.startsWith('#EXTM3U');
  }

  Future<int> downloadToFile({
    required String url,
    required Map<String, String> headers,
    required File target,
    HlsByteRange? range,
    void Function(File part)? validate,
  }) {
    return send<int>(
      url: url,
      headers: () => _withRange(headers, range),
      onResponse: (EpisodeHttpResponse response) => _writeResponse(
        response,
        target: target,
        range: range,
        validate: validate,
      ),
    );
  }

  Map<String, String> _withRange(
    Map<String, String> headers,
    HlsByteRange? range,
  ) {
    if (range == null) {
      return headers;
    }
    return <String, String>{...headers, 'Range': range.rangeHeader};
  }

  Future<int> _writeResponse(
    EpisodeHttpResponse response, {
    required File target,
    required HlsByteRange? range,
    required void Function(File part)? validate,
  }) async {
    final File part = partFileOf(target);
    Stream<List<int>> body = response.body;
    if (range != null && response.statusCode != HttpStatus.partialContent) {
      body = sliceByteStream(body, offset: range.offset, length: range.length);
    }
    try {
      final int written = await pipeStreamToFile(
        body,
        part,
        cancelToken: cancelToken,
      );
      _checkWrittenLength(written, range);
      validate?.call(part);
      await part.rename(target.path);
      return written;
    } catch (_) {
      await deleteIfExists(part);
      rethrow;
    }
  }

  void _checkWrittenLength(int written, HlsByteRange? range) {
    if (written == 0) {
      throw const HttpException('Empty response body');
    }
    if (range != null && written != range.length) {
      throw HttpException(
        'Expected ${range.length} bytes for a byte range, got $written',
      );
    }
  }
}

class _Attempt<T> {
  const _Attempt.done(this.value)
    : isDone = true,
      isRateLimited = false,
      retryAfter = null,
      error = null;

  const _Attempt.rateLimited(this.retryAfter)
    : isDone = false,
      isRateLimited = true,
      value = null,
      error = null;

  const _Attempt.failed(this.error)
    : isDone = false,
      isRateLimited = false,
      value = null,
      retryAfter = null;

  final bool isDone;
  final bool isRateLimited;
  final T? value;
  final String? retryAfter;
  final Object? error;
}
