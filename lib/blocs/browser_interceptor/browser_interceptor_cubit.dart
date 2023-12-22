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

  Future<void> init(
      {required String url, required Completer<bool> initCompleter}) async {
    logger.i("Init BrowserInterceptorCubit");
    _headlessInAppWebView = HeadlessInAppWebView(
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.CANCEL;
        },
        onLoadStart: (controller, url) {
          // print("onLoadStart: $url");
        },
        initialOptions: getDefaultBrowserOption(),
        onWebViewCreated: ((controller) {
          _inAppWebViewController = controller;

          loadPage(url: url).then((value) {
            emit(BrowserInterceptorInitialized());
          });
        }),
        onLoadStop: (controller, loadedUrl) async {
          await Future.delayed(const Duration(milliseconds: 150));

          final result = await controller.callAsyncJavaScript(
              functionBody: 'return document.documentElement.innerHTML');

          if (result == null || result.error != null) {
            Future.delayed(const Duration(milliseconds: 200), () {
              retryLoadPage();
            });
            return;
          }

          if (!result.value.contains("Just a moment...")) {
            Map<String, dynamic> data = {};
            await getHeaders(
                done: (h) {
                  data.addAll(h);
                },
                pingUrl: url,
                controller: _inAppWebViewController);

            logger.i(data);

            pageLoaded(body: result.value, data: data);

            try {
              initCompleter.complete(true);
            } catch (_) {}
          }
        });
    await _headlessInAppWebView.run();
  }

  void pageLoaded(
      {required String body, required Map<String, dynamic> data}) async {
    if (state is BrowserInterceptorLoadingPage) {
      (state as BrowserInterceptorLoadingPage).onLoaded.complete(
          HttpInterceptorControllerResponse(
              body: body,
              data: data,
              statusCode: 200,
              headers: {},
              cookies: {}));
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

    _inAppWebViewController.loadUrl(
        urlRequest: URLRequest(
            url: Uri.parse(url),
            method: method,
            body: body != null ? Uint8List.fromList(utf8.encode(body)) : null,
            headers: headers));

    emit(BrowserInterceptorLoadingPage(
        url: url,
        onLoaded: completer,
        headers: headers,
        method: method,
        body: body));

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
    if (this.isClosed || _jsAttempts > 10) {
      _jsAttempts = 0;
      return;
    }
    await Future.delayed(const Duration(milliseconds: 150));
    final res =
        await _inAppWebViewController.callAsyncJavaScript(functionBody: code);

    logger.d(res);

    if (res == null || res.error != null || res.value == null) {
      _jsAttempts++;
      await Future.delayed(const Duration(milliseconds: 400));
      return await executeJsScript(code);
    }

    return res.value;
  }

  @override
  Future<void> close() {
    _headlessInAppWebView.dispose();
    return super.close();
  }
}
