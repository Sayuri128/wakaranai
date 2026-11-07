import 'dart:async';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_cleanup.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/downloads_page/episode_streaming_fallback.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/picture_in_picture.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_overlay.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pip_scope.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NativePlayerData {
  const NativePlayerData({
    required this.video,
    required this.anime,
    required this.playlist,
    this.resolveEpisode,
    this.watchedEpisodeUids = const <String>{},
  });

  final PlayableVideo video;
  final AnimeConcreteView anime;
  final EpisodePlaylist playlist;
  final EpisodeResolver? resolveEpisode;
  final Set<String> watchedEpisodeUids;

  AnimeVideo get episode => playlist.current;
}

Future<EpisodePlayerResult?> openNativePlayer(
  BuildContext context,
  NativePlayerData data,
) async {
  final Object? result = await Navigator.of(context).pushNamed(
    Routes.nativeAnimePlayer,
    arguments: data,
  );
  if (result is EpisodePlayerResult) {
    return result;
  }
  return null;
}

typedef NativePlayerCubitFactory = NativePlayerCubit Function(
  BuildContext context,
);

class NativePlayer extends StatefulWidget {
  const NativePlayer({
    super.key,
    required this.data,
    this.pictureInPicture,
    this.deviceControls,
    this.cubitFactory,
  });

  final NativePlayerData data;
  final PictureInPicture? pictureInPicture;
  final PlayerDeviceControls? deviceControls;
  final NativePlayerCubitFactory? cubitFactory;

  @override
  State<NativePlayer> createState() => _NativePlayerState();
}

