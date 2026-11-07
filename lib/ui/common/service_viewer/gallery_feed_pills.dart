import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFeedPills extends StatelessWidget {
  const GalleryFeedPills({
    super.key,
    required this.feeds,
    required this.selectedFeedId,
    required this.onSelected,
  });

  final List<GalleryFeed> feeds;
  final String? selectedFeedId;
  final ValueChanged<String> onSelected;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: S.current.feeds_row_label,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: feeds.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 8),
          itemBuilder: (BuildContext context, int index) {
            final GalleryFeed feed = feeds[index];
            return GalleryFeedPill(
              title: feed.title,
              selected: feed.id == selectedFeedId,
              onTap: () => onSelected(feed.id),
            );
          },
        ),
      ),
    );
  }
}

class GalleryFeedPill extends StatelessWidget {
  const GalleryFeedPill({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.overlay(0.06),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              widthFactor: 1,
              child: Text(
                title,
                maxLines: 1,
                style: medium(
                  size: 14,
                  color: selected ? AppColors.mainBlack : AppColors.mainWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
