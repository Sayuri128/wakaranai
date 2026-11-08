import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_plan.dart';
import 'package:wakaranai/services/downloads/episode/episode_fetcher.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/episode_http.dart';
import 'package:wakaranai/services/downloads/episode/episode_media_sniff.dart';

typedef Mp4ProgressCallback =
    void Function(int downloadedBytes, int totalBytes);

const int _maxStalledRounds = 3;

class ContentRange {
  const ContentRange({this.start, this.end, this.total});

  static final RegExp _pattern = RegExp(
    r'bytes\s+(?:(\d+)-(\d+)|\*)\s*/\s*(\d+|\*)',
    caseSensitive: false,
  );

  static ContentRange? parse(String? header) {
    if (header == null) {
      return null;
    }
    final RegExpMatch? match = _pattern.firstMatch(header);
    if (match == null) {
      return null;
    }
    return ContentRange(
      start: int.tryParse(match.group(1) ?? ''),
      end: int.tryParse(match.group(2) ?? ''),
      total: int.tryParse(match.group(3) ?? ''),
    );
  }

  final int? start;
  final int? end;
  final int? total;
}

class _Mp4Round {
  const _Mp4Round({required this.complete, required this.totalBytes});

  final bool complete;
  final int? totalBytes;
}

class EpisodeMp4Downloader {
  EpisodeMp4Downloader({
    required this.fetcher,
    required this.url,
    required this.headers,
    required this.dir,
    this.onProgress,
  });

  final EpisodeFetcher fetcher;
  final String url;
  final Map<String, String> headers;
  final Directory dir;
  final Mp4ProgressCallback? onProgress;
  Mp4SourceFingerprint? _source;

  File get target => File(p.join(dir.path, kLocalMp4File));

  File get _part => partFileOf(target);

  Future<void> run() async {
    if (await target.exists()) {
      final int length = await target.length();
      onProgress?.call(length, length);
      return;
    }
    _source = await readMp4SourceFingerprint(dir);
    int stalledRounds = 0;
    int previousLength = -1;
    while (true) {
      final _Mp4Round round = await fetcher.send<_Mp4Round>(
        url: url,
        headers: _rangeHeaders,
        acceptedStatuses: const <int>{HttpStatus.requestedRangeNotSatisfiable},
        onResponse: _consume,
      );
      final int length = await _partLength();
      if (round.complete) {
        await _part.rename(target.path);
        await clearMp4SourceFingerprint(dir);
        onProgress?.call(length, round.totalBytes ?? length);
        return;
      }
      if (length <= previousLength) {
        stalledRounds++;
      }
      if (stalledRounds >= _maxStalledRounds) {
        throw EpisodeDownloadFailure(url: url, cause: 'download stalled');
      }
      previousLength = length;
    }
  }

  Map<String, String> _rangeHeaders() {
    final int existing = _part.existsSync() ? _part.lengthSync() : 0;
    final Map<String, String> rangeHeaders = <String, String>{
      ...headers,
      'Range': 'bytes=$existing-',
    };
    final String? validator = _source?.ifRangeValidator;
    if (existing > 0 && validator != null) {
      rangeHeaders['If-Range'] = validator;
    }
    return rangeHeaders;
  }

  Future<int> _partLength() async {
    if (!await _part.exists()) {
      return 0;
    }
    return _part.length();
  }