class _NativePlayerState extends State<NativePlayer> {
  late final PlayerDeviceControls _deviceControls;
  late final PictureInPicture _pictureInPicture;
  late final bool _ownsPictureInPicture;
  ModalRoute<Object?>? _route;
  NativePlayerCubit? _cubit;
  WatchedEpisodeCleanup? _watchedEpisodeCleanup;
  bool _pictureInPictureSupported = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _deviceControls = widget.deviceControls ?? PluginPlayerDeviceControls();
    final PictureInPicture? injectedPictureInPicture = widget.pictureInPicture;
    _ownsPictureInPicture = injectedPictureInPicture == null;
    _pictureInPicture = injectedPictureInPicture ?? createPictureInPicture();
    unawaited(_deviceControls.rememberOpeningVolume());
    unawaited(_resolvePictureInPictureSupport());
    _applyPlayerSystemUi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
  }

  void _applyPlayerSystemUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _resolvePictureInPictureSupport() async {
    final bool supported = await _pictureInPicture.isSupported();
    if (!mounted || !supported) {
      return;
    }
    setState(() {
      _pictureInPictureSupported = true;
    });
  }

  bool get _inPictureInPicture => _pictureInPicture.inPictureInPicture.value;

  void _onPictureInPictureEntered() {
    final ModalRoute<Object?>? route = _route;
    if (route == null || route.isCurrent || !route.isActive) {
      return;
    }
    Navigator.of(context).popUntil((Route<dynamic> other) => other == route);
  }

  void _onPictureInPictureExited() {
    _applyPlayerSystemUi();
    _leaveWith(_cubit?.state.webPlayerRequest);
  }

  void _enterPictureInPicture() {
    unawaited(_pictureInPicture.enter());
  }

  @override
  void dispose() {
    if (_ownsPictureInPicture) {
      _pictureInPicture.dispose();
    }
    unawaited(WakelockPlus.disable());
    unawaited(_deviceControls.restoreBrightness());
    unawaited(_deviceControls.restoreVolume());
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    _deleteWatchedDownloadsOnceClosed();
    super.dispose();
  }

  void _deleteWatchedDownloadsOnceClosed() {
    final WatchedEpisodeCleanup? cleanup = _watchedEpisodeCleanup;
    final NativePlayerCubit? cubit = _cubit;
    if (cleanup == null || cubit == null) {
      return;
    }
    unawaited(cleanup.deleteFinishedAfter(cubit.stream.drain<void>()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NativePlayerCubit>(
      lazy: false,
      create: _startCubit,
      child: NativePlayerPipScope(
        pictureInPicture: _pictureInPicture,
        enabled: _pictureInPictureSupported,
        onEnter: _onPictureInPictureEntered,
        onExit: _onPictureInPictureExited,
        child: _buildListeners(),
      ),
    );
  }

  Widget _buildListeners() {
    return MultiBlocListener(
      listeners: <BlocListener<NativePlayerCubit, NativePlayerState>>[
        BlocListener<NativePlayerCubit, NativePlayerState>(
          listenWhen: (NativePlayerState previous, NativePlayerState current) =>
              previous.isPlaying != current.isPlaying ||
              previous.subtitleFailed != current.subtitleFailed,
          listener: _onStateChanged,
        ),
        BlocListener<NativePlayerCubit, NativePlayerState>(
          listenWhen: (NativePlayerState previous, NativePlayerState current) =>
              previous.speedRejections < current.speedRejections,
          listener: _onSpeedRejected,
        ),
        BlocListener<NativePlayerCubit, NativePlayerState>(
          listenWhen: (NativePlayerState previous, NativePlayerState current) =>
              previous.webPlayerRequest == null &&
              current.webPlayerRequest != null,
          listener: _onWebPlayerRequested,
        ),
        BlocListener<NativePlayerCubit, NativePlayerState>(
          listenWhen: (NativePlayerState previous, NativePlayerState current) =>
              previous.status != NativePlayerStatus.error &&
              current.status == NativePlayerStatus.error,
          listener: _onPlaybackFailed,
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: _pictureInPicture.inPictureInPicture,
        builder: (BuildContext context, bool inPictureInPicture, Widget? child) {
          return _buildPlayerStates(inPictureInPicture);
        },
      ),
    );
  }

  Widget _buildPlayerStates(bool inPictureInPicture) {
    return BlocBuilder<NativePlayerCubit, NativePlayerState>(
      builder: (BuildContext context, NativePlayerState state) {
        return PopScope(
          canPop: !state.switchingEpisode,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              _cancelSwitch(context);
            }
          },
          child: _buildForState(context, state, inPictureInPicture),
        );
      },
    );
  }

  NativePlayerCubit _startCubit(BuildContext context) {
    final NativePlayerCubitFactory factory =
        widget.cubitFactory ?? _createCubit;
    final NativePlayerCubit cubit = factory(context);
    _cubit = cubit;
    unawaited(cubit.init());
    return cubit;
  }

  NativePlayerCubit _createCubit(BuildContext context) {
    final ConcreteDataRepository concreteDataRepository =
        context.read<ConcreteDataRepository>();
    final AnimeEpisodeActivityRepository animeEpisodeActivityRepository =
        context.read<AnimeEpisodeActivityRepository>();
    final WatchedEpisodeCleanup cleanup = WatchedEpisodeCleanup.of(context);
    _watchedEpisodeCleanup = cleanup;
    return NativePlayerCubit(
      video: widget.data.video,
      playlist: widget.data.playlist,
      engineFactory: VideoPlayerEngine.new,
      progressStoreFor: (AnimeVideo episode) => cleanup.track(
        ActivityEpisodeProgressStore(
          concreteDataRepository: concreteDataRepository,
          animeEpisodeActivityRepository: animeEpisodeActivityRepository,
          anime: widget.data.anime,
          episode: episode,
        ),
        episode,
      ),
      subtitleLoader: DioSubtitleLoader(),
      resolveEpisode: widget.data.resolveEpisode,
      watchedEpisodeUids: widget.data.watchedEpisodeUids,
      preferences: PlayerPreferences(),
    );
  }

  void _onStateChanged(BuildContext context, NativePlayerState state) {
    if (state.isPlaying) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
    if (state.subtitleFailed && !_inPictureInPicture) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.of(context).native_player_subtitle_failed,
      );
    }
  }

  void _onSpeedRejected(BuildContext context, NativePlayerState state) {
    if (_inPictureInPicture) {
      return;
    }
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.of(context).native_player_speed_unsupported,
    );
  }

  void _onWebPlayerRequested(BuildContext context, NativePlayerState state) {
    if (_inPictureInPicture) {
      return;
    }
    _leaveWith(state.webPlayerRequest);
  }

  void _onPlaybackFailed(BuildContext context, NativePlayerState state) {
    if (_inPictureInPicture) {
      return;
    }
    final bool streaming = streamInsteadOfFailedDownload(
      context,
      video: context.read<NativePlayerCubit>().video,
      episodeUid: state.playlist.current.uid,
    );
    if (streaming) {
      _leaveWith(PlayEpisodeRequested(state.playlist));
    }
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  void _cancelSwitch(BuildContext context) {
    unawaited(context.read<NativePlayerCubit>().cancelSwitch());
  }

  void _openInWebPlayer(EpisodePlaylist position) {
    _leaveWith(OpenInWebPlayer(position));
  }

  void _leaveWith(EpisodePlayerResult? result) {
    if (_leaving || result == null) {
      return;
    }
    _leaving = true;
    Navigator.of(context).pop(result);
  }

  Widget _buildForState(
    BuildContext context,
    NativePlayerState state,
    bool inPictureInPicture,
  ) {
    switch (state.status) {
      case NativePlayerStatus.loading:
        if (inPictureInPicture) {
          return _buildPictureInPicturePlaceholder();
        }
        return _buildLoading(context, state);
      case NativePlayerStatus.error:
        if (inPictureInPicture) {
          return _buildPictureInPicturePlaceholder();
        }
        return _buildError(context, state);
      case NativePlayerStatus.ready:
        return _buildPlayer(context, state, inPictureInPicture);
    }
  }

  Widget _buildPictureInPicturePlaceholder() {
    return const ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(),
    );
  }

  Widget _buildLoading(BuildContext context, NativePlayerState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(child: _buildLoadingContent(state.playlist.current.title)),
          Positioned(
            left: 16,
            bottom: 16,
            child: SafeArea(
              child: IconButton(
                tooltip: S.of(context).common_go_back,
                onPressed: _close,
                color: AppColors.onMedia,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          if (state.switchingEpisode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: SafeArea(
                child: Center(child: _buildCancelSwitchButton(context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCancelSwitchButton(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onMedia,
        backgroundColor: AppColors.onMedia.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: medium(size: 14),
      ),
      onPressed: () => _cancelSwitch(context),
      icon: const Icon(Icons.close_rounded, size: 20),
      label: Text(S.of(context).native_player_cancel_switch),
    );
  }

  Widget _buildLoadingContent(String episodeTitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircularProgressIndicator(color: AppColors.primary),
        if (episodeTitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              episodeTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: medium(size: 14, color: AppColors.onMedia),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError(BuildContext context, NativePlayerState state) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ServiceViewerMessage(
                  icon: Icons.error_outline_rounded,
                  title: S.of(context).native_player_error_title,
                  message: state.errorMessage,
                  actions: _buildErrorActions(context, state),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildErrorActions(
    BuildContext context,
    NativePlayerState state,
  ) {
    final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.mainWhite,
      side: BorderSide(color: AppColors.mainGrey),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    return <Widget>[
      OutlinedButton.icon(
        style: outlinedStyle,
        onPressed: _close,
        icon: const Icon(Icons.arrow_back_rounded),
        label: Text(S.of(context).common_go_back),
      ),
      OutlinedButton.icon(
        style: outlinedStyle,
        onPressed: () => _openInWebPlayer(state.playlist),
        icon: const Icon(Icons.public_rounded),
        label: Text(S.of(context).native_player_open_web_player),
      ),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.mainBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => unawaited(context.read<NativePlayerCubit>().retry()),
        icon: const Icon(Icons.refresh_rounded),
        label: Text(S.of(context).native_player_retry),
      ),
    ];
  }

  Widget _buildPlayer(
    BuildContext context,
    NativePlayerState state,
    bool inPictureInPicture,
  ) {
    final NativePlayerEngine? engine = state.engine;
    if (engine == null) {
      if (inPictureInPicture) {
        return _buildPictureInPicturePlaceholder();
      }
      return _buildLoading(context, state);
    }
    final PlayerFitMode fitMode =
        inPictureInPicture ? PlayerFitMode.fit : state.fitMode;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildVideoView(engine, state.engineGeneration, fitMode),
          if (!inPictureInPicture)
            NativePlayerOverlay(
              playback: engine,
              deviceControls: _deviceControls,
              state: state,
              title: widget.data.anime.title,
              subtitle: state.playlist.current.title,
              onBack: _close,
              onOpenWebPlayer: () => _openInWebPlayer(state.playlist),
              onPictureInPicture:
                  _pictureInPictureSupported ? _enterPictureInPicture : null,
            ),
        ],
      ),
    );
  }

  Widget _buildVideoView(
    NativePlayerEngine engine,
    int generation,
    PlayerFitMode fitMode,
  ) {
    return ValueListenableBuilder<VideoPlayerValue>(
      key: ValueKey<int>(generation),
      valueListenable: engine,
      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
        return ClipRect(
          child: FittedBox(
            fit: boxFitFor(fitMode),
            child: SizedBox.fromSize(
              size: _videoSizeOf(value),
              child: child,
            ),
          ),
        );
      },
      child: engine.buildView(),
    );
  }

  Size _videoSizeOf(VideoPlayerValue value) {
    final Size size = value.size;
    if (size.width > 0 && size.height > 0) {
      return size;
    }
    return Size(value.aspectRatio * 1080, 1080);
  }
}

BoxFit boxFitFor(PlayerFitMode mode) {
  switch (mode) {
    case PlayerFitMode.fit:
      return BoxFit.contain;
    case PlayerFitMode.fill:
      return BoxFit.cover;
    case PlayerFitMode.stretch:
      return BoxFit.fill;
  }
}
