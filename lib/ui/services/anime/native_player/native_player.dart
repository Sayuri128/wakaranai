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
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_overlay.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum NativePlayerResult { openInWebPlayer, nextEpisode }

class NativePlayerData {
  const NativePlayerData({
    required this.video,
    required this.episode,
    required this.anime,
    this.hasNextEpisode = false,
  });

  final PlayableVideo video;
  final AnimeVideo episode;
  final AnimeConcreteView anime;
  final bool hasNextEpisode;
}

Future<NativePlayerResult?> openNativePlayer(
  BuildContext context,
  NativePlayerData data,
) async {
  final Object? result = await Navigator.of(context).pushNamed(
    Routes.nativeAnimePlayer,
    arguments: data,
  );
  if (result is NativePlayerResult) {
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
                !previous.nextEpisodeRequested && current.nextEpisodeRequested,
            listener: (BuildContext context, NativePlayerState state) =>
                _playNextEpisode(),
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
    final NativePlayerCubit cubit = NativePlayerCubit(
      video: widget.data.video,
      engineFactory: VideoPlayerEngine.new,
      progressStore: ActivityEpisodeProgressStore(
        concreteDataRepository: context.read<ConcreteDataRepository>(),
        animeEpisodeActivityRepository:
            context.read<AnimeEpisodeActivityRepository>(),
        anime: widget.data.anime,
        episode: widget.data.episode,
      ),
      subtitleLoader: DioSubtitleLoader(),
      preferences: PlayerPreferences(),
      hasNextEpisode: widget.data.hasNextEpisode,
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

  void _openInWebPlayer() {
    Navigator.of(context).pop(NativePlayerResult.openInWebPlayer);
  }

  void _playNextEpisode() {
    if (_leaving) {
      return;
    }
    _leaving = true;
    Navigator.of(context).pop(NativePlayerResult.nextEpisode);
  }

  Widget _buildForState(BuildContext context, NativePlayerState state) {
    switch (state.status) {
      case NativePlayerStatus.loading:
        return _buildLoading();
      case NativePlayerStatus.error:
        return _buildError(context, state);
      case NativePlayerStatus.ready:
        return _buildPlayer(state);
    }
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                  actions: _buildErrorActions(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildErrorActions(BuildContext context) {
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
        onPressed: _openInWebPlayer,
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
      return _buildLoading();
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
            subtitle: widget.data.episode.title,
            onBack: _close,
            onOpenWebPlayer: _openInWebPlayer,
            onNextEpisode:
                widget.data.hasNextEpisode ? _playNextEpisode : null,
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
