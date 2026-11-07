enum BrowserChallengeKind { none, cloudflare, cloudflareTurnstile, ddosGuard }

class BrowserChallengeDetector {
  const BrowserChallengeDetector._();

  static const List<String> _cloudflareTitles = <String>[
    'just a moment',
    'attention required! | cloudflare',
  ];

  static const List<String> _cloudflareMarkers = <String>[
    'cf_chl_',
    'orchestrate/chl_page',
    'orchestrate/managed',
    'orchestrate/jsch',
    'cf-browser-verification',
    'cf-challenge-running',
    'checking your browser',
  ];

  static const List<String> _ddosGuardTitles = <String>['ddos-guard'];

  static const List<String> _ddosGuardMarkers = <String>[
    'check.ddos-guard.net',
    '/.well-known/ddos-guard/check',
    'ddg-l10n',
    'ddg-captcha',
    'ddos-guard/js-challenge',
  ];

  static const int _maxLinksOnChallengePage = 5;

  static final RegExp _titlePattern = RegExp(
    r'<title[^>]*>([\s\S]*?)</title>',
    caseSensitive: false,
  );
  static final RegExp _turnstileFramePattern = RegExp(
    r'''<iframe[^>]+src\s*=\s*["']https?://challenges\.cloudflare\.com''',
    caseSensitive: false,
  );
  static final RegExp _anchorPattern = RegExp(r'<a\s', caseSensitive: false);

  static BrowserChallengeKind detect(String html) {
    final String lowerHtml = html.toLowerCase();
    final String title = _titleOf(lowerHtml);

    if (_containsAny(title, _ddosGuardTitles) ||
        _containsAny(lowerHtml, _ddosGuardMarkers)) {
      return BrowserChallengeKind.ddosGuard;
    }
    if (_startsWithAny(title, _cloudflareTitles) ||
        _containsAny(lowerHtml, _cloudflareMarkers)) {
      return BrowserChallengeKind.cloudflare;
    }
    if (_hasStandaloneTurnstile(html)) {
      return BrowserChallengeKind.cloudflareTurnstile;
    }
    return BrowserChallengeKind.none;
  }

  static bool isChallenge(String html) {
    return detect(html) != BrowserChallengeKind.none;
  }

  static String _titleOf(String lowerHtml) {
    final RegExpMatch? match = _titlePattern.firstMatch(lowerHtml);
    if (match == null) {
      return '';
    }
    return (match.group(1) ?? '').trim();
  }

  static bool _hasStandaloneTurnstile(String html) {
    if (!_turnstileFramePattern.hasMatch(html)) {
      return false;
    }
    return _anchorPattern.allMatches(html).length < _maxLinksOnChallengePage;
  }

  static bool _containsAny(String haystack, List<String> needles) {
    if (haystack.isEmpty) {
      return false;
    }
    return needles.any(haystack.contains);
  }

  static bool _startsWithAny(String haystack, List<String> prefixes) {
    if (haystack.isEmpty) {
      return false;
    }
    return prefixes.any(haystack.startsWith);
  }
}

bool isSameSiteAsPing(String url, String? pingUrl) {
  if (pingUrl == null) {
    return true;
  }
  final String? challengedHost = Uri.tryParse(url)?.host.toLowerCase();
  final String? pingHost = Uri.tryParse(pingUrl)?.host.toLowerCase();
  if (challengedHost == null ||
      pingHost == null ||
      challengedHost.isEmpty ||
      pingHost.isEmpty) {
    return true;
  }
  return challengedHost == pingHost ||
      challengedHost.endsWith('.$pingHost') ||
      pingHost.endsWith('.$challengedHost');
}
