import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filter_chip.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFilterSection extends StatelessWidget {
  const GalleryFilterSection({
    super.key,
    required this.title,
    required this.child,
    this.count = 0,
    this.onClear,
  });

  final String title;
  final Widget child;
  final int count;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GalleryFilterCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: semibold(size: 15),
                  ),
                ),
                if (count > 0) ...<Widget>[
                  const SizedBox(width: 8),
                  GalleryFilterCountBadge(count: count),
                ],
              ],
            ),
          ),
          _buildClearButton(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    final VoidCallback? clear = onClear;
    return AnimatedOpacity(
      opacity: clear == null ? 0 : 1,
      duration: const Duration(milliseconds: 150),
      child: IgnorePointer(
        ignoring: clear == null,
        child: TextButton(
          onPressed: clear ?? () {},
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            S.current.filters_clear_section,
            style: medium(size: 13, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class GalleryFilterCard extends StatelessWidget {
  const GalleryFilterCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

InputDecoration galleryFilterInputDecoration({
  required String hint,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  final OutlineInputBorder idleBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.overlay(0.06)),
  );
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.overlay(0.06),
    hintText: hint,
    hintStyle: regular(size: 14, color: AppColors.mainGrey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: idleBorder,
    enabledBorder: idleBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
    ),
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
  );
}
