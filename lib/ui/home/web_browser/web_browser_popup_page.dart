import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/web_browser/web_browser_toolbar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class WebBrowserPopupPage extends StatefulWidget {
  const WebBrowserPopupPage({
    super.key,
    required this.windowId,
    required this.settings,
    this.initialUrl,
  });

  final int windowId;
  final InAppWebViewSettings settings;
  final WebUri? initialUrl;

  @override
  State<WebBrowserPopupPage> createState() => _WebBrowserPopupPageState();
}

class _WebBrowserPopupPageState extends State<WebBrowserPopupPage> {
  InAppWebViewController? _controller;
  WebUri? _currentUrl;
  bool _isLoading = true;
  double _progress = 0;
  bool _canGoBack = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
  }

  void _update(VoidCallback change) {
    if (!mounted) {
      return;
    }
    setState(change);
  }

  Future<void> _refreshHistoryState() async {
    final InAppWebViewController? controller = _controller;
    if (controller == null) {
      return;
    }
    final bool canGoBack = await controller.canGoBack();
    _update(() {
      _canGoBack = canGoBack;
    });
  }

  void _close() {
    if (_closed || !mounted) {
      return;
    }
    _closed = true;
    Navigator.of(context).pop();
  }

  void _handleSystemBack(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    final InAppWebViewController? controller = _controller;
    if (_canGoBack && controller != null) {
      unawaited(controller.goBack());
      return;
    }
    _close();
  }

  Future<bool?> _handleNestedWindow(
    InAppWebViewController controller,
    CreateWindowAction action,
  ) async {
    final WebUri? url = action.request.url;
    if (url != null) {
      await controller.loadUrl(urlRequest: URLRequest(url: url));
    }
    return false;
  }

  String get _hostLabel {
    final String host = _currentUrl?.host ?? '';
    if (host.isNotEmpty) {
      return host;
    }
    return _currentUrl?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _handleSystemBack,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  windowId: widget.windowId,
                  initialSettings: widget.settings,
                  onWebViewCreated: (InAppWebViewController controller) {
                    _update(() {
                      _controller = controller;
                    });
                  },
                  onLoadStart:
                      (InAppWebViewController controller, WebUri? url) {
                        _update(() {
                          _isLoading = true;
                          _currentUrl = url ?? _currentUrl;
                        });
                      },
                  onLoadStop: (InAppWebViewController controller, WebUri? url) {
                    _update(() {
                      _isLoading = false;
                      _currentUrl = url ?? _currentUrl;
                    });
                    unawaited(_refreshHistoryState());
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                        _update(() {
                          _progress = progress / 100;
                        });
                      },
                  onUpdateVisitedHistory:
                      (
                        InAppWebViewController controller,
                        WebUri? url,
                        bool? isReload,
                      ) {
                        _update(() {
                          _currentUrl = url ?? _currentUrl;
                        });
                        unawaited(_refreshHistoryState());
                      },
                  onCreateWindow: _handleNestedWindow,
                  onCloseWindow: (InAppWebViewController controller) {
                    _close();
                  },
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.overlay(0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WebBrowserProgressBar(isLoading: _isLoading, progress: _progress),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
              child: Row(
                children: <Widget>[
                  WebBrowserToolbarButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: S.current.web_browser_back,
                    onPressed: _canGoBack ? () => _controller?.goBack() : null,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _hostLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: medium(size: 13, color: AppColors.mainGrey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _close,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: Text(
                        S.current.web_browser_popup_close,
                        style: semibold(size: 15, color: AppColors.mainWhite),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay(0.08),
                        foregroundColor: AppColors.mainWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
