import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ReaderRoundButton extends StatelessWidget {
  const ReaderRoundButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: AppColors.onMedia, size: 22),
        ),
      ),
    );
  }
}

class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: Text(
        title,
        style: semibold(size: 16, color: AppColors.onMedia),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.slider,
    required this.onSettings,
    this.translateButton,
  });

  final int currentPage;
  final int totalPages;
  final Widget slider;
  final VoidCallback onSettings;
  final Widget? translateButton;

  @override
  Widget build(BuildContext context) {
    final Widget? translateButton = this.translateButton;
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
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$currentPage/$totalPages',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              ReaderRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(child: slider),
              const SizedBox(width: 12),
              if (translateButton != null) ...<Widget>[
                translateButton,
                const SizedBox(width: 8),
              ],
              ReaderRoundButton(
                icon: Icons.settings_rounded,
                onTap: onSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReaderPageCounter extends StatelessWidget {
  const ReaderPageCounter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.controlsVisible,
  });

  final int currentPage;
  final int totalPages;
  final bool controlsVisible;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      right: 0,
      left: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: controlsVisible ? 0.0 : 1.0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$currentPage/$totalPages',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReaderPageError extends StatelessWidget {
  const ReaderPageError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: AppColors.onMedia.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: AppColors.onMedia,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              S.current.concrete_viewer_retry_button,
              style: medium(size: 14, color: AppColors.onMedia),
            ),
          ),
        ],
      ),
    );
  }
}
