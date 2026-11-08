import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/utils/webview_user_agent.dart';

InAppWebViewSettings getDefaultBrowserSettings({
  bool allowAlgorithmicDarkening = true,
}) => InAppWebViewSettings(
  userAgent: WebViewUserAgent.current,
  javaScriptEnabled: true,
  preferredContentMode: UserPreferredContentMode.RECOMMENDED,
  mediaPlaybackRequiresUserGesture: true,
  javaScriptCanOpenWindowsAutomatically: true,
  cacheEnabled: true,
  useHybridComposition: true,
  supportMultipleWindows: true,
  cacheMode: CacheMode.LOAD_DEFAULT,
  databaseEnabled: true,
  scrollBarStyle: ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
  allowContentAccess: false,
  allowFileAccess: false,
  domStorageEnabled: true,
  clearSessionCache: false,
  algorithmicDarkeningAllowed: allowAlgorithmicDarkening,
  loadsImagesAutomatically: true,
  allowsInlineMediaPlayback: true,
);

const String _navigatorUserAgentScript = 'return navigator.userAgent;';

Future<void> getHeaders({
  required Function(Map<String, String> headers, Map<String, String> cookies)
  done,
  required String pingUrl,
  required InAppWebViewController controller,
}) async {
  final Map<String, String> pingCookies = await _cookiesFor(WebUri(pingUrl));
  final Map<String, String> pageCookies = await _loadedPageCookies(
    controller: controller,
    pingUrl: pingUrl,
  );
  final Map<String, String> cookies = mergeCookies(
    primary: pingCookies,
    secondary: pageCookies,
  );
  final String userAgent = await _navigatorUserAgent(controller);
  done(<String, String>{
    'user-agent': userAgent,
    'cookie': formatCookieHeader(cookies),
  }, cookies);
}

Map<String, String> mergeCookies({
  required Map<String, String> primary,
  required Map<String, String> secondary,
}) {
  return <String, String>{...secondary, ...primary};
}

String formatCookieHeader(Map<String, String> cookies) {
  return cookies.entries
      .map((MapEntry<String, String> cookie) => '${cookie.key}=${cookie.value}')
      .join('; ');
}

bool hasDifferentHost({required String pingUrl, required String? pageUrl}) {
  if (pageUrl == null || pageUrl.isEmpty) {
    return false;
  }
  final Uri? ping = Uri.tryParse(pingUrl);
  final Uri? page = Uri.tryParse(pageUrl);
  if (ping == null || page == null || page.host.isEmpty) {
    return false;
  }
  return ping.host.toLowerCase() != page.host.toLowerCase();
}

Future<Map<String, String>> _loadedPageCookies({
  required InAppWebViewController controller,
  required String pingUrl,
}) async {
  try {
    final WebUri? loadedUrl = await controller.getUrl();
    if (loadedUrl == null ||
        !hasDifferentHost(pingUrl: pingUrl, pageUrl: loadedUrl.toString())) {
      return <String, String>{};
    }
    return await _cookiesFor(loadedUrl);
  } catch (e) {
    logger.w('Failed to read cookies of the loaded page: $e');
    return <String, String>{};
  }
}

Future<Map<String, String>> _cookiesFor(WebUri url) async {
  try {
    final List<Cookie> cookies = await CookieManager.instance().getCookies(
      url: url,
    );
    return Map<String, String>.fromEntries(
      cookies.map(
        (Cookie cookie) => MapEntry(cookie.name, cookie.value.toString()),
      ),
    );
  } catch (e) {
    logger.w('Failed to read cookies for $url: $e');
    return <String, String>{};
  }
}

Future<String> _navigatorUserAgent(InAppWebViewController controller) async {
  try {
    final CallAsyncJavaScriptResult? result = await controller
        .callAsyncJavaScript(functionBody: _navigatorUserAgentScript);
    final dynamic userAgent = result?.value;
    if (userAgent is String && userAgent.isNotEmpty) {
      return userAgent;
    }
  } catch (e) {
    logger.w('Failed to read navigator.userAgent: $e');
  }
  return WebViewUserAgent.current;
}
