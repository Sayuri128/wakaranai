import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/browser.dart';
import 'package:wakaranai/utils/document_readiness.dart';
import 'package:wakaranai/utils/webview_user_agent.dart';

void main() {
  tearDown(() => WebViewUserAgent.overrideResolved(null));

  group('WebViewUserAgent.normalize', () {
    test('strips the webview, build and version tokens', () {
      const String raw =
          'Mozilla/5.0 (Linux; Android 14; Pixel 7 '
          'Build/UQ1A.240205.004; wv) AppleWebKit/537.36 (KHTML, like Gecko) '
          'Version/4.0 Chrome/131.0.6778.135 Mobile Safari/537.36';

      expect(
        WebViewUserAgent.normalize(raw),
        'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/131.0.6778.135 Mobile Safari/537.36',
      );
    });

    test('handles the reduced user agent format', () {
      const String raw =
          'Mozilla/5.0 (Linux; Android 10; K; wv) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 '
          'Chrome/140.0.0.0 Mobile Safari/537.36';

      expect(
        WebViewUserAgent.normalize(raw),
        'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36',
      );
    });

    test('leaves a Chrome mobile user agent untouched', () {
      const String raw =
          'Mozilla/5.0 (Linux; Android 10; K) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 '
          'Mobile Safari/537.36';

      expect(WebViewUserAgent.normalize('  $raw  '), raw);
    });

    test('rejects strings that are not Chrome user agents', () {
      expect(WebViewUserAgent.normalize(''), isNull);
      expect(WebViewUserAgent.normalize('Dalvik/2.1.0 (Linux; U)'), isNull);
    });
  });

  group('WebViewUserAgent.current', () {
    test('falls back to a Chrome mobile user agent when unresolved', () {
      expect(WebViewUserAgent.isResolved, isFalse);
      expect(WebViewUserAgent.current, WebViewUserAgent.fallback);
      expect(WebViewUserAgent.current, contains('Mobile Safari'));
      expect(WebViewUserAgent.current, isNot(contains('; wv')));
    });

    test('is used by the default browser settings', () {
      WebViewUserAgent.overrideResolved('Mozilla/5.0 Test Chrome/1.0');

      final InAppWebViewSettings settings = getDefaultBrowserSettings();

      expect(settings.userAgent, 'Mozilla/5.0 Test Chrome/1.0');
      expect(
        settings.preferredContentMode,
        UserPreferredContentMode.RECOMMENDED,
      );
      expect(settings.algorithmicDarkeningAllowed, isTrue);
      expect(
        getDefaultBrowserSettings(
          allowAlgorithmicDarkening: false,
        ).algorithmicDarkeningAllowed,
        isFalse,
      );
    });
  });

  group('cookies', () {
    test('pingUrl cookies win over page cookies with the same name', () {
      final Map<String, String> merged = mergeCookies(
        primary: <String, String>{'cf_clearance': 'ping', 'session': 'a'},
        secondary: <String, String>{'cf_clearance': 'page', 'theme': 'dark'},
      );

      expect(merged, <String, String>{
        'cf_clearance': 'ping',
        'session': 'a',
        'theme': 'dark',
      });
    });

    test('formats a cookie header', () {
      expect(
        formatCookieHeader(<String, String>{'a': '1', 'b': '2'}),
        'a=1; b=2',
      );
      expect(formatCookieHeader(<String, String>{}), '');
    });

    test('collects page cookies only for a different host', () {
      expect(
        hasDifferentHost(
          pingUrl: 'https://site.org/ping',
          pageUrl: 'https://cdn.site.org/page',
        ),
        isTrue,
      );
      expect(
        hasDifferentHost(
          pingUrl: 'https://site.org/ping',
          pageUrl: 'https://SITE.org/other',
        ),
        isFalse,
      );
      expect(
        hasDifferentHost(pingUrl: 'https://site.org', pageUrl: null),
        isFalse,
      );
      expect(
        hasDifferentHost(pingUrl: 'https://site.org', pageUrl: 'about:blank'),
        isFalse,
      );
    });
  });

  group('DocumentReadiness.nextStep', () {
    test('is ready once the document is complete', () {
      expect(
        DocumentReadiness.nextStep(readyState: 'complete', polls: 0),
        DocumentReadinessStep.ready,
      );
    });

    test('settles after a few interactive polls', () {
      expect(
        DocumentReadiness.nextStep(readyState: 'interactive', polls: 2),
        DocumentReadinessStep.keepPolling,
      );
      expect(
        DocumentReadiness.nextStep(
          readyState: 'interactive',
          polls: DocumentReadiness.interactivePollsBeforeSettle + 1,
        ),
        DocumentReadinessStep.settleThenProceed,
      );
    });

    test('gives up after the poll limit', () {
      expect(
        DocumentReadiness.nextStep(
          readyState: 'loading',
          polls: DocumentReadiness.maxPolls,
        ),
        DocumentReadinessStep.keepPolling,
      );
      expect(
        DocumentReadiness.nextStep(
          readyState: 'loading',
          polls: DocumentReadiness.maxPolls + 1,
        ),
        DocumentReadinessStep.giveUp,
      );
    });
  });
}
