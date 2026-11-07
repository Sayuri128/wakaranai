import 'dart:async';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/playlist_sheets.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/skip_markers.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_auto_next_card.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_bottom_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_fit_mode.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_gesture_layer.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_seek_bar.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_size_reporter.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_skip_marker_button.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_top_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const Duration _controlsAutoHideDelay = Duration(seconds: 3);
const Duration _lockHintDuration = Duration(milliseconds: 2500);
const Duration _seekIndicatorDuration = Duration(milliseconds: 700);
const Duration _fadeDuration = Duration(milliseconds: 200);
const Duration _flashMessageDuration = Duration(milliseconds: 1200);
const double _skipOpeningVisibleFraction = 0.3;
const double _initialBottomPanelHeight = 120;
const double _bottomPanelClearance = 8;
const double _hiddenCaptionInset = 32;
const double _hiddenAutoNextInset = 16;

enum _SeekSide { backward, forward }

class NativePlayerOverlay extends StatefulWidget {
  const NativePlayerOverlay({
    super.key,
    required this.playback,
    required this.deviceControls,
    required this.state,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onOpenWebPlayer,
    this.onPictureInPicture,
  });

  final ValueListenable<VideoPlayerValue> playback;
  final PlayerDeviceControls deviceControls;
  final NativePlayerState state;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback onOpenWebPlayer;
  final VoidCallback? onPictureInPicture;

  @override
  State<NativePlayerOverlay> createState() => _NativePlayerOverlayState();
}

class _NativePlayerOverlayState extends State<NativePlayerOverlay> {
  bool _controlsVisible = true;
  bool _locked = false;
  bool _lockHintVisible = false;
  Timer? _hideTimer;
  Timer? _lockHintTimer;
  Timer? _seekIndicatorTimer;
  Timer? _flashMessageTimer;
  String? _flashMessage;
  _SeekSide? _seekSide;
  int _seekSeconds = 0;
  double _bottomPanelHeight = _initialBottomPanelHeight;

