class DownloadEstimate {
  const DownloadEstimate({
    required this.bytesPerSecond,
    required this.remaining,
  });

  final double bytesPerSecond;
  final Duration remaining;
}

class DownloadRate {
  DownloadRate({
    required this.totalBytes,
    DateTime Function()? clock,
    this.window = const Duration(seconds: 20),
  }) : _clock = clock ?? DateTime.now;

  final int totalBytes;
  final Duration window;
  final DateTime Function() _clock;
  final List<({DateTime time, int bytes})> _samples =
      <({DateTime time, int bytes})>[];

  static const Duration _minimumSpan = Duration(seconds: 2);

  void record(int downloadedBytes) {
    final DateTime now = _clock();
    _samples.add((time: now, bytes: downloadedBytes));
    final DateTime oldestKept = now.subtract(window);
    while (_samples.length > 2 && _samples.first.time.isBefore(oldestKept)) {
      _samples.removeAt(0);
    }
  }

  DownloadEstimate? get estimate {
    if (_samples.length < 2) {
      return null;
    }
    final ({DateTime time, int bytes}) first = _samples.first;
    final ({DateTime time, int bytes}) last = _samples.last;
    final Duration span = last.time.difference(first.time);
    final int downloaded = last.bytes - first.bytes;
    if (span < _minimumSpan || downloaded <= 0) {
      return null;
    }
    final double bytesPerSecond =
        downloaded / (span.inMilliseconds / Duration.millisecondsPerSecond);
    final int remainingBytes = (totalBytes - last.bytes).clamp(0, totalBytes);
    final int remainingSeconds = (remainingBytes / bytesPerSecond).ceil();
    return DownloadEstimate(
      bytesPerSecond: bytesPerSecond,
      remaining: Duration(seconds: remainingSeconds),
    );
  }
}
