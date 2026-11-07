import 'dart:io';
import 'dart:math';

class DownloadThrottle {
  DownloadThrottle({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const Duration minimumPageDelay = Duration(milliseconds: 500);
  static const Duration maximumPageDelay = Duration(seconds: 8);
  static const Duration maximumRetryWait = Duration(seconds: 60);
  static const Duration _firstBackoff = Duration(seconds: 2);
  static const int _chapterDelayFactor = 4;

  final DateTime Function() _now;
  final Map<String, Duration> _configuredPageDelay = <String, Duration>{};
  final Map<String, Duration> _configuredChapterDelay = <String, Duration>{};
  final Map<String, Duration> _learnedPageDelay = <String, Duration>{};

  void configure(
    String extensionUid, {
    Duration pageDelay = Duration.zero,
    Duration chapterDelay = Duration.zero,
  }) {
    _configuredPageDelay[extensionUid] = pageDelay;
    _configuredChapterDelay[extensionUid] = chapterDelay;
  }

  Duration pageDelay(String extensionUid) {
    return _longer(
      _configuredPageDelay[extensionUid] ?? Duration.zero,
      _learnedPageDelay[extensionUid] ?? Duration.zero,
    );
  }

  Duration chapterDelay(String extensionUid) {
    final Duration learned =
        (_learnedPageDelay[extensionUid] ?? Duration.zero) *
            _chapterDelayFactor;
    return _longer(
      _configuredChapterDelay[extensionUid] ?? Duration.zero,
      learned,
    );
  }

  void rateLimited(String extensionUid) {
    final Duration current = _learnedPageDelay[extensionUid] ?? Duration.zero;
    final Duration doubled = _longer(current * 2, minimumPageDelay);
    _learnedPageDelay[extensionUid] =
        doubled > maximumPageDelay ? maximumPageDelay : doubled;
  }

  Duration retryWait(int rateLimitedAttempt, {String? retryAfterHeader}) {
    final Duration? requested = _parseRetryAfter(retryAfterHeader);
    if (requested != null) {
      return requested > maximumRetryWait ? maximumRetryWait : requested;
    }
    final int exponent = max(0, rateLimitedAttempt - 1);
    final Duration backoff = _firstBackoff * pow(2, exponent).toInt();
    return backoff > maximumRetryWait ? maximumRetryWait : backoff;
  }

  Duration? _parseRetryAfter(String? header) {
    final String? value = header?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final int? seconds = int.tryParse(value);
    if (seconds != null) {
      return Duration(seconds: max(0, seconds));
    }
    try {
      final Duration untilDate = HttpDate.parse(value).difference(_now());
      return untilDate.isNegative ? Duration.zero : untilDate;
    } on HttpException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Duration _longer(Duration a, Duration b) => a > b ? a : b;
}
