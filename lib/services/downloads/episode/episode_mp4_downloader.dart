import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_plan.dart';
import 'package:wakaranai/services/downloads/episode/episode_fetcher.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/episode_http.dart';

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

  File get target => File(p.join(dir.path, kLocalMp4File));

  File get _part => partFileOf(target);

  Future<void> run() async {
    if (await target.exists()) {
      final int length = await target.length();
      onProgress?.call(length, length);
      return;
    }
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
    return <String, String>{...headers, 'Range': 'bytes=$existing-'};
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
    final int start = await _prepareStart(response, range, existing);
    final int? total = range?.total ?? _totalFromLength(response, start);
    await pipeStreamToFile(
      response.body,
      _part,
      cancelToken: fetcher.cancelToken,
      mode: start == 0 ? FileMode.write : FileMode.append,
      onChunk: _chunkReporter(start, total),
    );
    return _roundAfterWrite(total);
  }

  Future<int> _prepareStart(
    EpisodeHttpResponse response,
    ContentRange? range,
    int existing,
  ) async {
    if (response.statusCode != HttpStatus.partialContent) {
      return 0;
    }
    final int start = range?.start ?? existing;
    if (start > existing) {
      await response.discard();
      await deleteIfExists(_part);
      throw HttpException('Server resumed at $start, expected $existing');
    }
    if (start < existing) {
      await _truncatePart(start);
    }
    return start;
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
      await deleteIfExists(_part);
      throw HttpException('Downloaded $length bytes, expected $total');
    }
    return _Mp4Round(complete: length == total, totalBytes: total);
  }

  Future<_Mp4Round> _consumeUnsatisfiable(EpisodeHttpResponse response) async {
    await response.discard();
    final int existing = await _partLength();
    final int? total = ContentRange.parse(
      response.header('content-range'),
    )?.total;
    if (existing == 0) {
      throw const HttpException('Range not satisfiable for an empty file');
    }
    if (total == null || total == existing) {
      return _Mp4Round(complete: true, totalBytes: existing);
    }
    await deleteIfExists(_part);
    throw HttpException('Partial file of $existing bytes exceeds $total');
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
