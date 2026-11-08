import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/filters/gallery_filters_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFiltersButton extends StatelessWidget {
  const GalleryFiltersButton({
    super.key,
    required this.filters,
    required this.selected,
    required this.onApplied,
    this.expanded = false,
  });

  static const double height = 48;

  final List<GalleryFilter> filters;
  final Map<String, FilterData> selected;
  final ValueChanged<Map<String, FilterData>> onApplied;
  final bool expanded;

  int get _activeCount => selected.length;

  Future<void> _open(BuildContext context) async {
    final Map<String, FilterData>? result = await showGalleryFiltersSheet(
      context,
      filters: filters,
      current: selected,
    );
    if (result == null) {
      return;
    }
    onApplied(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _activeCount > 0;
    final BorderRadius radius = BorderRadius.circular(height / 2);
    return Semantics(
      button: true,
      label: S.current.filters_button_semantics(_activeCount),
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: height,
        width: expanded ? double.infinity : null,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.overlay(0.06),
          borderRadius: radius,
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.overlay(0.08),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
            onTap: () => _open(context),
            child: Padding(
              padding: EdgeInsets.only(left: 14, right: active ? 8 : 16),
              child: _buildContent(active),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool active) {
    final Color foreground = active ? AppColors.primary : AppColors.mainWhite;
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.tune_rounded,
          size: 20,
          color: active ? AppColors.primary : AppColors.mainGrey,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            S.current.gallery_filters_button_label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: medium(size: 15, color: foreground),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: active ? _buildBadge() : const SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 24),
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$_activeCount',
          style: semibold(size: 13, color: AppColors.mainBlack),
        ),
      ),
    );
  }
}
