class AnimeIframePage {
  const AnimeIframePage({
    required this.source,
    required this.baseUrl,
    required this.html,
  });

  final Uri source;
  final Uri baseUrl;
  final String html;
}

const String animeIframeAllowedFeatures =
    'autoplay; fullscreen; encrypted-media; picture-in-picture';

AnimeIframePage? buildAnimeIframePage(String rawSource) {
  final Uri? source = parseAnimeIframeSource(rawSource);
  if (source == null) {
    return null;
  }
  return AnimeIframePage(
    source: source,
    baseUrl: Uri.parse('${source.origin}/'),
    html: _buildHtml(source),
  );
}

Uri? parseAnimeIframeSource(String rawSource) {
  final String trimmedSource = rawSource.trim();
  if (trimmedSource.isEmpty) {
    return null;
  }
  final String absoluteSource = trimmedSource.startsWith('//')
      ? 'https:$trimmedSource'
      : trimmedSource;
  final Uri? source = Uri.tryParse(absoluteSource);
  if (source == null) {
    return null;
  }
  if (source.scheme != 'http' && source.scheme != 'https') {
    return null;
  }
  if (source.host.isEmpty) {
    return null;
  }
  return source;
}

String escapeHtmlAttribute(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

String _buildHtml(Uri source) {
  final String escapedSource = escapeHtmlAttribute(source.toString());
  return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: #000; }
iframe { display: block; border: 0; width: 100%; height: 100%; }
</style>
</head>
<body>
<iframe src="$escapedSource" allow="$animeIframeAllowedFeatures" allowfullscreen></iframe>
</body>
</html>
''';
}
