import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_page.dart';

void main() {
  test('attribute escaping covers every html-significant character', () {
    expect(
      escapeHtmlAttribute('a&b"c\'d<e>f'),
      'a&amp;b&quot;c&#39;d&lt;e&gt;f',
    );
    expect(escapeHtmlAttribute('&amp;'), '&amp;amp;');
  });

  test('a valid source becomes an escaped iframe on its own origin', () {
    final AnimeIframePage page = buildAnimeIframePage(
      ' https://player.example.com:8443/embed/42?a=1&b=2 ',
    )!;

    expect(page.baseUrl.toString(), 'https://player.example.com:8443/');
    expect(
      page.html,
      contains(
        '<iframe src="https://player.example.com:8443/embed/42?a=1&amp;b=2" '
        'allow="autoplay; fullscreen; encrypted-media; picture-in-picture" '
        'allowfullscreen></iframe>',
      ),
    );
  });

  test('quotes and markup in the source cannot break out of the attribute', () {
    final AnimeIframePage page = buildAnimeIframePage(
      'https://example.com/v?x="><script>alert(1)</script>&y=\'z\'',
    )!;

    expect(page.html, isNot(contains('<script>')));
    expect(page.html, isNot(contains('"><')));
    expect(page.html, isNot(contains("'z'")));
    final RegExpMatch srcAttribute = RegExp(
      r'<iframe src="([^"]*)"',
    ).firstMatch(page.html)!;
    expect(srcAttribute.group(1), isNot(contains('<')));
    expect(srcAttribute.group(1), isNot(contains('>')));
  });

  test('a protocol-relative source is treated as https', () {
    final AnimeIframePage page = buildAnimeIframePage(
      '//cdn.example.org/embed/1',
    )!;

    expect(page.source.toString(), 'https://cdn.example.org/embed/1');
    expect(page.baseUrl.toString(), 'https://cdn.example.org/');
  });

  test('sources that are not http(s) urls are rejected', () {
    const List<String> invalidSources = <String>[
      '',
      '   ',
      'not a url',
      'javascript:alert(1)',
      'file:///sdcard/video.html',
      'data:text/html,<p>hi</p>',
      'ftp://example.com/video',
      'https://',
      '/relative/embed/1',
      'http://[::1',
    ];

    for (final String source in invalidSources) {
      expect(buildAnimeIframePage(source), isNull, reason: source);
    }
  });
}
