import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capyscript/modules/http/http_interceptor_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/utils/browser.dart';
import 'package:wakaranai/utils/browser_challenge_detector.dart';
import 'package:wakaranai/utils/document_readiness.dart';

part 'browser_interceptor_state.dart';

class BrowserInterceptorException implements Exception {
  final String message;

  const BrowserInterceptorException(this.message);

  @override
  String toString() => 'BrowserInterceptorException: $message';
}

class BrowserInterceptorCubit extends Cubit<BrowserInterceptorState>
    implements HttpInterceptorController {
  BrowserInterceptorCubit() : super(BrowserInterceptorInitial());

  static const int okStatusCode = 200;
  static const int challengeStatusCode = 403;
  static const int timeoutStatusCode = 408;
  static const int unavailableStatusCode = 0;

  static const Duration pageLoadTimeout = Duration(seconds: 28);
  static const Duration challengeWaitPerAttempt = Duration(seconds: 10);
  static const int maxChallengeReloads = 1;

  static const Duration _pageSettleDelay = Duration(milliseconds: 150);
  static const Duration _pageReadRetryDelay = Duration(milliseconds: 200);
  static const int _maxPageReadRetries = 3;
  static const Duration _jsSettleDelay = Duration(milliseconds: 250);
  static const Duration _jsRetryBaseDelay = Duration(milliseconds: 100);
  static const Duration _jsRetryMaxDelay = Duration(seconds: 1);
  static const int _maxJsAttempts = 20;
  static const String _documentHtmlScript =
      'return document.documentElement.innerHTML';

  InAppWebViewController? _inAppWebViewController;
  HeadlessInAppWebView? _headlessInAppWebView;
  Completer<bool>? _initCompleter;
  String? _pingUrl;

  BrowserInterceptorLoadingPage? _pendingLoad;
  Timer? _pendingLoadDeadline;
  Timer? _challengeTimer;
  int _challengeReloads = 0;
  int _pageReadRetries = 0;
  BrowserChallengeKind _lastChallengeKind = BrowserChallengeKind.none;
  String _lastChallengeBody = '';

  Future<void> init({
    required String url,
    required Completer<bool> initCompleter,
  }) async {
    logger.i("Init BrowserInterceptorCubit");
    _initCompleter = initCompleter;
    _pingUrl = url;
    _headlessInAppWebView = HeadlessInAppWebView(
      onLoadStart: _onLoadStart,
      initialSettings: getDefaultBrowserSettings(
        allowAlgorithmicDarkening: false,
      ),
      onWebViewCreated: _onWebViewCreated(url),
      onProgressChanged: _onProgressChanged,
      onLoadStop: (InAppWebViewController controller, WebUri? loadedUrl) async {
        await _onPageLoaded(loadedUrl, controller, url);
      },
    );
    try {
      await _headlessInAppWebView!.run();
    } catch (e) {
      logger.e('Failed to start the headless browser interceptor: $e');
      _emitIfOpen(
        BrowserInterceptorLoadFailed(
          url: url,
          reason: 'Headless webview failed to start: $e',
        ),
      );
      _completeInit(false);
    }
  }

  Future<void> _onPageLoaded(
    WebUri? loadedUrl,
    InAppWebViewController controller,
    String pingUrl,
  ) async {
    await Future<void>.delayed(_pageSettleDelay);
    logger.d("onLoadStop: $loadedUrl");
    if (isClosed) {
      return;
    }

    await DocumentReadiness.waitFor(controller);

    final String? html = await _readDocumentHtml(controller);
    if (isClosed) {
      return;
    }
    if (html == null) {
      _retryUnreadablePage();
      return;
    }

    final BrowserChallengeKind challenge = BrowserChallengeDetector.detect(
      html,
    );
    if (challenge != BrowserChallengeKind.none) {
      _onChallengeDetected(challenge, html);
      return;
    }

    await _onChallengeFreePage(
      html: html,
      controller: controller,
      pingUrl: pingUrl,
    );
  }

  Future<void> _onChallengeFreePage({
    required String html,
    required InAppWebViewController controller,
    required String pingUrl,
  }) async {
    _cancelChallengeTimer();
    final Map<String, String> headers = <String, String>{};
    final Map<String, String> cookies = <String, String>{};
    await getHeaders(
      done: (Map<String, String> pageHeaders, Map<String, String> pageCookies) {
        headers.addAll(pageHeaders);
        cookies.addAll(pageCookies);
      },
      pingUrl: pingUrl,
      controller: controller,
    );

    pageLoaded(body: html, data: headers, headers: headers, cookies: cookies);
  }

  Future<String?> _readDocumentHtml(InAppWebViewController controller) async {
    try {
      final CallAsyncJavaScriptResult? result = await controller
          .callAsyncJavaScript(functionBody: _documentHtmlScript);
      if (result == null || result.error != null) {
        logger.w('Failed to read page content: ${result?.error}');
        return null;
      }
      final dynamic value = result.value;
      if (value is String) {
        return value;
      }
      return null;
    } catch (e) {
      logger.w('Failed to read page content: $e');
      return null;
    }
  }

  void _retryUnreadablePage() {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    if (pending == null) {
      return;
    }
    if (_pageReadRetries >= _maxPageReadRetries) {
      _failPendingLoad(
        statusCode: unavailableStatusCode,
        reason: 'Page content could not be read',
      );
      return;
    }
    _pageReadRetries++;
    unawaited(
      Future<void>.delayed(_pageReadRetryDelay, () {
        if (identical(_pendingLoad, pending)) {
          retryLoadPage();
        }
      }),
    );
  }

  void _onChallengeDetected(BrowserChallengeKind kind, String html) {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    if (pending == null) {
      logger.w('Browser challenge ($kind) detected outside of a page request');
      return;
    }
    logger.i('Browser challenge ($kind) detected on ${pending.url}');
    _lastChallengeKind = kind;
    _lastChallengeBody = html;
    if (_challengeTimer != null) {
      return;
    }
    _challengeTimer = Timer(challengeWaitPerAttempt, () {
      unawaited(_onChallengeWaitElapsed(pending));
    });
  }

  Future<void> _onChallengeWaitElapsed(
    BrowserInterceptorLoadingPage pending,
  ) async {
    _challengeTimer = null;
    if (isClosed || !identical(_pendingLoad, pending)) {
      return;
    }

    final InAppWebViewController? controller = _inAppWebViewController;
    if (controller != null) {
      final String? html = await _readDocumentHtml(controller);
      if (!identical(_pendingLoad, pending)) {
        return;
      }
      if (html != null && !BrowserChallengeDetector.isChallenge(html)) {
        await _onChallengeFreePage(
          html: html,
          controller: controller,
          pingUrl: _pingUrl ?? pending.url,
        );
        return;
      }
    }

    if (_challengeReloads < maxChallengeReloads) {
      _challengeReloads++;
      logger.i(
        'Challenge still present on ${pending.url}, reloading ($_challengeReloads/$maxChallengeReloads)',
      );
      retryLoadPage();
      return;
    }
    _reportChallengeRequired();
  }

  void _reportChallengeRequired() {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    if (pending == null) {
      return;
    }
    BrowserChallengeKind kind = _lastChallengeKind;
    if (kind == BrowserChallengeKind.none) {
      kind = BrowserChallengeKind.cloudflare;
    }
    logger.w('Browser challenge ($kind) did not clear on ${pending.url}');
    final String body = _lastChallengeBody;
    _emitIfOpen(
      BrowserInterceptorChallengeRequired(url: pending.url, kind: kind),
    );
    _resolvePendingLoad(_response(statusCode: challengeStatusCode, body: body));
  }

  void _onPendingLoadDeadline(BrowserInterceptorLoadingPage pending) {
    if (!identical(_pendingLoad, pending)) {
      return;
    }
    if (_lastChallengeKind != BrowserChallengeKind.none) {
      _reportChallengeRequired();
      return;
    }
    _failPendingLoad(
      statusCode: timeoutStatusCode,
      reason: 'Page did not load within ${pageLoadTimeout.inSeconds}s',
    );
  }

  void _failPendingLoad({required int statusCode, required String reason}) {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    if (pending == null) {
      return;
    }
    logger.w('Browser interceptor failed to load ${pending.url}: $reason');
    _emitIfOpen(BrowserInterceptorLoadFailed(url: pending.url, reason: reason));
    _resolvePendingLoad(_response(statusCode: statusCode, body: ''));
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    logger.d("progress: $progress");
  }

  void Function(InAppWebViewController controller) _onWebViewCreated(
    String url,
  ) {
    return (InAppWebViewController controller) {
      _inAppWebViewController = controller;
      if (isClosed) {
        return;
      }
      unawaited(loadPage(url: url).then(_onInitialPageLoaded));
    };
  }

  void _onInitialPageLoaded(HttpInterceptorControllerResponse response) {
    final bool succeeded = response.statusCode == okStatusCode;
    if (succeeded) {
      _emitIfOpen(BrowserInterceptorInitialized());
    }
    _completeInit(succeeded);
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    logger.d("onLoadStart: $url");
  }

  void pageLoaded({
    required String body,
    required Map<String, dynamic> data,
    required Map<String, String> headers,
    required Map<String, String> cookies,
  }) {
    _resolvePendingLoad(
      HttpInterceptorControllerResponse(
        body: body,
        data: data,
        statusCode: okStatusCode,
        headers: headers,
        cookies: cookies,
      ),
    );
    _emitIfOpen(BrowserInterceptorPageLoaded(body: body, data: data));
  }

  @override
  Future<HttpInterceptorControllerResponse> loadPage({
    required String url,
    String? method,
    Map<String, String>? headers,
    String? body,
  }) async {
    if (isClosed) {
      throw const BrowserInterceptorException(
        'Browser interceptor is already closed',
      );
    }

    final Completer<HttpInterceptorControllerResponse> completer =
        Completer<HttpInterceptorControllerResponse>();

    final BrowserInterceptorLoadingPage? superseded = _pendingLoad;
    _clearPendingLoad();
    if (superseded != null && !superseded.onLoaded.isCompleted) {
      superseded.onLoaded.complete(completer.future);
    }

    final BrowserInterceptorLoadingPage pending = BrowserInterceptorLoadingPage(
      url: url,
      onLoaded: completer,
      headers: headers,
      method: method,
      body: body,
    );
    _pendingLoad = pending;
    _pendingLoadDeadline = Timer(
      pageLoadTimeout,
      () => _onPendingLoadDeadline(pending),
    );

    emit(pending);
    _navigate(pending);

    return completer.future;
  }

  void retryLoadPage() {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    if (pending == null || isClosed) {
      return;
    }
    _navigate(pending);
  }

  void _navigate(BrowserInterceptorLoadingPage request) {
    final InAppWebViewController? controller = _inAppWebViewController;
    if (controller == null) {
      logger.w('Browser interceptor has no webview yet for ${request.url}');
      return;
    }
    final String? requestBody = request.body;
    Uint8List? encodedBody;
    if (requestBody != null) {
      encodedBody = Uint8List.fromList(utf8.encode(requestBody));
    }
    unawaited(
      controller
          .loadUrl(
            urlRequest: URLRequest(
              url: WebUri(request.url),
              method: request.method,
              body: encodedBody,
              headers: request.headers,
            ),
          )
          .catchError((Object e) {
            logger.w(
              'Browser interceptor failed to navigate to ${request.url}: $e',
            );
          }),
    );
  }

  @override
  Future<dynamic> executeJsScript(String code) async {
    await Future<void>.delayed(_jsSettleDelay);
    await DocumentReadiness.waitFor(_requireController());

    Object? lastError;
    for (int attempt = 1; attempt <= _maxJsAttempts; attempt++) {
      final InAppWebViewController controller = _requireController();
      try {
        final CallAsyncJavaScriptResult? result = await controller
            .callAsyncJavaScript(functionBody: code);
        if (result != null && result.error == null && result.value != null) {
          return result.value;
        }
        lastError = result?.error;
      } catch (e) {
        lastError = e;
      }
      await Future<void>.delayed(_jsRetryDelay(attempt));
    }

    if (lastError != null) {
      throw BrowserInterceptorException(
        'executeJsScript failed after $_maxJsAttempts attempts: $lastError',
      );
    }
    logger.w(
      'executeJsScript returned no value after $_maxJsAttempts attempts',
    );
    return null;
  }

  InAppWebViewController _requireController() {
    final InAppWebViewController? controller = _inAppWebViewController;
    if (isClosed || controller == null) {
      throw const BrowserInterceptorException(
        'Browser interceptor webview is not available',
      );
    }
    return controller;
  }

  Duration _jsRetryDelay(int attempt) {
    final int delayMs = min(
      _jsRetryBaseDelay.inMilliseconds * attempt,
      _jsRetryMaxDelay.inMilliseconds,
    );
    return Duration(milliseconds: delayMs);
  }

  HttpInterceptorControllerResponse _response({
    required int statusCode,
    required String body,
  }) {
    return HttpInterceptorControllerResponse(
      body: body,
      data: <String, dynamic>{},
      statusCode: statusCode,
      headers: <String, String>{},
      cookies: <String, String>{},
    );
  }

  void _resolvePendingLoad(HttpInterceptorControllerResponse response) {
    final BrowserInterceptorLoadingPage? pending = _pendingLoad;
    _clearPendingLoad();
    if (pending != null && !pending.onLoaded.isCompleted) {
      pending.onLoaded.complete(response);
    }
  }

  void _clearPendingLoad() {
    _pendingLoad = null;
    _pendingLoadDeadline?.cancel();
    _pendingLoadDeadline = null;
    _cancelChallengeTimer();
    _challengeReloads = 0;
    _pageReadRetries = 0;
    _lastChallengeKind = BrowserChallengeKind.none;
    _lastChallengeBody = '';
  }

  void _cancelChallengeTimer() {
    _challengeTimer?.cancel();
    _challengeTimer = null;
  }

  void _completeInit(bool succeeded) {
    final Completer<bool>? completer = _initCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(succeeded);
    }
  }

  void _emitIfOpen(BrowserInterceptorState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() async {
    _resolvePendingLoad(_response(statusCode: unavailableStatusCode, body: ''));
    _completeInit(false);
    final HeadlessInAppWebView? headless = _headlessInAppWebView;
    _headlessInAppWebView = null;
    _inAppWebViewController = null;
    try {
      await headless?.dispose();
    } catch (e) {
      logger.w('Failed to dispose the headless browser interceptor: $e');
    }
    return super.close();
  }
}
