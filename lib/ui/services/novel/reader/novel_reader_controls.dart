import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_controls.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class NovelReaderBottomBar extends StatelessWidget {
  const NovelReaderBottomBar({
    super.key,
    required this.fraction,
    required this.hasPrevious,
    required this.hasNext,
    required this.onSeek,
    required this.onPrevious,
    required this.onNext,
    required this.onSettings,
  });

  final double fraction;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<double> onSeek;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        40,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(child: _ProgressPill(fraction: fraction)),
          const SizedBox(height: 8),
          _ProgressSlider(fraction: fraction, onSeek: onSeek),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              ReaderRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              _ChapterStepButton(
                icon: Icons.skip_previous_rounded,
                tooltip: S.current.novel_reader_previous_chapter,
                enabled: hasPrevious,
                onTap: onPrevious,
              ),
              const SizedBox(width: 12),
              _ChapterStepButton(
                icon: Icons.skip_next_rounded,
                tooltip: S.current.novel_reader_next_chapter,
                enabled: hasNext,
                onTap: onNext,
              ),
              const Spacer(),
              ReaderRoundButton(
                icon: Icons.text_fields_rounded,
                onTap: onSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        S.current.novel_progress_percent((fraction * 100).floor()),
        style: medium(size: 13, color: AppColors.onMedia),
      ),
    );
  }
}

class _ProgressSlider extends StatelessWidget {
  const _ProgressSlider({required this.fraction, required this.onSeek});

  final double fraction;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.16),
      ),
      child: Slider(
        value: fraction.clamp(0.0, 1.0).toDouble(),
        onChanged: onSeek,
      ),
    );
  }
}

class _ChapterStepButton extends StatelessWidget {
  const _ChapterStepButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.35,
        child: IgnorePointer(
          ignoring: !enabled,
          child: ReaderRoundButton(icon: icon, onTap: onTap),
        ),
      ),
    );
  }
}

class NovelNextChapterButton extends StatelessWidget {
  const NovelNextChapterButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  S.current.novel_reader_next_chapter_named(title.trim()),
                  style: semibold(size: 15, color: AppColors.mainBlack),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: AppColors.mainBlack),
            ],
          ),
        ),
      ),
    );
  }
}
