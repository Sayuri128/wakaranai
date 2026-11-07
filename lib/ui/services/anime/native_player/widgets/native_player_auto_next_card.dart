import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class NativePlayerAutoNextCard extends StatelessWidget {
  const NativePlayerAutoNextCard({
    super.key,
    required this.secondsLeft,
    required this.onPlayNow,
    required this.onCancel,
  });

  final int secondsLeft;
  final VoidCallback onPlayNow;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final S strings = S.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            strings.native_player_auto_next_countdown(secondsLeft),
            style: semibold(size: 15, color: AppColors.onMedia),
          ),
          const SizedBox(height: 10),
          _buildProgress(),
          const SizedBox(height: 12),
          _buildActions(strings),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final double fraction = secondsLeft / kAutoNextCountdownSeconds;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 3,
        color: AppColors.primary,
        backgroundColor: AppColors.onMedia.withValues(alpha: 0.24),
      ),
    );
  }

  Widget _buildActions(S strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(foregroundColor: AppColors.onMedia),
          child: Text(strings.native_player_auto_next_cancel),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onPlayNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(strings.native_player_auto_next_play_now),
        ),
      ],
    );
  }
}
