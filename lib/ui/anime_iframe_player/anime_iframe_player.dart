import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AnimeIframePlayerData {
  final String src;

  const AnimeIframePlayerData({
    required this.src,
  });
}

class AnimeIframePlayer extends StatefulWidget {
  const AnimeIframePlayer({Key? key, required this.data}) : super(key: key);

  final AnimeIframePlayerData data;

  @override
  State<AnimeIframePlayer> createState() => _AnimeIframePlayerState();
}

class _AnimeIframePlayerState extends State<AnimeIframePlayer>{
  InAppWebViewController? _inAppWebViewController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
        onWebViewCreated: (controller) {
          _inAppWebViewController = controller;

          _inAppWebViewController!.loadUrl(
              urlRequest: URLRequest(url: Uri.parse("https://www.blank.org/")));

          if (mounted) {
            setState(() {});
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage.message);
        },
        onLoadStop: (controller, url) {
          controller.callAsyncJavaScript(functionBody: '''
          const iframe = document.createElement("iframe");
          iframe.src = "${widget.data.src}";
          iframe.style["border"] = "none";
          
          iframe.style["width"] = "100%";
          iframe.style["height"] = "100%";      
          
          document.body.style["background"] = "black";
          document.body.style["display"] = "flex";
          document.body.style["justify-content"] = "center";
          document.body.style["align-items"] = "center";
          document.body.style["width"] = "100%";
          document.body.style["height"] = "100%";
          document.body.style["margin"] = "0";
          document.getElementsByTagName("html")[0].style["margin"] = "0";
          document.body.removeChild(document.getElementsByTagName("center")[0]);
         
          document.body.appendChild(iframe);
                    
          ''').then((value) {
            print(value);
          });
        },
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              preferredContentMode: UserPreferredContentMode.MOBILE,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptCanOpenWindowsAutomatically: true,
              cacheEnabled: true,
            ),
            android: AndroidInAppWebViewOptions(
                useHybridComposition: true, supportMultipleWindows: true),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
            )));
  }
}
