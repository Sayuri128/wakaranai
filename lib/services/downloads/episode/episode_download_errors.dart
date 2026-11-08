class EpisodeSourceExpired implements Exception {
  const EpisodeSourceExpired({required this.url, required this.statusCode});

  final String url;
  final int statusCode;

  @override
  String toString() => 'EpisodeSourceExpired($statusCode, $url)';
}

class UnsupportedEpisodeDownload implements Exception {
  const UnsupportedEpisodeDownload(this.reason);

  final String reason;

  @override
  String toString() => 'UnsupportedEpisodeDownload: $reason';
}

class EpisodeDownloadFailure implements Exception {
  const EpisodeDownloadFailure({required this.url, this.cause});

  final String url;
  final Object? cause;

  @override
  String toString() => 'EpisodeDownloadFailure($url): $cause';
}
