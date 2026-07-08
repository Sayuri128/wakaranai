import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

/// Floating circular favorite (add-to-library) button placed over the cover.
class ConcreteFavoriteButton extends StatelessWidget {
  const ConcreteFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.black.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.primary : AppColors.onMedia,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating circular back button placed over the cover, always accessible.
class ConcreteBackButton extends StatelessWidget {
  const ConcreteBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.black.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_rounded,
                  color: AppColors.mainWhite, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom-fading scrim placed **inside** the cover's [Hero] child so it flies
/// together with the image (a sibling scrim would be left behind on the empty
/// hero placeholder during the flight and pop in at the end).
class ConcreteCoverScrim extends StatelessWidget {
  const ConcreteCoverScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.transparent,
              Colors.transparent,
              AppColors.backgroundColor,
            ],
            stops: const <double>[0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

/// A subtle rounded pill used to display a single tag/genre.
class ConcreteTagChip extends StatelessWidget {
  const ConcreteTagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label.trim(),
          style: medium(size: 12, color: AppColors.mainWhite)),
    );
  }
}

/// Section header ("Chapters"/"Episodes") with a count badge.
class ConcreteSectionHeader extends StatelessWidget {
  const ConcreteSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: <Widget>[
          Text(title, style: semibold(size: 18)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.overlay(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: medium(size: 12, color: AppColors.mainGrey)),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable set of selectable group/provider pills.
class ConcreteGroupSelector extends StatelessWidget {
  const ConcreteGroupSelector({
    super.key,
    required this.titles,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = index == selectedIndex;
          return Material(
            color: selected
                ? AppColors.primary
                : AppColors.overlay(0.06),
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    titles[index].trim(),
                    style: semibold(
                      size: 14,
                      color:
                          selected ? AppColors.mainBlack : AppColors.mainWhite,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Description text that collapses past [collapsedLines] with a toggle.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({
    super.key,
    required this.text,
    this.collapsedLines = 4,
  });

  final String text;
  final int collapsedLines;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = regular(size: 14, color: AppColors.mainGrey);
    final TextSpan span = TextSpan(text: widget.text, style: style);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: span,
          maxLines: widget.collapsedLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final bool overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : widget.collapsedLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? S.current.concrete_viewer_description_show_less
                        : S.current.concrete_viewer_description_show_more,
                    style: semibold(size: 13, color: AppColors.primary),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A single chapter/episode row, styled as a card.
class ConcreteListTile extends StatelessWidget {
  const ConcreteListTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.onLongPress,
    this.subtitle,
    this.progress,
    this.selected = false,
    this.dim = false,
  });

  final String title;
  final Widget? subtitle;
  final double? progress;
  final bool selected;
  final bool dim;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool showProgress =
        progress != null && progress! > 0 && progress! < 1;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: dim ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.overlay(0.04),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title.trim(), style: medium(size: 15)),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 6),
                          subtitle!,
                        ],
                        if (showProgress) ...<Widget>[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor:
                                  AppColors.overlay(0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : (dim
                            ? Icons.check_circle_outline_rounded
                            : Icons.chevron_right_rounded),
                    color: selected || dim
                        ? AppColors.primary
                        : AppColors.mainGrey,
                    size: selected || dim ? 22 : 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the title-details + list section while loading.
class ConcreteContentSkeleton extends StatelessWidget {
  const ConcreteContentSkeleton({super.key, this.showCover = false});

  final bool showCover;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showCover)
            ShimmerBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              borderRadius: 0,
            ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(width: 220, height: 22, borderRadius: 6),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                ShimmerBox(width: 64, height: 26, borderRadius: 8),
                ShimmerBox(width: 80, height: 26, borderRadius: 8),
                ShimmerBox(width: 56, height: 26, borderRadius: 8),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(width: double.infinity, height: 12, borderRadius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 12, borderRadius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: 200, height: 12, borderRadius: 6),
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (int i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerBox(width: 160, height: 15, borderRadius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: 90, height: 12, borderRadius: 6),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
