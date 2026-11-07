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
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_overlay.dart';
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

class NativePlayer extends StatefulWidget {
  const NativePlayer({super.key, required this.data});

  final NativePlayerData data;

  @override
  State<NativePlayer> createState() => _NativePlayerState();
}

class _NativePlayerState extends State<NativePlayer> {
  final PlayerDeviceControls _deviceControls = PluginPlayerDeviceControls();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_deviceControls.rememberOpeningVolume());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    unawaited(_deviceControls.restoreBrightness());
    unawaited(_deviceControls.restoreVolume());
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NativePlayerCubit>(
      lazy: false,
      create: _createCubit,
      child: MultiBlocListener(
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
            listener: (BuildContext context, NativePlayerState state) =>
                _leaveWith(state.webPlayerRequest),
          ),
        ],
        child: BlocBuilder<NativePlayerCubit, NativePlayerState>(
          builder: (BuildContext context, NativePlayerState state) {
            return _buildForState(context, state);
          },
        ),
      ),
    );
  }

  NativePlayerCubit _createCubit(BuildContext context) {
    final ConcreteDataRepository concreteDataRepository =
        context.read<ConcreteDataRepository>();
    final AnimeEpisodeActivityRepository animeEpisodeActivityRepository =
        context.read<AnimeEpisodeActivityRepository>();
    final NativePlayerCubit cubit = NativePlayerCubit(
      video: widget.data.video,
      playlist: widget.data.playlist,
      engineFactory: VideoPlayerEngine.new,
      progressStoreFor: (AnimeVideo episode) => ActivityEpisodeProgressStore(
        concreteDataRepository: concreteDataRepository,
        animeEpisodeActivityRepository: animeEpisodeActivityRepository,
        anime: widget.data.anime,
        episode: episode,
      ),
      subtitleLoader: DioSubtitleLoader(),
      resolveEpisode: widget.data.resolveEpisode,
      watchedEpisodeUids: widget.data.watchedEpisodeUids,
      preferences: PlayerPreferences(),
    );
    unawaited(cubit.init());
    return cubit;
  }

  void _onStateChanged(BuildContext context, NativePlayerState state) {
    if (state.isPlaying) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
    if (state.subtitleFailed) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.of(context).native_player_subtitle_failed,
      );
    }
  }

  void _onSpeedRejected(BuildContext context, NativePlayerState state) {
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.of(context).native_player_speed_unsupported,
    );
  }

  void _close() {
    Navigator.of(context).maybePop();
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

  Widget _buildForState(BuildContext context, NativePlayerState state) {
    switch (state.status) {
      case NativePlayerStatus.loading:
        return _buildLoading(state.playlist.current.title);
      case NativePlayerStatus.error:
        return _buildError(context, state);
      case NativePlayerStatus.ready:
        return _buildPlayer(state);
    }
  }

  Widget _buildLoading(String episodeTitle) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(child: _buildLoadingContent(episodeTitle)),
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
        ],
      ),
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

  Widget _buildPlayer(NativePlayerState state) {
    final NativePlayerEngine? engine = state.engine;
    if (engine == null) {
      return _buildLoading(state.playlist.current.title);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildVideoView(engine, state.engineGeneration, state.fitMode),
          NativePlayerOverlay(
            playback: engine,
            deviceControls: _deviceControls,
            state: state,
            title: widget.data.anime.title,
            subtitle: state.playlist.current.title,
            onBack: _close,
            onOpenWebPlayer: () => _openInWebPlayer(state.playlist),
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