  Future<_Mp4Round> _consume(EpisodeHttpResponse response) async {
    if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
      return _consumeUnsatisfiable(response);
    }
    final int existing = await _partLength();
    final ContentRange? range = response.statusCode == HttpStatus.partialContent
        ? ContentRange.parse(response.header('content-range'))
        : null;
    final int start = _startOffset(response, range, existing);
    if (start > 0 && _servesAnotherFile(range)) {
      return _restartFromZero(response);
    }
    await _checkResumeOffset(response, start, existing);
    final Stream<List<int>> body = start == 0
        ? await _verifiedVideoBody(response)
        : response.body;
    if (start > 0 && start < existing) {
      await _truncatePart(start);
    }
    final int? total = range?.total ?? _totalFromLength(response, start);
    if (start == 0 || _source == null) {
      await _rememberSource(response, total);
    }
    await pipeStreamToFile(
      body,
      _part,
      cancelToken: fetcher.cancelToken,
      mode: start == 0 ? FileMode.write : FileMode.append,
      onChunk: _chunkReporter(start, total),
    );
    return _roundAfterWrite(total);
  }

  int _startOffset(
    EpisodeHttpResponse response,
    ContentRange? range,
    int existing,
  ) {
    if (response.statusCode != HttpStatus.partialContent) {
      return 0;
    }
    return range?.start ?? existing;
  }

  bool _servesAnotherFile(ContentRange? range) {
    final int? storedTotal = _source?.totalBytes;
    final int? servedTotal = range?.total;
    if (storedTotal == null || servedTotal == null) {
      return false;
    }
    return storedTotal != servedTotal;
  }

  Future<_Mp4Round> _restartFromZero(EpisodeHttpResponse response) async {
    logger.i('Episode file at $url changed since the last attempt, restarting');
    await response.discard();
    await _forgetPartialFile();
    return const _Mp4Round(complete: false, totalBytes: null);
  }

  Future<void> _forgetPartialFile() async {
    await deleteIfExists(_part);
    await clearMp4SourceFingerprint(dir);
    _source = null;
  }

  Future<void> _checkResumeOffset(
    EpisodeHttpResponse response,
    int start,
    int existing,
  ) async {
    if (start <= existing) {
      return;
    }
    await response.discard();
    await _forgetPartialFile();
    throw HttpException('Server resumed at $start, expected $existing');
  }

  Future<Stream<List<int>>> _verifiedVideoBody(
    EpisodeHttpResponse response,
  ) async {
    final SniffedMedia? declared = sniffContentType(
      response.header('content-type'),
    );
    if (declared != null) {
      await response.discard();
      throw nonVideoRejection(declared, url);
    }
    final StreamHead head = await peekStreamHead(
      response.body,
      kMediaSniffLength,
    );
    final Uint8List headBytes = head.bytes;
    if (headBytes.isEmpty) {
      throw const HttpException('Empty response body');
    }
    final SniffedMedia sniffed = sniffMediaHead(headBytes);
    if (sniffed != SniffedMedia.video) {
      await head.discard();
      throw nonVideoRejection(sniffed, url);
    }
    return head.body;
  }

  Future<void> _rememberSource(EpisodeHttpResponse response, int? total) async {
    final Mp4SourceFingerprint source = Mp4SourceFingerprint(
      totalBytes: total,
      etag: response.header('etag'),
      lastModified: response.header('last-modified'),
    );
    _source = source;
    await writeMp4SourceFingerprint(dir, source);
  }

  int? _totalFromLength(EpisodeHttpResponse response, int start) {
    final int? length = response.contentLength;
    if (length == null) {
      return null;
    }
    return start + length;
  }

  void Function(int chunkLength) _chunkReporter(int start, int? total) {
    int downloaded = start;
    return (int chunkLength) {
      downloaded += chunkLength;
      onProgress?.call(downloaded, total ?? 0);
    };
  }

  Future<_Mp4Round> _roundAfterWrite(int? total) async {
    final int length = await _partLength();
    if (total == null) {
      if (length == 0) {
        throw const HttpException('Empty response body');
      }
      return _Mp4Round(complete: true, totalBytes: length);
    }
    if (length > total) {
      await _forgetPartialFile();
      throw HttpException('Downloaded $length bytes, expected $total');
    }
    return _Mp4Round(complete: length == total, totalBytes: total);
  }

  Future<_Mp4Round> _consumeUnsatisfiable(EpisodeHttpResponse response) async {
    await response.discard();
    final int existing = await _partLength();
    final int? servedTotal = ContentRange.parse(
      response.header('content-range'),
    )?.total;
    if (existing == 0) {
      throw const HttpException('Range not satisfiable for an empty file');
    }
    final int? storedTotal = _source?.totalBytes;
    final bool servedMatches = servedTotal == null || servedTotal == existing;
    final bool storedMatches = storedTotal == null || storedTotal == existing;
    if (servedMatches && storedMatches) {
      return _Mp4Round(complete: true, totalBytes: existing);
    }
    await _forgetPartialFile();
    throw HttpException(
      'Partial file of $existing bytes does not match '
      '${servedTotal ?? storedTotal} bytes',
    );
  }

  Future<void> _truncatePart(int length) async {
    final RandomAccessFile handle = await _part.open(mode: FileMode.append);
    try {
      await handle.truncate(length);
    } finally {
      await handle.close();
    }
  }
}
