import 'dart:async';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/data/models/web_browser_result/web_browser_result.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/web_browser/web_browser_done_button.dart';
import 'package:wakaranai/ui/home/web_browser/web_browser_popup_page.dart';
import 'package:wakaranai/ui/home/web_browser/web_browser_toolbar.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/browser.dart';
import 'package:wakaranai/utils/text_styles.dart';

class WebBrowserData {
  final ProtectorConfig config;
  final ProtectorStorageItem? protectorStorageItem;

  const WebBrowserData({
    required this.config,
    this.protectorStorageItem,
  });
}

class WebBrowserPage extends StatefulWidget {
  const WebBrowserPage({
    super.key,
    required this.data,
  });

  final WebBrowserData data;

  @override
  State<WebBrowserPage> createState() => _WebBrowserPageState();
}

class _WebBrowserPageState extends State<WebBrowserPage> {
  static const String _clearanceCookieName = 'cf_clearance';
  static const List<String> _challengeTitleMarkers = <String>[
    'just a moment',
    'attention required',
    'please wait',
    'checking your browser',
    'ddos-guard',
  ];

  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _controller;

  late final InAppWebViewSettings settings;

  WebUri? _currentUrl;
  bool _isLoading = true;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isCollecting = false;
  bool _challengeSeen = false;
  bool _challengePassed = false;
  String? _baselineClearance;
  String? _mainFrameError;
  WebUri? _failedUrl;

  @override
  void initState() {
    super.initState();

    final InAppWebViewSettings def = getDefaultBrowserSettings();
    def.preferredContentMode = UserPreferredContentMode.RECOMMENDED;
    settings = def;
    _currentUrl = WebUri(widget.data.config.pingUrl);
    unawaited(_captureClearanceBaseline());
  }

  void _update(VoidCallback change) {
    if (!mounted) {
      return;
    }
    setState(change);
  }

  WebUri get _activeUrl => _currentUrl ?? WebUri(widget.data.config.pingUrl);

  String get _activeHost {
    final String host = _activeUrl.host;
    if (host.isNotEmpty) {
      return host;
    }
    return _activeUrl.toString();
  }

  Future<String?> _readClearance(WebUri url) async {
    try {
      final Cookie? cookie = await CookieManager.instance()
          .getCookie(url: url, name: _clearanceCookieName);
      return cookie?.value?.toString();
    } catch (e) {
      logger.w('Failed to read clearance cookie: $e');
      return null;
    }
  }

  Future<void> _captureClearanceBaseline() async {
    _baselineClearance = await _readClearance(_activeUrl);
  }

  Future<void> _checkClearanceAppeared(WebUri? url) async {
    if (url == null || _challengePassed) {
      return;
    }
    final String? clearance = await _readClearance(url);
    if (clearance == null || clearance.isEmpty) {
      return;
    }
    if (clearance == _baselineClearance) {
      return;
    }
    _update(() {
      _challengePassed = true;
    });
  }

  bool _isChallengeTitle(String title) {
    final String normalized = title.trim().toLowerCase();
    return _challengeTitleMarkers.any(normalized.contains);
  }

  void _handleTitleChanged(InAppWebViewController controller, String? title) {
    if (title == null || title.trim().isEmpty) {
      return;
    }
    if (_isChallengeTitle(title)) {
      _update(() {
        _challengeSeen = true;
        _challengePassed = false;
      });
      return;
    }
    if (_challengeSeen && !_challengePassed) {
      _update(() {
        _challengePassed = true;
      });
    }
  }

