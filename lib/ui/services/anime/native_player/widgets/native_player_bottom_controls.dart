import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_fit_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';

class NativePlayerBottomControls extends StatelessWidget {
  const NativePlayerBottomControls({
    super.key,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.fitMode,
    required this.onFitMode,
    required this.onLock,
    this.showEpisodeNavigation = false,
    this.onPreviousEpisode,
    this.onNextEpisode,
  });

  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final PlayerFitMode fitMode;
  final VoidCallback onFitMode;
  final VoidCallback onLock;
  final bool showEpisodeNavigation;
  final VoidCallback? onPreviousEpisode;
  final VoidCallback? onNextEpisode;

  @override
  Widget build(BuildContext context) {
    final S strings = S.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildButton(
              icon: Icons.lock_outline_rounded,
              tooltip: strings.native_player_lock,
              onPressed: onLock,
            ),
          ),
        ),
        _buildTransport(strings),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _buildButton(
              icon: fitModeIcon(fitMode),
              tooltip: strings.native_player_fit_mode,
              onPressed: onFitMode,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransport(S strings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showEpisodeNavigation)
          _buildButton(
            icon: Icons.skip_previous_rounded,
            tooltip: strings.player_previous_episode,
            onPressed: onPreviousEpisode,
            size: 30,
          ),
        if (showEpisodeNavigation) const SizedBox(width: 16),
        _buildButton(
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          tooltip:
              isPlaying ? strings.native_player_pause : strings.native_player_play,
          onPressed: onTogglePlay,
          size: 44,
        ),
        if (showEpisodeNavigation) const SizedBox(width: 16),
        if (showEpisodeNavigation)
          _buildButton(
            icon: Icons.skip_next_rounded,
            tooltip: strings.native_player_next_episode,
            onPressed: onNextEpisode,
            size: 30,
          ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    double size = 24,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: size,
      color: AppColors.onMedia,
      disabledColor: AppColors.onMedia.withValues(alpha: 0.3),
      icon: Icon(icon),
    );
  }
}
