import 'package:flutter_inappwebview/flutter_inappwebview.dart';

InAppWebViewGroupOptions getDefaultBrowserOption() => InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      userAgent:
          "Mozilla/5.0 (Linux; Android 13; SM-N960U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.5481.63 Mobile Safari/537.36",
      javaScriptEnabled: true,
      preferredContentMode: UserPreferredContentMode.DESKTOP,
      mediaPlaybackRequiresUserGesture: true,
      javaScriptCanOpenWindowsAutomatically: true,
      cacheEnabled: true,
    ),
    android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        supportMultipleWindows: true,
        cacheMode: AndroidCacheMode.LOAD_DEFAULT,
        databaseEnabled: true,
        scrollBarStyle: AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
        allowContentAccess: true,
        allowFileAccess: true,
        domStorageEnabled: true,
        clearSessionCache: false,
        forceDark: AndroidForceDark.FORCE_DARK_ON,
        loadsImagesAutomatically: true),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));
