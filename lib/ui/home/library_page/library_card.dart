import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LibraryCard extends StatelessWidget {
  const LibraryCard({
    super.key,
    required this.entry,
    required this.headers,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMenu,
    this.compact = false,
    this.unseenCount = 0,
  });

  final LibraryEntryDomain entry;
  final bool compact;
  final int unseenCount;
  final Map<String, String>? headers;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GalleryViewCard(
            key: ValueKey<bool>(headers != null),
            uid: entry.uid,
            headers: headers ?? const <String, String>{},
            cover: entry.cover ?? '',
            title: entry.title,
            compact: compact,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
        if (selectionMode)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.15),
                  border: selected
                      ? Border.all(color: AppColors.primary, width: 2.5)
                      : null,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? AppColors.primary : AppColors.onMedia,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          )
        else ...<Widget>[
          if (unseenCount > 0)
            Positioned(top: 6, left: 6, child: _buildUnseenBadge()),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onMenu,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.onMedia,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnseenBadge() {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$unseenCount',
          style: semibold(size: compact ? 11 : 12, color: AppColors.mainBlack),
        ),
      ),
    );
  }
}
