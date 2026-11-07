import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/picture_in_picture.dart';

PictureInPictureConfig nativePlayerPipConfig({
  required NativePlayerState state,
  required bool hasNextEpisode,
  required Size? videoSize,
  required S strings,
}) {
  final bool ready =
      state.status == NativePlayerStatus.ready &&
      state.engine != null &&
      !state.switchingEpisode;
  final Size? usableSize = videoSize != null && isUsableVideoSize(videoSize)
      ? videoSize
      : null;
  return PictureInPictureConfig(
    autoEnter: ready && state.isPlaying,
    aspectWidth: usableSize?.width.round() ?? 0,
    aspectHeight: usableSize?.height.round() ?? 0,
    playing: state.isPlaying,
    hasNext: hasNextEpisode,
    toggleTitle: state.isPlaying
        ? strings.native_player_pause
        : strings.native_player_play,
    nextTitle: strings.native_player_next_episode,
  );
}

class NativePlayerPipScope extends StatefulWidget {
  const NativePlayerPipScope({
    super.key,
    required this.pictureInPicture,
    required this.enabled,
    required this.onEnter,
    required this.onExit,
    required this.child,
  });

  final PictureInPicture pictureInPicture;
  final bool enabled;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final Widget child;

  @override
  State<NativePlayerPipScope> createState() => _NativePlayerPipScopeState();
}

class _NativePlayerPipScopeState extends State<NativePlayerPipScope> {
  late final NativePlayerCubit _cubit;
  StreamSubscription<NativePlayerState>? _stateSubscription;
  StreamSubscription<PictureInPictureAction>? _actionSubscription;
  NativePlayerEngine? _observedEngine;
  Size? _lastVideoSize;
  PictureInPictureConfig? _lastConfig;
  bool _wasInPictureInPicture = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<NativePlayerCubit>();
    _stateSubscription = _cubit.stream.listen(_onCubitState);
    _actionSubscription = widget.pictureInPicture.actions.listen(_onAction);
    _wasInPictureInPicture = widget.pictureInPicture.inPictureInPicture.value;
    widget.pictureInPicture.inPictureInPicture.addListener(_onModeChanged);
    _observeEngine(_cubit.state.engine);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(NativePlayerPipScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _lastConfig = null;
      _sync();
    }
  }

  @override
  void dispose() {
    unawaited(_stateSubscription?.cancel());
    unawaited(_actionSubscription?.cancel());
    widget.pictureInPicture.inPictureInPicture.removeListener(_onModeChanged);
    _observedEngine?.removeListener(_sync);
    _observedEngine = null;
    unawaited(widget.pictureInPicture.disable());
    super.dispose();
  }

  void _onCubitState(NativePlayerState state) {
    _observeEngine(state.engine);
    _sync();
  }

  void _observeEngine(NativePlayerEngine? engine) {
    if (identical(engine, _observedEngine)) {
      return;
    }
    _observedEngine?.removeListener(_sync);
    _observedEngine = engine;
    engine?.addListener(_sync);
  }

  void _sync() {
    if (!mounted || !widget.enabled) {
      return;
    }
    final PictureInPictureConfig config = nativePlayerPipConfig(
      state: _cubit.state,
      hasNextEpisode: _cubit.hasNextEpisode,
      videoSize: _currentVideoSize(),
      strings: S.of(context),
    );
    if (config == _lastConfig) {
      return;
    }
    _lastConfig = config;
    unawaited(widget.pictureInPicture.configure(config));
  }

  Size? _currentVideoSize() {
    final NativePlayerEngine? engine = _observedEngine;
    if (engine != null) {
      final Size size = engine.value.size;
      if (isUsableVideoSize(size)) {
        _lastVideoSize = size;
      }
    }
    return _lastVideoSize;
  }

  void _onAction(PictureInPictureAction action) {
    switch (action) {
      case PictureInPictureAction.togglePlayback:
        unawaited(_cubit.togglePlayPause());
        return;
      case PictureInPictureAction.nextEpisode:
        if (_cubit.hasNextEpisode) {
          unawaited(_cubit.playNext());
        }
        return;
    }
  }

  void _onModeChanged() {
    final bool inPictureInPicture =
        widget.pictureInPicture.inPictureInPicture.value;
    if (inPictureInPicture == _wasInPictureInPicture) {
      return;
    }
    _wasInPictureInPicture = inPictureInPicture;
    if (inPictureInPicture) {
      widget.onEnter();
    } else {
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