  NativePlayerCubit get _cubit => context.read<NativePlayerCubit>();

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
  }

  @override
  void didUpdateWidget(NativePlayerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _announceAutoSkip(oldWidget.state);
    if (oldWidget.state.isPlaying == widget.state.isPlaying) {
      return;
    }
    if (widget.state.isPlaying) {
      _scheduleAutoHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _announceAutoSkip(NativePlayerState previous) {
    final PlayableSkipType? skippedType = widget.state.lastAutoSkipType;
    final bool skippedAgain =
        widget.state.autoSkipCount > previous.autoSkipCount;
    if (!skippedAgain || skippedType == null) {
      return;
    }
    _showFlashMessage(autoSkippedLabel(skippedType));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _lockHintTimer?.cancel();
    _seekIndicatorTimer?.cancel();
    _flashMessageTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    if (!widget.state.isPlaying) {
      return;
    }
    _hideTimer = Timer(_controlsAutoHideDelay, () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _registerInteraction() {
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _scheduleAutoHide();
  }

  void _handleTap() {
    if (_locked) {
      _showLockHint();
      return;
    }
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _scheduleAutoHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _handleDoubleTap(Offset tapPosition, Size overlaySize) {
    if (_locked) {
      _showLockHint();
      return;
    }
    final _SeekSide side = tapPosition.dx < overlaySize.width / 2
        ? _SeekSide.backward
        : _SeekSide.forward;
    _showSeekIndicator(side);
    final Duration offset = side == _SeekSide.backward
        ? -kNativePlayerSeekStep
        : kNativePlayerSeekStep;
    unawaited(_cubit.seekBy(offset));
  }

  void _showSeekIndicator(_SeekSide side) {
    _seekIndicatorTimer?.cancel();
    setState(() {
      if (_seekSide == side) {
        _seekSeconds += kNativePlayerSeekStep.inSeconds;
      } else {
        _seekSide = side;
        _seekSeconds = kNativePlayerSeekStep.inSeconds;
      }
    });
    _seekIndicatorTimer = Timer(_seekIndicatorDuration, () {
      if (mounted) {
        setState(() {
          _seekSide = null;
          _seekSeconds = 0;
        });
      }
    });
  }

  void _showFlashMessage(String message) {
    _flashMessageTimer?.cancel();
    setState(() {
      _flashMessage = message;
    });
    _flashMessageTimer = Timer(_flashMessageDuration, () {
      if (mounted) {
        setState(() {
          _flashMessage = null;
        });
      }
    });
  }

  void _applyFitMode(PlayerFitMode mode) {
    if (mode == widget.state.fitMode) {
      return;
    }
    unawaited(_cubit.setFitMode(mode));
    _showFlashMessage(fitModeLabel(mode));
  }

  void _cycleFitMode() {
    _applyFitMode(nextFitMode(widget.state.fitMode));
    _registerInteraction();
  }

  void _skipOpening() {
    unawaited(_cubit.skipOpening());
    _showFlashMessage(
      S.of(context).native_player_seek_forward(widget.state.skipOpeningSeconds),
    );
    _registerInteraction();
  }

  void _skipMarker(PlayableSkipMarker marker) {
    unawaited(_cubit.skipMarker(marker));
  }

  void _lock() {
    _hideTimer?.cancel();
    setState(() {
      _locked = true;
      _controlsVisible = false;
    });
    _showLockHint();
  }

  void _unlock() {
    _lockHintTimer?.cancel();
    setState(() {
      _locked = false;
      _lockHintVisible = false;
      _controlsVisible = true;
    });
    _scheduleAutoHide();
  }

  void _showLockHint() {
    _lockHintTimer?.cancel();
    setState(() {
      _lockHintVisible = true;
    });
    _lockHintTimer = Timer(_lockHintDuration, () {
      if (mounted) {
        setState(() {
          _lockHintVisible = false;
        });
      }
    });
  }

  Future<void> _openQualityPicker(List<QualityGroup> groups) async {
    _hideTimer?.cancel();
    final NativePlayerCubit cubit = _cubit;
    await showQualityPicker(
      context,
      groups: groups,
      currentStreamIndex: widget.state.streamIndex,
      selectedRenditionId: widget.state.selectedRenditionId,
      onSelected: (QualityOption option) =>
          unawaited(cubit.selectQualityOption(option)),
    );
    if (mounted) {
      _scheduleAutoHide();
    }
  }

  List<QualityGroup> _qualityGroups() {
    final List<PlayableStream> streams = _cubit.video.streams;
    return buildQualityGroups(
      streamLabels: streamQualityLabels(streams),
      currentStreamIndex: widget.state.streamIndex,
      renditions: widget.state.renditions,
      autoLabel: S.of(context).native_player_quality_auto,
    );
  }

  Future<void> _openSpeedPicker() async {
    _hideTimer?.cancel();
    await showSpeedPicker(
      context,
      selectedSpeed: widget.state.playbackSpeed,
      onSelected: (double speed) => unawaited(_cubit.setPlaybackSpeed(speed)),
    );
    _scheduleAutoHide();
  }

  Future<void> _openSubtitlePicker() async {
    _hideTimer?.cancel();
    await showSubtitlePicker(
      context,
      subtitles: _cubit.video.subtitles,
      selectedIndex: widget.state.subtitleIndex,
      onSelected: (int? index) => unawaited(_cubit.selectSubtitle(index)),
    );
    _scheduleAutoHide();
  }

  Future<void> _openMoreSheet() async {
    _hideTimer?.cancel();
    await showPlayerMoreSheet(
      context,
      fitMode: widget.state.fitMode,
      onFitModeSelected: _applyFitMode,
      onOpenWebPlayer: widget.onOpenWebPlayer,
    );
    if (mounted) {
      _scheduleAutoHide();
    }
  }

  void _updateBottomPanelHeight(Size size) {
    if (!mounted || size.height == _bottomPanelHeight) {
      return;
    }
    setState(() {
      _bottomPanelHeight = size.height;
    });
  }

  Future<void> _openEpisodesSheet() async {
    _hideTimer?.cancel();
    final NativePlayerCubit cubit = _cubit;
    await showEpisodesSheet(
      context,
      playlist: widget.state.playlist,
      watchedEpisodeUids: widget.state.watchedEpisodeUids,
      onSelected: (AnimeVideo episode) =>
          unawaited(cubit.selectEpisode(episode)),
    );
    if (mounted) {
      _scheduleAutoHide();
    }
  }

  Future<void> _openGroupsSheet() async {
    _hideTimer?.cancel();
    final NativePlayerCubit cubit = _cubit;
    await showGroupsSheet(
      context,
      playlist: widget.state.playlist,
      onSelected: (int groupIndex) => unawaited(cubit.selectGroup(groupIndex)),
    );
    if (mounted) {
      _scheduleAutoHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_locked,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _showLockHint();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildGestureLayer(),
          _buildBufferingIndicator(),
          _buildSeekIndicator(_SeekSide.backward),
          _buildSeekIndicator(_SeekSide.forward),
          _buildFlashMessage(),
          _buildCaption(),
          _buildControls(),
          _buildSkipMarkerButton(),
          _buildAutoNextCard(),
          _buildLockHint(),
        ],
      ),
    );
  }

  Widget _buildGestureLayer() {
    final NativePlayerCubit cubit = _cubit;
    return NativePlayerGestureLayer(
      playback: widget.playback,
      deviceControls: widget.deviceControls,
      locked: _locked,
      holdActive: widget.state.holdActive,
      holdSpeed: widget.state.displayedHoldSpeed,
      onTap: _handleTap,
      onDoubleTapAt: _handleDoubleTap,
      onHoldStart: () => unawaited(cubit.startHoldSpeed()),
      onHoldEnd: () => unawaited(cubit.endHoldSpeed()),
      onSeek: (Duration position) => unawaited(cubit.seekTo(position)),
      onFitModeRequested: _applyFitMode,
      onLockedGesture: _showLockHint,
    );
  }

  Widget _buildFlashMessage() {
    final String? message = _flashMessage;
    return Align(
      alignment: const Alignment(0, -0.45),
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: message == null ? 0 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message ?? '',
              style: semibold(size: 14, color: AppColors.onMedia),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoNextCard() {
    final int? secondsLeft = widget.state.autoNextSecondsLeft;
    final NativePlayerCubit cubit = _cubit;
    final bool controlsShown = _controlsVisible && !_locked;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double shownInset =
        _bottomPanelHeight - safeBottom + _bottomPanelClearance;
    return AnimatedPositioned(
      duration: _fadeDuration,
      right: 16,
      bottom: controlsShown ? shownInset : _hiddenAutoNextInset,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: _fadeDuration,
          child: _buildAutoNextContent(cubit, secondsLeft),
        ),
      ),
    );
  }

  Widget _buildSkipMarkerButton() {
    final bool controlsShown = _controlsVisible && !_locked;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double shownInset =
        _bottomPanelHeight - safeBottom + _bottomPanelClearance;
    final List<PlayableSkipMarker> markers = _cubit.skipMarkers;
    return AnimatedPositioned(
      duration: _fadeDuration,
      right: 16,
      bottom: controlsShown ? shownInset : _hiddenAutoNextInset,
      child: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.playback,
          builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
            return AnimatedSwitcher(
              duration: _fadeDuration,
              child: _buildSkipMarkerContent(markers, value),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkipMarkerContent(
    List<PlayableSkipMarker> markers,
    VideoPlayerValue value,
  ) {
    final PlayableSkipMarker? marker = _locked || markers.isEmpty
        ? null
        : activeSkipMarker(markers, value.position);
    if (marker == null || widget.state.autoNextSecondsLeft != null) {
      return const SizedBox.shrink();
    }
    return NativePlayerSkipMarkerButton(
      key: ValueKey<PlayableSkipMarker>(marker),
      type: marker.type,
      onSkip: () => _skipMarker(marker),
    );
  }

  Widget _buildAutoNextContent(NativePlayerCubit cubit, int? secondsLeft) {
    if (secondsLeft == null) {
      return const SizedBox.shrink();
    }
    return NativePlayerAutoNextCard(
      secondsLeft: secondsLeft,
      onPlayNow: () => unawaited(cubit.playNextNow()),
      onCancel: cubit.cancelAutoNext,
    );
  }

  Widget _buildBufferingIndicator() {
    return IgnorePointer(
      child: Center(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.playback,
          builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
            if (!value.isBuffering) {
              return const SizedBox.shrink();
            }
            return CircularProgressIndicator(color: AppColors.primary);
          },
        ),
      ),
    );
  }

  Widget _buildSeekIndicator(_SeekSide side) {
    final bool visible = _seekSide == side;
    final bool backward = side == _SeekSide.backward;
    final String label = backward
        ? S.of(context).native_player_seek_backward(_seekSeconds)
        : S.of(context).native_player_seek_forward(_seekSeconds);
    return Align(
      alignment: backward ? const Alignment(-0.6, 0) : const Alignment(0.6, 0),
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: visible ? 1 : 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  backward ? Icons.fast_rewind_rounded : Icons.fast_forward_rounded,
                  color: AppColors.onMedia,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(label, style: semibold(size: 15, color: AppColors.onMedia)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaption() {
    final double bottomInset = _controlsVisible && !_locked
        ? _bottomPanelHeight + _bottomPanelClearance
        : _hiddenCaptionInset;
    return AnimatedPositioned(
      duration: _fadeDuration,
      left: 48,
      right: 48,
      bottom: bottomInset,
      child: IgnorePointer(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.playback,
          builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
            final String text = value.caption.text.trim();
            if (text.isEmpty) {
              return const SizedBox.shrink();
            }
            return _buildCaptionBubble(text);
          },
        ),
      ),
    );
  }

  Widget _buildCaptionBubble(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: medium(size: 17, color: AppColors.onMedia),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final bool visible = _controlsVisible && !_locked;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: _fadeDuration,
        opacity: visible ? 1 : 0,
        child: Column(
          children: <Widget>[
            _buildTopBar(),
            const Spacer(),
            NativePlayerSizeReporter(
              onSizeChanged: _updateBottomPanelHeight,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final NativePlayerCubit cubit = _cubit;
    final bool playlistEnabled = cubit.canSwitchEpisodes;
    final bool hasSeveralGroups = widget.state.playlist.hasSeveralGroups;
    final bool hasSubtitles = cubit.video.subtitles.isNotEmpty;
    final List<QualityGroup> qualityGroups = _qualityGroups();
    final bool hasQualities = selectableQualityCount(qualityGroups) >= 2;
    return NativePlayerTopBar(
      title: widget.title,
      subtitle: widget.subtitle,
      onBack: widget.onBack,
      onEpisodes: playlistEnabled ? () => unawaited(_openEpisodesSheet()) : null,
      onGroups: playlistEnabled && hasSeveralGroups
          ? () => unawaited(_openGroupsSheet())
          : null,
      onSubtitles: hasSubtitles ? () => unawaited(_openSubtitlePicker()) : null,
      subtitlesActive: widget.state.subtitleIndex != null,
      onQuality: hasQualities
          ? () => unawaited(_openQualityPicker(qualityGroups))
          : null,
      qualityLabel: hasQualities
          ? currentQualityLabel(
              qualityGroups,
              currentStreamIndex: widget.state.streamIndex,
              selectedRenditionId: widget.state.selectedRenditionId,
            )
          : null,
      playbackSpeed: widget.state.playbackSpeed,
      onSpeed: () => unawaited(_openSpeedPicker()),
      onMore: () => unawaited(_openMoreSheet()),
      onPictureInPicture: widget.onPictureInPicture,
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildSkipOpeningRow(),
              NativePlayerSeekBar(
                playback: widget.playback,
                onScrubStart: () => _hideTimer?.cancel(),
                onSeek: (Duration position) {
                  unawaited(_cubit.seekTo(position));
                  _scheduleAutoHide();
                },
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipOpeningRow() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.playback,
      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
        if (!_skipOpeningAvailable(value)) {
          return const SizedBox.shrink();
        }
        return Align(alignment: Alignment.centerRight, child: child);
      },
      child: _buildSkipOpeningButton(),
    );
  }

  bool _skipOpeningAvailable(VideoPlayerValue value) {
    if (_cubit.skipMarkers.isNotEmpty) {
      return false;
    }
    final int totalMilliseconds = value.duration.inMilliseconds;
    if (totalMilliseconds <= 0) {
      return false;
    }
    final double watchedFraction =
        value.position.inMilliseconds / totalMilliseconds;
    return watchedFraction < _skipOpeningVisibleFraction;
  }

  Widget _buildSkipOpeningButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: Material(
        color: AppColors.onMedia.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _skipOpening,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.fast_forward_rounded,
                  size: 16,
                  color: AppColors.onMedia,
                ),
                const SizedBox(width: 6),
                Text(
                  S.of(context).native_player_skip_opening(
                        widget.state.skipOpeningSeconds,
                      ),
                  style: medium(size: 13, color: AppColors.onMedia),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final NativePlayerCubit cubit = _cubit;
    return NativePlayerBottomControls(
      isPlaying: widget.state.isPlaying,
      onTogglePlay: () {
        unawaited(cubit.togglePlayPause());
        _registerInteraction();
      },
      showEpisodeNavigation: cubit.canSwitchEpisodes,
      onPreviousEpisode: cubit.hasPreviousEpisode
          ? () => unawaited(cubit.playPrevious())
          : null,
      onNextEpisode:
          cubit.hasNextEpisode ? () => unawaited(cubit.playNext()) : null,
      fitMode: widget.state.fitMode,
      onFitMode: _cycleFitMode,
      onLock: _lock,
    );
  }

  Widget _buildLockHint() {
    final bool visible = _locked && _lockHintVisible;
    return Positioned(
      right: 24,
      bottom: 24,
      child: SafeArea(
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            duration: _fadeDuration,
            opacity: visible ? 1 : 0,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              shape: const StadiumBorder(),
              child: IconButton(
                tooltip: S.of(context).native_player_unlock,
                onPressed: _unlock,
                iconSize: 26,
                color: AppColors.onMedia,
                icon: const Icon(Icons.lock_open_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
