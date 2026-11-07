import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/browser_challenge_detector.dart';

void main() {
  group('BrowserChallengeDetector', () {
    test('detects the Cloudflare interstitial by its title', () {
      const String html =
          '<head><title>Just a moment...</title></head><body></body>';

      expect(
        BrowserChallengeDetector.detect(html),
        BrowserChallengeKind.cloudflare,
      );
    });

    test('detects a localized Cloudflare interstitial by its options', () {
      const String html =
          '<head><title>Один момент…</title></head>'
          '<body><script>window._cf_chl_opt={cvId:"3"};</script></body>';

      expect(
        BrowserChallengeDetector.detect(html),
        BrowserChallengeKind.cloudflare,
      );
    });

    test('detects the managed challenge orchestrator script', () {
      const String html =
          '<script src="/cdn-cgi/challenge-platform/h/b/'
          'orchestrate/chl_page/v1?ray=abc"></script>';

      expect(BrowserChallengeDetector.isChallenge(html), isTrue);
    });

    test('detects the legacy browser check text', () {
      const String html =
          '<body><h1>Checking your browser before accessing</h1></body>';

      expect(BrowserChallengeDetector.isChallenge(html), isTrue);
    });

    test('detects a standalone Turnstile iframe', () {
      const String html =
          '<body><div><iframe '
          'src="https://challenges.cloudflare.com/cdn-cgi/challenge-platform/'
          'h/b/turnstile/if/ov2/av0/rcv0/0/x" title="Widget"></iframe></div>'
          '</body>';

      expect(
        BrowserChallengeDetector.detect(html),
        BrowserChallengeKind.cloudflareTurnstile,
      );
    });

    test('ignores a Turnstile widget embedded in a link-rich page', () {
      final String links = List<String>.generate(
        12,
        (int index) => '<a href="/title/$index">Title $index</a>',
      ).join();
      final String html =
          '<head><title>Catalog</title></head><body>$links'
          '<iframe src="https://challenges.cloudflare.com/turnstile/x">'
          '</iframe></body>';

      expect(BrowserChallengeDetector.detect(html), BrowserChallengeKind.none);
    });

    test('detects the DDoS-Guard splash page', () {
      const String html =
          '<head><title>DDoS-Guard</title></head>'
          '<body><div id="ddg-l10n-title"></div></body>';

      expect(
        BrowserChallengeDetector.detect(html),
        BrowserChallengeKind.ddosGuard,
      );
    });

    test('detects the DDoS-Guard check script without a title', () {
      const String html =
          '<script src="/.well-known/ddos-guard/check?context=free_splash">'
          '</script>';

      expect(
        BrowserChallengeDetector.detect(html),
        BrowserChallengeKind.ddosGuard,
      );
    });

    test('does not flag a regular page behind Cloudflare', () {
      const String html =
          '<head><title>Latest manga</title></head><body>'
          '<script>window.__CF\$cv\$params={r:"abc"};</script>'
          '<script src="/cdn-cgi/challenge-platform/scripts/jsd/main.js">'
          '</script><a href="/manga/1">One</a></body>';

      expect(BrowserChallengeDetector.isChallenge(html), isFalse);
    });

    test('does not flag a page that merely mentions a moment', () {
      const String html =
          '<head><title>Wait for it</title></head>'
          '<body><p>Just a moment of silence.</p></body>';

      expect(BrowserChallengeDetector.isChallenge(html), isFalse);
    });

    test('does not flag an empty document', () {
      expect(BrowserChallengeDetector.isChallenge(''), isFalse);
    });
  });
}
