import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';

class NativePlayerBottomBar extends StatelessWidget {
  const NativePlayerBottomBar({
    super.key,
    required this.isPlaying,
    required this.onBack,
    required this.onTogglePlay,
    required this.onNextEpisode,
    required this.onSubtitles,
    required this.onSpeed,
    required this.onQuality,
    required this.onOpenWebPlayer,
    required this.onLock,
    this.subtitlesActive = false,
  });

  final bool isPlaying;
  final bool subtitlesActive;
  final VoidCallback onBack;
  final VoidCallback onTogglePlay;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onSubtitles;
  final VoidCallback onSpeed;
  final VoidCallback? onQuality;
  final VoidCallback onOpenWebPlayer;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    final S strings = S.of(context);
    return Row(
      children: <Widget>[
        _buildButton(
          icon: Icons.arrow_back_rounded,
          tooltip: strings.common_go_back,
          onPressed: onBack,
        ),
        _buildButton(
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          tooltip: isPlaying ? strings.native_player_pause : strings.native_player_play,
          onPressed: onTogglePlay,
          size: 32,
        ),
        if (onNextEpisode != null)
          _buildButton(
            icon: Icons.skip_next_rounded,
            tooltip: strings.native_player_next_episode,
            onPressed: onNextEpisode!,
          ),
        const Spacer(),
        if (onSubtitles != null)
          _buildButton(
            icon: subtitlesActive
                ? Icons.closed_caption_rounded
                : Icons.closed_caption_off_outlined,
            tooltip: strings.native_player_subtitles,
            onPressed: onSubtitles!,
            highlighted: subtitlesActive,
          ),
        _buildButton(
          icon: Icons.speed_rounded,
          tooltip: strings.native_player_speed,
          onPressed: onSpeed,
        ),
        if (onQuality != null)
          _buildButton(
            icon: Icons.high_quality_rounded,
            tooltip: strings.native_player_quality,
            onPressed: onQuality!,
          ),
        _buildButton(
          icon: Icons.public_rounded,
          tooltip: strings.native_player_open_web_player,
          onPressed: onOpenWebPlayer,
        ),
        _buildButton(
          icon: Icons.lock_outline_rounded,
          tooltip: strings.native_player_lock,
          onPressed: onLock,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    double size = 24,
    bool highlighted = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: size,
      color: highlighted ? AppColors.primary : AppColors.onMedia,
      icon: Icon(icon),
    );
  }
}
