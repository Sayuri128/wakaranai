import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/models/config_info/protector_config/protector_config.dart';

class WebBrowserPage extends StatefulWidget {
  const WebBrowserPage({Key? key, required this.config}) : super(key: key);

  final ProtectorConfig config;

  @override
  State<WebBrowserPage> createState() => _WebBrowserPageState();
}

class _WebBrowserPageState extends State<WebBrowserPage> {
  final GlobalKey _webViewKey = GlobalKey();
  late InAppWebViewController _webView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          InAppWebView(
            key: _webViewKey,
            initialUrlRequest:
                URLRequest(url: Uri.parse(widget.config.pingUrl)),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
              clearCache: true,
              cacheEnabled: false,
            )),
            onWebViewCreated: (controller) async {
              _webView = controller;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: ElevatedButton(
                onPressed: () async {
                  _getHeaders((headers) {
                    if (!mounted) return;
                    Navigator.of(context).pop(headers);
                  });
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.primary),
                    shadowColor: MaterialStateProperty.all(
                        AppColors.primary.withOpacity(0.35))),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    S.current.web_browser_no_login_button,
                    style: semibold(size: 16),
                    textAlign: TextAlign.center,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Future<void> _getHeaders(Function(Map<String, String>) done) async {
    done({
      'user-agent': ((await _webView.callAsyncJavaScript(
              functionBody: 'return navigator.userAgent;'))
          ?.value as String),
      'cookie': (await CookieManager.instance()
              .getCookies(url: Uri.parse(widget.config.pingUrl)))
          .map((e) => '${e.name}=${e.value}')
          .join('; ')
    });
  }
}