  Future<void> _refreshHistoryState() async {
    final InAppWebViewController? controller = _controller;
    if (controller == null) {
      return;
    }
    final bool canGoBack = await controller.canGoBack();
    final bool canGoForward = await controller.canGoForward();
    _update(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  void _handleLoadStart(InAppWebViewController controller, WebUri? url) {
    _update(() {
      _isLoading = true;
      _progress = 0;
      _currentUrl = url ?? _currentUrl;
      if (url != null && url.toString() != _failedUrl?.toString()) {
        _mainFrameError = null;
        _failedUrl = null;
      }
    });
  }

  void _handleLoadStop(InAppWebViewController controller, WebUri? url) {
    _update(() {
      _isLoading = false;
      _currentUrl = url ?? _currentUrl;
    });
    unawaited(_refreshHistoryState());
    unawaited(_checkClearanceAppeared(url));
  }

  void _handleReceivedError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error) {
    if (request.isForMainFrame != true) {
      return;
    }
    if (error.type == WebResourceErrorType.CANCELLED) {
      return;
    }
    _update(() {
      _isLoading = false;
      _mainFrameError = error.description;
      _failedUrl = request.url;
    });
  }

  Future<bool?> _handleCreateWindow(
      InAppWebViewController controller, CreateWindowAction action) async {
    unawaited(_openPopup(action));
    return true;
  }

  Future<void> _openPopup(CreateWindowAction action) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => WebBrowserPopupPage(
        windowId: action.windowId,
        settings: settings,
        initialUrl: action.request.url,
      ),
    ));
    await _refreshHistoryState();
    await _checkClearanceAppeared(_currentUrl);
  }

  void _clearError() {
    _update(() {
      _mainFrameError = null;
    });
  }

  Future<void> _goBack() async {
    _clearError();
    await _controller?.goBack();
  }

  Future<void> _goForward() async {
    _clearError();
    await _controller?.goForward();
  }

  Future<void> _reload() async {
    final InAppWebViewController? controller = _controller;
    if (controller == null) {
      return;
    }
    final WebUri? failedUrl = _failedUrl;
    _update(() {
      _mainFrameError = null;
      _failedUrl = null;
    });
    if (failedUrl != null) {
      await controller.loadUrl(urlRequest: URLRequest(url: failedUrl));
      return;
    }
    await controller.reload();
  }

  Future<void> _stop() async {
    await _controller?.stopLoading();
    _update(() {
      _isLoading = false;
    });
  }

  void _handleSystemBack(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    if (_canGoBack && _controller != null) {
      unawaited(_goBack());
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _copyCurrentUrl() async {
    await Clipboard.setData(ClipboardData(text: _activeUrl.toString()));
    if (!mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: '${S.current.web_browser_link_copied}\n${_activeUrl.toString()}',
    );
  }

  Future<void> _openExternally() async {
    final Uri uri = Uri.parse(_activeUrl.toString());
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.w('Failed to open $uri externally: $e');
    }
    if (!launched && mounted) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.web_browser_open_external_failed,
      );
    }
  }

  List<String?> _cookieDomainsFor(String host) {
    final List<String?> domains = <String?>[null, host];
    final List<String> labels = host.split('.');
    for (int start = 0; start <= labels.length - 2; start++) {
      domains.add('.${labels.sublist(start).join('.')}');
    }
    return domains;
  }

  Future<void> _clearSiteCookies() async {
    final WebUri url = _activeUrl;
    final String host = url.host;
    if (host.isEmpty) {
      return;
    }
    final CookieManager cookieManager = CookieManager.instance();
    final WebUri siteRoot = WebUri('${url.scheme}://$host/');
    for (final String? domain in _cookieDomainsFor(host)) {
      try {
        await cookieManager.deleteCookies(
          url: siteRoot,
          domain: domain,
          webViewController: _controller,
        );
      } catch (e) {
        logger.w('Failed to delete cookies for $host ($domain): $e');
      }
    }
    _baselineClearance = null;
    _update(() {
      _challengeSeen = false;
      _challengePassed = false;
    });
    if (!mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: S.current.web_browser_cookies_cleared(host),
    );
    await _reload();
  }

  void _showMoreSheet() {
    unawaited(showActionSheet(
      context,
      title: _activeHost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SelectableText(
              _activeUrl.toString(),
              maxLines: 3,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ),
          ActionSheetRow(
            label: S.current.web_browser_copy_link,
            icon: Icons.link_rounded,
            onTap: () => _runFromSheet(_copyCurrentUrl),
          ),
          ActionSheetRow(
            label: S.current.web_browser_open_external,
            icon: Icons.open_in_new_rounded,
            onTap: () => _runFromSheet(_openExternally),
          ),
          ActionSheetRow(
            label: S.current.web_browser_clear_cookies,
            icon: Icons.cookie_outlined,
            destructive: true,
            onTap: () => _runFromSheet(_clearSiteCookies),
          ),
        ],
      ),
    ));
  }

  void _runFromSheet(Future<void> Function() action) {
    Navigator.of(context).pop();
    unawaited(action());
  }

  Future<void> _finish() async {
    final InAppWebViewController? controller = _controller;
    if (controller == null || _isCollecting) {
      return;
    }
    _update(() {
      _isCollecting = true;
    });
    try {
      await getHeaders(
          done: (Map<String, String> headers,
              Map<String, String> cookies) async {
            try {
              if (!mounted) {
                return;
              }
              final CallAsyncJavaScriptResult? body =
                  await controller.callAsyncJavaScript(
                      functionBody:
                          "return document.documentElement.innerHTML");
              if (!mounted) {
                return;
              }
              Navigator.of(context).pop(WebBrowserPageResult(
                  headers: headers,
                  cookies: cookies,
                  body: body?.value ?? ""));
            } catch (e) {
              logger.w('Failed to collect the page body: $e');
              _update(() {
                _isCollecting = false;
              });
            }
          },
          controller: controller,
          pingUrl: widget.data.config.pingUrl);
    } catch (e) {
      logger.w('Failed to collect browser headers: $e');
      _update(() {
        _isCollecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !(_canGoBack && _controller != null),
      onPopInvokedWithResult: _handleSystemBack,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: _buildWebView()),
                    if (_mainFrameError != null)
                      Positioned.fill(child: _buildErrorPanel()),
                  ],
                ),
              ),
              _buildBottomPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      key: _webViewKey,
      initialSettings: settings,
      initialUrlRequest: URLRequest(
        url: WebUri(widget.data.config.pingUrl),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _update(() {
          _controller = controller;
        });
      },
      onLoadStart: _handleLoadStart,
      onLoadStop: _handleLoadStop,
      onProgressChanged: (InAppWebViewController controller, int progress) {
        _update(() {
          _progress = progress / 100;
        });
      },
      onUpdateVisitedHistory:
          (InAppWebViewController controller, WebUri? url, bool? isReload) {
        _update(() {
          _currentUrl = url ?? _currentUrl;
        });
        unawaited(_refreshHistoryState());
      },
      onTitleChanged: _handleTitleChanged,
      onReceivedError: _handleReceivedError,
      onCreateWindow: _handleCreateWindow,
    );
  }

  Widget _buildErrorPanel() {
    return ColoredBox(
      color: AppColors.backgroundColor,
      child: ServiceViewerMessage(
        icon: Icons.cloud_off_rounded,
        title: S.current.web_browser_error_title,
        message: _mainFrameError,
        actions: <Widget>[
          ElevatedButton.icon(
            onPressed: _controller == null ? null : () => unawaited(_reload()),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              S.current.web_browser_retry,
              style: semibold(size: 15, color: AppColors.mainBlack),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool controllerReady = _controller != null;
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
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: WebBrowserToolbar(
                host: _activeHost,
                isSecure: _activeUrl.scheme == 'https',
                isLoading: _isLoading,
                canGoBack: _canGoBack,
                canGoForward: _canGoForward,
                enabled: controllerReady,
                onBack: () => unawaited(_goBack()),
                onForward: () => unawaited(_goForward()),
                onReload: () => unawaited(_reload()),
                onStop: () => unawaited(_stop()),
                onAddressTap: () => unawaited(_copyCurrentUrl()),
                onMore: _showMoreSheet,
              ),
            ),
            if (!keyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 6, 13, 10),
                child: WebBrowserDoneButton(
                  highlighted: _challengePassed,
                  busy: _isCollecting,
                  onPressed: controllerReady && !_isCollecting
                      ? () => unawaited(_finish())
                      : null,
                ),
              ),
            if (keyboardVisible) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

Future<void> openWebView(
    BuildContext context, ApiClient apiClient, ConfigInfo config) async {
  final ProtectorConfig? protectorConfig = config.protectorConfig;
  if (protectorConfig == null) return;

  final String uid = ProtectorStorageService.sessionKey(config);
  final Object? result = await Navigator.of(context).pushNamed(
      Routes.webBrowser,
      arguments: WebBrowserData(
          config: protectorConfig,
          protectorStorageItem:
              await ProtectorStorageService().getItemForConfig(config)));
  if (result != null && result is WebBrowserPageResult) {
    await apiClient.passProtector(
        body: result.body, headers: result.headers, cookies: result.cookies);
    await ProtectorStorageService()
        .saveItem(item: ProtectorStorageItem(uid: uid, data: result));
  } else {
    return;
  }
}
