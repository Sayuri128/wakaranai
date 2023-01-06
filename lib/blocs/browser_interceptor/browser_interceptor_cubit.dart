import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:meta/meta.dart';
import 'package:wakascript/inbuilt_libs/http/http_interceptor_controller.dart';

part 'browser_interceptor_state.dart';

class BrowserInterceptorCubit extends Cubit<BrowserInterceptorState>
    implements HttpInterceptorController {
  BrowserInterceptorCubit() : super(BrowserInterceptorInitial());

  late final InAppWebViewController _inAppWebViewController;

  Future<void> init(
      {required String url,
      required InAppWebViewController webViewController}) async {
    _inAppWebViewController = webViewController;
    await loadPage(url: url);
    emit(BrowserInterceptorInitialized());
  }

  void pageLoaded(
      {required String body, required Map<String, dynamic> data}) async {
    if (state is BrowserInterceptorLoadingPage) {
      (state as BrowserInterceptorLoadingPage)
          .onLoaded
          .complete(HttpInterceptorControllerResponse(body: body, data: data));
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

  @override
  Future<dynamic> executeJsScript(String code) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final res =
        await _inAppWebViewController.callAsyncJavaScript(functionBody: code);

    if (res == null || res.error != null || res.value == null) {
      return await executeJsScript(code);
    }

    return res.value;
  }
}
