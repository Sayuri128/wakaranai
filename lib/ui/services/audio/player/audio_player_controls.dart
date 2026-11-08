import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/audiobook_player/audiobook_player_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/ui/services/audio/player/audio_player_sheets.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AudioPlayerSeekBar extends StatefulWidget {
  const AudioPlayerSeekBar({super.key, required this.state});

  final AudiobookPlayerState state;

  @override
  State<AudioPlayerSeekBar> createState() => _AudioPlayerSeekBarState();
}

class _AudioPlayerSeekBarState extends State<AudioPlayerSeekBar> {
  double? _dragFraction;

  double _fractionOf(AudiobookPlayerState state) {
    final int total = state.duration.inMilliseconds;
    if (total <= 0) {
      return 0;
    }
    return (state.position.inMilliseconds / total).clamp(0.0, 1.0).toDouble();
  }

  Duration _positionAt(double fraction) {
    return Duration(
      milliseconds: (widget.state.duration.inMilliseconds * fraction).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AudiobookPlayerState state = widget.state;
    final bool seekable = state.status == AudiobookStatus.ready &&
        state.duration > Duration.zero;
    final double fraction = _dragFraction ?? _fractionOf(state);
    final Duration shown = _dragFraction == null
        ? state.position
        : _positionAt(_dragFraction!);
    final Duration remaining = state.duration - shown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.overlay(0.12),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.16),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: fraction,
              onChangeStart: seekable
                  ? (double value) => setState(() => _dragFraction = value)
                  : null,
              onChanged: seekable
                  ? (double value) => setState(() => _dragFraction = value)
                  : null,
              onChangeEnd: seekable ? _commitSeek : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Text(
                  AudioProgress.formatClock(shown),
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
                const Spacer(),
                Text(
                  '-${AudioProgress.formatClock(remaining)}',
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _commitSeek(double value) {
    setState(() => _dragFraction = null);
    unawaited(context.read<AudiobookPlayerCubit>().seek(_positionAt(value)));
  }
}

class AudioPlayerTransport extends StatelessWidget {
  const AudioPlayerTransport({super.key, required this.state});

  final AudiobookPlayerState state;

  @override
  Widget build(BuildContext context) {
    final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
    final bool ready = state.status == AudiobookStatus.ready;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        AudioPlayerIconButton(
          icon: Icons.skip_previous_rounded,
          tooltip: S.of(context).audio_player_previous_track,
          onTap: () => unawaited(player.previous()),
        ),
        _SkipButton(
          seconds: player.skipBackwardInterval.inSeconds,
          forward: false,
          tooltip: S.of(context).audio_player_rewind(
                player.skipBackwardInterval.inSeconds,
              ),
          onTap: ready ? () => unawaited(player.skipBackward()) : null,
        ),
        _PlayPauseButton(state: state),
        _SkipButton(
          seconds: player.skipForwardInterval.inSeconds,
          forward: true,
          tooltip: S.of(context).audio_player_forward(
                player.skipForwardInterval.inSeconds,
              ),
          onTap: ready ? () => unawaited(player.skipForward()) : null,
        ),
        AudioPlayerIconButton(
          icon: Icons.skip_next_rounded,
          tooltip: S.of(context).audio_player_next_track,
          onTap: state.hasNext ? () => unawaited(player.next()) : null,
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.state});

  final AudiobookPlayerState state;

  bool get _busy {
    return state.status == AudiobookStatus.loading ||
        (state.buffering && state.playing);
  }

  @override
  Widget build(BuildContext context) {
    final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
    return Tooltip(
      message: state.playing
          ? S.of(context).audio_player_pause
          : S.of(context).audio_player_play,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => unawaited(player.togglePlay()),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Center(child: _buildIcon()),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (_busy) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.mainBlack,
        ),
      );
    }
    return Icon(
      state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
      size: 40,
      color: AppColors.mainBlack,
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.seconds,
    required this.forward,
    required this.tooltip,
    required this.onTap,
  });

  final int seconds;
  final bool forward;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = onTap == null ? AppColors.mainGrey : AppColors.mainWhite;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.flip(
                flipX: forward,
                child: Icon(Icons.replay_rounded, size: 44, color: color),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('$seconds', style: semibold(size: 11, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioPlayerIconButton extends StatelessWidget {
  const AudioPlayerIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 32,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = onTap == null ? AppColors.mainGrey : AppColors.mainWhite;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: size,
      icon: Icon(icon, color: color),
    );
  }
}

class AudioPlayerBottomBar extends StatelessWidget {
  const AudioPlayerBottomBar({super.key, required this.state});

  final AudiobookPlayerState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              AudioPlayerIconButton(
                icon: Icons.keyboard_arrow_down_rounded,
                tooltip: S.of(context).audio_player_close,
                size: 28,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              _SpeedButton(speed: state.speed),
              _SleepTimerButton(state: state),
              AudioPlayerIconButton(
                icon: Icons.format_list_bulleted_rounded,
                tooltip: S.of(context).audio_player_tracks,
                size: 26,
                onTap: () => unawaited(showAudioTracksSheet(context)),
              ),
              AudioPlayerIconButton(
                icon: Icons.more_horiz_rounded,
                tooltip: S.of(context).audio_player_more,
                size: 26,
                onTap: () => unawaited(showAudioPlayerMoreSheet(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.speed});

  final double speed;

  @override
  Widget build(BuildContext context) {
    final bool changed = speed != 1.0;
    return Tooltip(
      message: S.of(context).audio_player_speed,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => unawaited(showAudioSpeedSheet(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            formatAudioSpeed(speed),
            style: semibold(
              size: 15,
              color: changed ? AppColors.primary : AppColors.mainWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({required this.state});

  final AudiobookPlayerState state;

  String? _label(BuildContext context) {
    final AudiobookSleepTimer timer = state.sleepTimer;
    if (timer.mode == AudiobookSleepMode.endOfTrack) {
      return S.of(context).audio_sleep_end_of_track_short;
    }
    if (timer.mode == AudiobookSleepMode.timer) {
      final int minutes = (timer.remaining(DateTime.now()).inSeconds / 60).ceil();
      return S.of(context).audio_sleep_minutes_short(minutes);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? label = _label(context);
    final Color color =
        state.sleepTimer.isActive ? AppColors.primary : AppColors.mainWhite;
    return Tooltip(
      message: S.of(context).audio_sleep_timer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => unawaited(showAudioSleepTimerSheet(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.bedtime_outlined, size: 24, color: color),
              if (label != null) ...<Widget>[
                const SizedBox(width: 4),
                Text(label, style: medium(size: 12, color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
