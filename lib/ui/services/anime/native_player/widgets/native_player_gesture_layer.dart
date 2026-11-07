import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_seek_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const Duration kScrubRangePerScreenWidth = Duration(seconds: 90);
const double _axisLockDistance = 8;
const double _levelDragFraction = 0.75;
const double _pinchFillThreshold = 1.08;
const double _pinchFitThreshold = 0.92;
const Duration _levelIndicatorLinger = Duration(milliseconds: 600);
const Duration _fadeDuration = Duration(milliseconds: 150);

enum _DragMode { none, undecided, scrub, brightness, volume, pinch }

Duration scrubTarget({
  required Duration start,
  required double dragDistance,
  required double width,
  required Duration duration,
}) {
  if (width <= 0) {
    return start;
  }
  final double fraction = dragDistance / width;
  final int offsetMilliseconds =
      (fraction * kScrubRangePerScreenWidth.inMilliseconds).round();
  final Duration target = start + Duration(milliseconds: offsetMilliseconds);
  if (target < Duration.zero) {
    return Duration.zero;
  }
  if (duration > Duration.zero && target > duration) {
    return duration;
  }
  return target;
}

PlayerFitMode? fitModeForPinch(double scale) {
  if (scale >= _pinchFillThreshold) {
    return PlayerFitMode.fill;
  }
  if (scale <= _pinchFitThreshold) {
    return PlayerFitMode.fit;
  }
  return null;
}

class NativePlayerGestureLayer extends StatefulWidget {
  const NativePlayerGestureLayer({
    super.key,
    required this.playback,
    required this.deviceControls,
    required this.locked,
    required this.holdActive,
    required this.holdSpeed,
    required this.onTap,
    required this.onDoubleTapAt,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onSeek,
    required this.onFitModeRequested,
    required this.onLockedGesture,
  });

  final ValueListenable<VideoPlayerValue> playback;
  final PlayerDeviceControls deviceControls;
  final bool locked;
  final bool holdActive;
  final double holdSpeed;
  final VoidCallback onTap;
  final void Function(Offset position, Size size) onDoubleTapAt;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<PlayerFitMode> onFitModeRequested;
  final VoidCallback onLockedGesture;

  @override
  State<NativePlayerGestureLayer> createState() =>
      _NativePlayerGestureLayerState();
}

class _NativePlayerGestureLayerState extends State<NativePlayerGestureLayer> {
  _DragMode _mode = _DragMode.none;
  Offset _dragOrigin = Offset.zero;
  Offset? _doubleTapPosition;
  Duration _scrubStart = Duration.zero;
  Duration _scrubTarget = Duration.zero;
  Duration _scrubDuration = Duration.zero;
  double _pinchScale = 1;
  double? _levelStart;
  double? _level;
  double _lastSentLevel = -1;
  _DragMode? _visibleLevelMode;
  Timer? _levelIndicatorTimer;
  bool _holding = false;

  @override
  void dispose() {
    _levelIndicatorTimer?.cancel();
    super.dispose();
  }

