import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakascript/logger.dart';

class WebBrowserInterceptorWidget extends StatefulWidget {
  const WebBrowserInterceptorWidget(
      {Key? key, required this.initUrl, required this.initCompleter})
      : super(key: key);

  final Completer<bool> initCompleter;
  final String initUrl;

  @override
  State<WebBrowserInterceptorWidget> createState() =>
      _WebBrowserInterceptorWidgetState();
}

class _WebBrowserInterceptorWidgetState
    extends State<WebBrowserInterceptorWidget> {
  final GlobalKey _webViewKey = GlobalKey();

  late Future<InAppWebViewController> _webView;

  final Completer<InAppWebViewController> _webViewCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _webView = _webViewCompleter.future;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.read<BrowserInterceptorCubit>().state
          is BrowserInterceptorInitial) {
        _webView.then((value) {
          context
              .read<BrowserInterceptorCubit>()
              .init(url: widget.initUrl, webViewController: value);
        });
      } else {
        widget.initCompleter.complete(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrowserInterceptorCubit, BrowserInterceptorState>(
      listener: (context, state) {
        if (state is BrowserInterceptorLoadingPage) {
          logger.i("Loading page: ${state.url}");
          _webView.then((value) => value.loadUrl(
              urlRequest: URLRequest(
                  url: Uri.parse(state.url),
                  method: state.method,
                  body: state.body != null
                      ? Uint8List.fromList(utf8.encode(state.body!))
                      : null,
                  headers: state.headers)));
        } else if (state is BrowserInterceptorInitialized) {
          widget.initCompleter.complete(true);
          // context.read<ServiceViewCubit>().init();
        }
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            InAppWebView(
              key: _webViewKey,
              onLoadStart: (controller, url) {
                print("Load start: $url");
              },
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    preferredContentMode: UserPreferredContentMode.DESKTOP,
                    allowFileAccessFromFileURLs: true,
                    allowUniversalAccessFromFileURLs: true,
                    cacheEnabled: true
                  )),
              onWebViewCreated: (controller) async {
                _webViewCompleter.complete(controller);
              },
              onLoadStop: ((controller, url) async {
                await Future.delayed(const Duration(milliseconds: 150));

                final result = await controller.callAsyncJavaScript(
                    functionBody: 'return document.documentElement.innerHTML');

                if (result == null || result.error != null) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      context.read<BrowserInterceptorCubit>().retryLoadPage();
                    }
                  });
                  return;
                }

                if (!result.value.contains("Just a moment...")) {
                  Map<String, dynamic> data = {};
                  await getHeaders(
                      done: (h) {
                        data.addAll(h);
                      },
                      pingUrl: widget.initUrl,
                      controller: await _webView);

                  logger.i(data);

                  context
                      .read<BrowserInterceptorCubit>()
                      .pageLoaded(body: result.value, data: data);
                }
              }),
            )
          ],
        ),
      ),
    );
  }
}
