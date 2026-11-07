import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';

class WebViewUserAgent {
  WebViewUserAgent._();

  static const String fallback =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36';

  static const Duration _resolveTimeout = Duration(seconds: 3);

  static final RegExp _webViewToken = RegExp(r';\s*wv(?=[;)])');
  static final RegExp _buildToken = RegExp(r'\s+Build/[^;)]*');
  static final RegExp _versionToken = RegExp(r'\s*\bVersion/[\d.]+');
  static final RegExp _repeatedSpaces = RegExp(r'\s{2,}');

  static String? _resolved;

  static String get current => _resolved ?? fallback;

  static bool get isResolved => _resolved != null;

  static Future<void> resolve() async {
    if (_resolved != null) {
      return;
    }
    try {
      final String raw = await InAppWebViewController.getDefaultUserAgent()
          .timeout(_resolveTimeout);
      final String? normalized = normalize(raw);
      if (normalized == null) {
        logger.w('Unusable webview user agent: $raw');
        return;
      }
      _resolved = normalized;
      logger.i('Resolved webview user agent: $normalized');
    } catch (e) {
      logger.w('Failed to resolve webview user agent: $e');
    }
  }

  static String? normalize(String raw) {
    final String trimmed = raw.trim();
    if (!trimmed.contains('Chrome/') || !trimmed.startsWith('Mozilla/')) {
      return null;
    }
    return trimmed
        .replaceAll(_webViewToken, '')
        .replaceAll(_buildToken, '')
        .replaceAll(_versionToken, '')
        .replaceAll(_repeatedSpaces, ' ')
        .trim();
  }

  @visibleForTesting
  static void overrideResolved(String? userAgent) {
    _resolved = userAgent;
  }
}