  Size get _size => context.size ?? Size.zero;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final Offset? position = _doubleTapPosition;
    if (position == null) {
      return;
    }
    widget.onDoubleTapAt(position, _size);
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.locked) {
      widget.onLockedGesture();
      return;
    }
    _holding = true;
    widget.onHoldStart();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _releaseHold();
  }

  void _releaseHold() {
    if (!_holding) {
      return;
    }
    _holding = false;
    widget.onHoldEnd();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (widget.locked) {
      _mode = _DragMode.none;
      return;
    }
    if (_mode == _DragMode.none) {
      _beginGesture(details);
      return;
    }
    _reconfigureGesture(details);
  }

  void _beginGesture(ScaleStartDetails details) {
    _dragOrigin = details.localFocalPoint;
    _pinchScale = 1;
    setState(() {
      _mode = details.pointerCount >= 2 ? _DragMode.pinch : _DragMode.undecided;
    });
  }

  void _reconfigureGesture(ScaleStartDetails details) {
    if (details.pointerCount < 2) {
      return;
    }
    if (_mode == _DragMode.brightness || _mode == _DragMode.volume) {
      return;
    }
    _pinchScale = 1;
    setState(() {
      _mode = _DragMode.pinch;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (widget.locked || _mode == _DragMode.none) {
      return;
    }
    if (_mode == _DragMode.pinch) {
      _pinchScale = details.scale;
      return;
    }
    final Offset delta = details.localFocalPoint - _dragOrigin;
    if (_mode == _DragMode.undecided) {
      _decideMode(delta);
    }
    switch (_mode) {
      case _DragMode.scrub:
        _updateScrub(delta.dx);
      case _DragMode.brightness:
      case _DragMode.volume:
        _updateLevel(delta.dy);
      case _DragMode.none:
      case _DragMode.undecided:
      case _DragMode.pinch:
        break;
    }
  }

  void _decideMode(Offset delta) {
    if (delta.distance < _axisLockDistance) {
      return;
    }
    if (delta.dx.abs() > delta.dy.abs()) {
      _beginScrub();
      return;
    }
    _beginLevel(
      _dragOrigin.dx < _size.width / 2 ? _DragMode.brightness : _DragMode.volume,
    );
  }

  void _beginScrub() {
    final VideoPlayerValue value = widget.playback.value;
    if (!value.isInitialized || value.duration <= Duration.zero) {
      setState(() {
        _mode = _DragMode.none;
      });
      return;
    }
    setState(() {
      _mode = _DragMode.scrub;
      _scrubStart = value.position;
      _scrubTarget = value.position;
      _scrubDuration = value.duration;
    });
  }

  void _updateScrub(double dragDistance) {
    final Duration target = scrubTarget(
      start: _scrubStart,
      dragDistance: dragDistance,
      width: _size.width,
      duration: _scrubDuration,
    );
    if (target == _scrubTarget) {
      return;
    }
    setState(() {
      _scrubTarget = target;
    });
  }

  void _beginLevel(_DragMode mode) {
    _levelIndicatorTimer?.cancel();
    setState(() {
      _mode = mode;
      _visibleLevelMode = mode;
      _levelStart = null;
      _level = null;
    });
    unawaited(_loadLevelStart(mode));
  }

  Future<void> _loadLevelStart(_DragMode mode) async {
    final double? current = mode == _DragMode.brightness
        ? await widget.deviceControls.readBrightness()
        : await widget.deviceControls.readVolume();
    if (!mounted || _mode != mode) {
      return;
    }
    setState(() {
      _levelStart = current ?? 0.5;
      _level = _levelStart;
      _lastSentLevel = _levelStart!;
    });
  }

  void _updateLevel(double verticalDistance) {
    final double? start = _levelStart;
    final double height = _size.height;
    if (start == null || height <= 0) {
      return;
    }
    final double change = -verticalDistance / (height * _levelDragFraction);
    final double level = (start + change).clamp(0.0, 1.0);
    setState(() {
      _level = level;
    });
    if ((level - _lastSentLevel).abs() < 0.01) {
      return;
    }
    _lastSentLevel = level;
    if (_mode == _DragMode.brightness) {
      unawaited(widget.deviceControls.setBrightness(level));
    } else {
      unawaited(widget.deviceControls.setVolume(level));
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (details.pointerCount > 0) {
      return;
    }
    final _DragMode finishedMode = _mode;
    setState(() {
      _mode = _DragMode.none;
    });
    switch (finishedMode) {
      case _DragMode.scrub:
        widget.onSeek(_scrubTarget);
      case _DragMode.pinch:
        _finishPinch();
      case _DragMode.brightness:
      case _DragMode.volume:
        _hideLevelIndicatorLater();
      case _DragMode.none:
      case _DragMode.undecided:
        break;
    }
  }

  void _finishPinch() {
    final PlayerFitMode? mode = fitModeForPinch(_pinchScale);
    _pinchScale = 1;
    if (mode != null) {
      widget.onFitModeRequested(mode);
    }
  }

  void _hideLevelIndicatorLater() {
    _levelIndicatorTimer?.cancel();
    _levelIndicatorTimer = Timer(_levelIndicatorLinger, () {
      if (mounted) {
        setState(() {
          _visibleLevelMode = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildDetector(),
        _buildHoldIndicator(),
        _buildScrubIndicator(),
        _buildLevelIndicator(_DragMode.brightness),
        _buildLevelIndicator(_DragMode.volume),
      ],
    );
  }

  Widget _buildDetector() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: _releaseHold,
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
    );
  }

  Widget _buildHoldIndicator() {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: IgnorePointer(
          child: AnimatedOpacity(
            duration: _fadeDuration,
            opacity: widget.holdActive ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      speedMultiplierLabel(widget.holdSpeed),
                      style: semibold(size: 14, color: AppColors.onMedia),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.fast_forward_rounded,
                      size: 18,
                      color: AppColors.onMedia,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrubIndicator() {
    final bool visible = _mode == _DragMode.scrub;
    final Duration delta = _scrubTarget - _scrubStart;
    final String sign = delta.isNegative ? '−' : '+';
    final String deltaLabel = '$sign${formatPlaybackDuration(delta.abs())}';
    return Center(
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: visible ? 1 : 0,
          child: _buildPill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${formatPlaybackDuration(_scrubTarget)} / '
                  '${formatPlaybackDuration(_scrubDuration)}',
                  style: semibold(size: 18, color: AppColors.onMedia),
                ),
                const SizedBox(height: 2),
                Text(
                  deltaLabel,
                  style: medium(
                    size: 14,
                    color: AppColors.onMedia.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(_DragMode mode) {
    final bool brightness = mode == _DragMode.brightness;
    final bool visible = _visibleLevelMode == mode;
    final double level = _level ?? 0;
    return Align(
      alignment: brightness ? const Alignment(-0.8, 0) : const Alignment(0.8, 0),
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: _fadeDuration,
          opacity: visible ? 1 : 0,
          child: _buildPill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  _levelIcon(brightness, level),
                  size: 20,
                  color: AppColors.onMedia,
                ),
                const SizedBox(height: 8),
                _buildLevelBar(level),
                const SizedBox(height: 8),
                Text(
                  '${(level * 100).round()}%',
                  style: medium(size: 12, color: AppColors.onMedia),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _levelIcon(bool brightness, double level) {
    if (brightness) {
      return Icons.brightness_6_rounded;
    }
    if (level <= 0) {
      return Icons.volume_off_rounded;
    }
    if (level < 0.5) {
      return Icons.volume_down_rounded;
    }
    return Icons.volume_up_rounded;
  }

  Widget _buildLevelBar(double level) {
    return SizedBox(
      width: 6,
      height: 96,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: AppColors.onMedia.withValues(alpha: 0.24)),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: level.clamp(0.0, 1.0),
                widthFactor: 1,
                child: ColoredBox(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
