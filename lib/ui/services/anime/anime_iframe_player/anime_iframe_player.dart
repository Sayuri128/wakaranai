import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_page.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/cubit/anime_iframe_player_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';

class AnimeIframePlayerData {
  final AnimeVideo video;
  final AnimeConcreteView anime;

  const AnimeIframePlayerData({required this.video, required this.anime});
}

class AnimeIframePlayer extends StatefulWidget {
  const AnimeIframePlayer({super.key, required this.data});

  final AnimeIframePlayerData data;

  @override
  State<AnimeIframePlayer> createState() => _AnimeIframePlayerState();
}

class _AnimeIframePlayerState extends State<AnimeIframePlayer> {
  late final AnimeIframePage? _page = buildAnimeIframePage(
    widget.data.video.src,
  );
  bool _landscapeLockedForFullscreen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (_page == null) {
      logger.w(
        'Anime iframe source is not a valid http(s) URL: '
        '${widget.data.video.src}',
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_landscapeLockedForFullscreen) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  void _lockLandscapeForFullscreen() {
    _landscapeLockedForFullscreen = true;
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _releaseFullscreenOrientation() {
    if (!_landscapeLockedForFullscreen) {
      return;
    }
    _landscapeLockedForFullscreen = false;
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
  }

  Future<NavigationActionPolicy> _decideNavigation(
    AnimeIframePage page,
    NavigationAction action,
  ) async {
    if (!action.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }
    final WebUri? target = action.request.url;
    if (target == null) {
      return NavigationActionPolicy.CANCEL;
    }
    if (target.scheme == 'about' ||
        target.toString() == page.baseUrl.toString()) {
      return NavigationActionPolicy.ALLOW;
    }
    logger.d('Blocked top-level navigation away from the player: $target');
    return NavigationActionPolicy.CANCEL;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimeIframePlayerCubit>(
      lazy: false,
      create: (context) => AnimeIframePlayerCubit(
        concreteDataRepository: context.read<ConcreteDataRepository>(),
        animeEpisodeActivityRepository: context
            .read<AnimeEpisodeActivityRepository>(),
      )..init(anime: widget.data.anime, video: widget.data.video),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final AnimeIframePage? page = _page;
    if (page == null) {
      return _buildInvalidSource(context);
    }
    return _buildWebView(page);
  }

  Widget _buildWebView(AnimeIframePage page) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: page.html,
        baseUrl: WebUri.uri(page.baseUrl),
      ),
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
            logger.d(consoleMessage.message);
          },
      shouldOverrideUrlLoading:
          (InAppWebViewController controller, NavigationAction action) {
            return _decideNavigation(page, action);
          },
      onEnterFullscreen: (InAppWebViewController controller) {
        _lockLandscapeForFullscreen();
      },
      onExitFullscreen: (InAppWebViewController controller) {
        _releaseFullscreenOrientation();
      },
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        preferredContentMode: UserPreferredContentMode.MOBILE,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        cacheEnabled: true,
        useHybridComposition: true,
        supportMultipleWindows: true,
        allowsInlineMediaPlayback: true,
      ),
    );
  }

  Widget _buildInvalidSource(BuildContext context) {
    final String rawSource = widget.data.video.src.trim();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: ServiceViewerMessage(
          icon: Icons.error_outline_rounded,
          title: S.of(context).service_view_error_title,
          message: rawSource.isEmpty ? null : rawSource,
          actions: <Widget>[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainWhite,
                side: BorderSide(color: AppColors.mainGrey),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(S.of(context).common_go_back),
            ),
          ],
        ),
      ),
    );
  }
}
