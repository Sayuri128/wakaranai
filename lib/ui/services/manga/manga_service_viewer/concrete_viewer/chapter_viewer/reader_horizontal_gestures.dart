import 'package:flutter/material.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ReaderHorizontalGestures extends StatelessWidget {
  const ReaderHorizontalGestures({
    super.key,
    required this.mode,
    required this.controlsEnabled,
    required this.pageController,
  });

  static const bool _showGestureOverlay = false;

  final ChapterViewMode mode;
  final bool controlsEnabled;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    if (!controlsEnabled) {
      return const SizedBox();
    }

    final bool leftToRight = mode == ChapterViewMode.leftToRight;
    return TransparentPointer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildTapZone(
                context,
                label: leftToRight ? "Prev" : "Next",
                onTap: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                },
              ),
              _buildTapZone(
                context,
                label: leftToRight ? "Next" : "Prev",
                onTap: () {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTapZone(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: MediaQuery.of(context).size.height * .80,
        width: MediaQuery.of(context).size.width * .2,
        decoration: BoxDecoration(
          color: _showGestureOverlay
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showGestureOverlay
              ? Center(
                  child: Text(
                    label,
                    style: semibold(size: 24).apply(
                      shadows: <Shadow>[
                        BoxShadow(
                          color: AppColors.mainBlack,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
