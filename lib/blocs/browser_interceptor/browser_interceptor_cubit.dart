import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:capyscript/modules/http/http_interceptor_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/utils/browser.dart';

part 'browser_interceptor_state.dart';

class BrowserInterceptorCubit extends Cubit<BrowserInterceptorState>
    implements HttpInterceptorController {
  BrowserInterceptorCubit() : super(BrowserInterceptorInitial());

  late final InAppWebViewController _inAppWebViewController;
  late final HeadlessInAppWebView _headlessInAppWebView;

  Future<void> init({
    required String url,
    required Completer<bool> initCompleter,
  }) async {
    logger.i("Init BrowserInterceptorCubit");
    _headlessInAppWebView = HeadlessInAppWebView(
        onLoadStart: _onLoadStart,
        initialSettings: getDefaultBrowserSettings(),
        onWebViewCreated: _onWebViewCreated(url),
        onProgressChanged: _onProgressChanged,
        onUpdateVisitedHistory: (controller, loadedUrl, androidIsReload) async {
          await _onPageLoaded(loadedUrl, controller, url, initCompleter);
        },
        onLoadStop: (controller, loadedUrl) async {
          await _onPageLoaded(loadedUrl, controller, url, initCompleter);
        });
    await _headlessInAppWebView.run();
  }

  Future<void> _onPageLoaded(
      WebUri? loadedUrl,
      InAppWebViewController controller,
      String url,
      Completer<bool> initCompleter) async {
    await Future.delayed(const Duration(milliseconds: 150));

    print("onLoadStop: $loadedUrl");

    final result = await controller.callAsyncJavaScript(
        functionBody: 'return document.documentElement.innerHTML');

    if (result == null || result.error != null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        retryLoadPage();
      });
    } else {
      if (!result.value.contains("Just a moment...")) {
        Map<String, String> data = {};
        Map<String, String> coo = {};
        await getHeaders(
            done: (h, cookie) {
              data.addAll(h);
              coo.addAll(cookie);
            },
            pingUrl: url,
            controller: _inAppWebViewController);

        logger.i(data);

        pageLoaded(body: result.value, data: data, headers: data, cookies: coo);

        try {
          initCompleter.complete(true);
        } catch (_) {}
      }
    }
  }

  void _onProgressChanged(controller, progress) {
    print("progress: $progress");
  }

  void Function(InAppWebViewController controller) _onWebViewCreated(
      String url) {
    return ((InAppWebViewController controller) {
      _inAppWebViewController = controller;

      loadPage(url: url).then((value) {
        emit(BrowserInterceptorInitialized());
      });
    });
  }

  void _onLoadStart(controller, url) {
    print("onLoadStart: $url");
  }

  void pageLoaded(
      {required String body,
      required Map<String, dynamic> data,
      required Map<String, String> headers,
      required Map<String, String> cookies}) async {
    if (state is BrowserInterceptorLoadingPage) {
      (state as BrowserInterceptorLoadingPage).onLoaded.complete(
          HttpInterceptorControllerResponse(
              body: body,
              data: data,
              statusCode: 200,
              headers: headers,
              cookies: cookies));
    }
    emit(BrowserInterceptorPageLoaded(body: body, data: data));
  }

  @override
  Future<HttpInterceptorControllerResponse> loadPage(
      {required String url,
      String? method,
      Map<String, String>? headers,
      String? body}) async {
    final completer = Completer<HttpInterceptorControllerResponse>();

    emit(
      BrowserInterceptorLoadingPage(
          url: url,
          onLoaded: completer,
          headers: headers,
          method: method,
          body: body),
    );

    _inAppWebViewController.loadUrl(
        urlRequest: URLRequest(
            url: WebUri(url),
            method: method,
            body: body != null ? Uint8List.fromList(utf8.encode(body)) : null,
            headers: headers));

    return completer.future;
  }

  void retryLoadPage() {
    if (state is BrowserInterceptorLoadingPage) {
      final loading = (state as BrowserInterceptorLoadingPage);
      loadPage(
          url: loading.url,
          headers: loading.headers,
          body: loading.body,
          method: loading.method);
    }
  }

  int _jsAttempts = 0;

  @override
  Future<dynamic> executeJsScript(String code) async {
    try {
      if (isClosed || _jsAttempts > 100) {
        _jsAttempts = 0;
        return;
      }
      await Future.delayed(const Duration(milliseconds: 250));
      final res =
          await _inAppWebViewController.callAsyncJavaScript(functionBody: code);

      logger.d(res);

      if (res == null || res.error != null || res.value == null) {
        _jsAttempts++;
        await Future.delayed(const Duration(milliseconds: 100));
        return await executeJsScript(code);
      }

      return res.value;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _headlessInAppWebView.dispose();
    return super.close();
  }
}
