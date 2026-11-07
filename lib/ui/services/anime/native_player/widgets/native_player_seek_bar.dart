import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

String formatPlaybackDuration(Duration duration) {
  final Duration safeDuration =
      duration.isNegative ? Duration.zero : duration;
  final int hours = safeDuration.inHours;
  final String minutes =
      safeDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final String seconds =
      safeDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

Duration bufferedEndOf(VideoPlayerValue value) {
  Duration end = Duration.zero;
  for (final DurationRange range in value.buffered) {
    if (range.end > end) {
      end = range.end;
    }
  }
  return end;
}

class NativePlayerSeekBar extends StatefulWidget {
  const NativePlayerSeekBar({
    super.key,
    required this.playback,
    required this.onSeek,
    required this.onScrubStart,
  });

  final ValueListenable<VideoPlayerValue> playback;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onScrubStart;

  @override
  State<NativePlayerSeekBar> createState() => _NativePlayerSeekBarState();
}

class _NativePlayerSeekBarState extends State<NativePlayerSeekBar> {
  double? _scrubMilliseconds;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.playback,
      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
        return _buildRow(value);
      },
    );
  }

  Widget _buildRow(VideoPlayerValue value) {
    final double totalMilliseconds =
        value.duration.inMilliseconds.toDouble();
    final bool seekable = totalMilliseconds > 0;
    final double maxValue = seekable ? totalMilliseconds : 1;
    final double positionMilliseconds = _scrubMilliseconds ??
        value.position.inMilliseconds.toDouble();
    final double sliderValue =
        math.min(math.max(positionMilliseconds, 0), maxValue);
    final double bufferedValue = math.min(
      math.max(bufferedEndOf(value).inMilliseconds.toDouble(), 0),
      maxValue,
    );
    final Duration shownPosition =
        Duration(milliseconds: sliderValue.round());

    return Row(
      children: <Widget>[
        _buildTimeLabel(formatPlaybackDuration(shownPosition)),
        Expanded(
          child: SliderTheme(
            data: _sliderTheme(context),
            child: Slider(
              value: seekable ? sliderValue : 0,
              secondaryTrackValue: seekable ? bufferedValue : null,
              max: maxValue,
              onChangeStart: seekable ? _handleScrubStart : null,
              onChanged: seekable ? _handleScrubUpdate : null,
              onChangeEnd: seekable ? _handleScrubEnd : null,
            ),
          ),
        ),
        _buildTimeLabel(formatPlaybackDuration(value.duration)),
      ],
    );
  }

  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      trackHeight: 3,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.onMedia.withValues(alpha: 0.24),
      secondaryActiveTrackColor: AppColors.onMedia.withValues(alpha: 0.5),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.16),
      disabledActiveTrackColor: AppColors.onMedia.withValues(alpha: 0.24),
      disabledInactiveTrackColor: AppColors.onMedia.withValues(alpha: 0.24),
      disabledThumbColor: AppColors.onMedia.withValues(alpha: 0.5),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
    );
  }

  Widget _buildTimeLabel(String text) {
    return SizedBox(
      width: 64,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: medium(size: 12, color: AppColors.onMedia),
      ),
    );
  }

  void _handleScrubStart(double milliseconds) {
    widget.onScrubStart();
    setState(() {
      _scrubMilliseconds = milliseconds;
    });
  }

  void _handleScrubUpdate(double milliseconds) {
    setState(() {
      _scrubMilliseconds = milliseconds;
    });
  }

  void _handleScrubEnd(double milliseconds) {
    setState(() {
      _scrubMilliseconds = null;
    });
    widget.onSeek(Duration(milliseconds: milliseconds.round()));
  }
}
