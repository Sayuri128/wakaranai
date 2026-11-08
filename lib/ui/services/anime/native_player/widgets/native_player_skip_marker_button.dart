import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

String skipMarkerLabel(PlayableSkipType type) {
  switch (type) {
    case PlayableSkipType.intro:
      return S.current.player_skip_intro;
    case PlayableSkipType.outro:
      return S.current.player_skip_outro;
    case PlayableSkipType.recap:
      return S.current.player_skip_recap;
  }
}

String autoSkippedLabel(PlayableSkipType type) {
  switch (type) {
    case PlayableSkipType.intro:
      return S.current.player_skip_skipped_intro;
    case PlayableSkipType.outro:
      return S.current.player_skip_skipped_outro;
    case PlayableSkipType.recap:
      return S.current.player_skip_skipped_recap;
  }
}

class NativePlayerSkipMarkerButton extends StatelessWidget {
  const NativePlayerSkipMarkerButton({
    super.key,
    required this.type,
    required this.onSkip,
  });

  final PlayableSkipType type;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.onMedia.withValues(alpha: 0.24)),
      ),
      child: InkWell(
        borderRadius: radius,
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onSkip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.skip_next_rounded,
                size: 20,
                color: AppColors.onMedia,
              ),
              const SizedBox(width: 8),
              Text(
                skipMarkerLabel(type),
                style: semibold(size: 14, color: AppColors.onMedia),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
