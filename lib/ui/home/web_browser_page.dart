import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/browser.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/config_info/protector_config/protector_config.dart';

class WebBrowserData {
  final ProtectorConfig config;
  final ProtectorStorageItem? protectorStorageItem;

  const WebBrowserData({
    required this.config,
    this.protectorStorageItem,
  });
}

class WebBrowserPage extends StatefulWidget {
  const WebBrowserPage({Key? key, required this.data}) : super(key: key);

  final WebBrowserData data;

  @override
  State<WebBrowserPage> createState() => _WebBrowserPageState();
}

class _WebBrowserPageState extends State<WebBrowserPage> {
  final GlobalKey _webViewKey = GlobalKey();
  late InAppWebViewController _webView;

  late final InAppWebViewGroupOptions options;

  @override
  void initState() {
    super.initState();

    final def = getDefaultBrowserOption();
    def.crossPlatform.preferredContentMode =
        UserPreferredContentMode.RECOMMENDED;
    options = def;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            InAppWebView(
              key: _webViewKey,
              initialOptions: options,
              initialUrlRequest:
                  URLRequest(url: Uri.parse(widget.data.config.pingUrl)),
              onWebViewCreated: (controller) async {
                _webView = controller;
                controller.android.clearSslPreferences();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: ElevatedButton(
                  onPressed: () async {
                    getHeaders(
                        done: (headers) {
                          if (!mounted) return;
                          Navigator.of(context).pop(headers);
                        },
                        controller: _webView,
                        pingUrl: widget.data.config.pingUrl);
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
      ),
    );
  }
}

Future<void> getHeaders(
    {required Function(Map<String, dynamic>) done,
    required String pingUrl,
    required InAppWebViewController controller}) async {
  final cookies = Map.fromEntries(
      (await CookieManager.instance().getCookies(url: Uri.parse(pingUrl)))
          .map((e) => MapEntry(e.name, e.value)));
  done({
    'headers': Map.from(<String, String>{
      'user-agent': ((await controller.callAsyncJavaScript(
              functionBody: 'return navigator.userAgent;'))
          ?.value as String),
      'cookie': cookies.entries.map((e) => '${e.key}=${e.value}').join('; ')
    }),
    'cookies-raw': cookies
  });
}

Future<void> openWebView(
    BuildContext context, ApiClient apiClient, ConfigInfo config) async {
  final uid = '${config.name}_${config.version}';
  final result = await Navigator.of(context).pushNamed(Routes.webBrowser,
      arguments: WebBrowserData(
          config: config.protectorConfig!,
          protectorStorageItem:
              await ProtectorStorageService().getItem(uid: uid)));
  if (result != null) {
    await apiClient.passProtector(data: result as Map<String, dynamic>);
    await ProtectorStorageService()
        .saveItem(item: ProtectorStorageItem(uid: uid, headers: result));
  } else {
    return;
  }
}
