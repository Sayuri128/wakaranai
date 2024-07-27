import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/cubit/anime_iframe_player_cubit.dart';

class AnimeIframePlayerData {
  final AnimeVideo video;
  final AnimeConcreteView anime;

  const AnimeIframePlayerData({
    required this.video,
    required this.anime,
  });
}

class AnimeIframePlayer extends StatefulWidget {
  const AnimeIframePlayer({super.key, required this.data});

  final AnimeIframePlayerData data;

  @override
  State<AnimeIframePlayer> createState() => _AnimeIframePlayerState();
}

class _AnimeIframePlayerState extends State<AnimeIframePlayer> {
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
        overlays: <SystemUiOverlay>[
          SystemUiOverlay.top,
          SystemUiOverlay.bottom
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimeIframePlayerCubit>(
      lazy: false,
      create: (context) => AnimeIframePlayerCubit(
        concreteDataRepository: context.read<ConcreteDataRepository>(),
        animeEpisodeActivityRepository:
            context.read<AnimeEpisodeActivityRepository>(),
      )..init(
          anime: widget.data.anime,
          video: widget.data.video,
        ),
      child: InAppWebView(
        onWebViewCreated: (InAppWebViewController controller) {
          _inAppWebViewController = controller;

          _inAppWebViewController!.loadUrl(
              urlRequest: URLRequest(url: WebUri("https://www.blank.org/")));

          if (mounted) {
            setState(() {});
          }
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          logger.d(consoleMessage.message);
        },
        onLoadStop: (InAppWebViewController controller, WebUri? url) {
          controller.callAsyncJavaScript(functionBody: '''
          const iframe = document.createElement("iframe");
          iframe.src = "${widget.data.video.src}";
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
                    
          ''').then((CallAsyncJavaScriptResult? value) {
            logger.d(value);
          });
        },
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptCanOpenWindowsAutomatically: true,
          cacheEnabled: true,
          useHybridComposition: true,
          supportMultipleWindows: true,
          allowsInlineMediaPlayback: true,
        ),
      ),
    );
  }
}
