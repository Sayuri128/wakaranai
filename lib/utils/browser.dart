import 'package:flutter_inappwebview/flutter_inappwebview.dart';

InAppWebViewSettings getDefaultBrowserSettings() => InAppWebViewSettings(
      userAgent:
          "Mozilla/5.0 (Linux; Android 13; SM-N960U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.5481.63 Mobile Safari/537.36",
      javaScriptEnabled: true,
      preferredContentMode: UserPreferredContentMode.DESKTOP,
      mediaPlaybackRequiresUserGesture: true,
      javaScriptCanOpenWindowsAutomatically: true,
      cacheEnabled: true,
      useHybridComposition: true,
      supportMultipleWindows: true,
      cacheMode: CacheMode.LOAD_DEFAULT,
      databaseEnabled: true,
      scrollBarStyle: ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
      allowContentAccess: true,
      allowFileAccess: true,
      domStorageEnabled: true,
      clearSessionCache: false,
      forceDark: ForceDark.ON,
      loadsImagesAutomatically: true,
      allowsInlineMediaPlayback: true,
    );
