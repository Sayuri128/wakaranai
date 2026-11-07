class EpisodeDownloadProgress {
  const EpisodeDownloadProgress({
    required this.completedSegments,
    required this.totalSegments,
    required this.downloadedBytes,
    required this.totalBytes,
  });

  final int completedSegments;
  final int totalSegments;
  final int downloadedBytes;
  final int totalBytes;

  double? get fraction {
    if (totalSegments > 0) {
      return completedSegments / totalSegments;
    }
    if (totalBytes > 0) {
      return downloadedBytes / totalBytes;
    }
    return null;
  }

  @override
  String toString() {
    return 'EpisodeDownloadProgress($completedSegments/$totalSegments, '
        '$downloadedBytes/$totalBytes bytes)';
  }
}
