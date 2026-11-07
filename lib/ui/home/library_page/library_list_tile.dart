import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_list_tile.dart';
import 'package:wakaranai/ui/common/title_status.dart';
import 'package:wakaranai/ui/home/library_page/library_entry_details.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LibraryListTile extends StatefulWidget {
  const LibraryListTile({
    super.key,
    required this.entry,
    required this.headers,
    required this.selected,
    required this.selectionMode,
    required this.unseenCount,
    required this.detailsLoader,
    required this.onTap,
    required this.onLongPress,
    required this.onMenu,
  });

  final LibraryEntryDomain entry;
  final Map<String, String>? headers;
  final bool selected;
  final bool selectionMode;
  final int unseenCount;
  final LibraryEntryDetailsLoader detailsLoader;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMenu;

  @override
  State<LibraryListTile> createState() => _LibraryListTileState();
}

class _LibraryListTileState extends State<LibraryListTile> {
  LibraryEntryDetails _details = const LibraryEntryDetails();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(LibraryListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool sameEntry = oldWidget.entry.uid == widget.entry.uid;
    final bool reopened = oldWidget.entry.lastReadAt != widget.entry.lastReadAt;
    if (!sameEntry || reopened) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    try {
      final LibraryEntryDetails details = await widget.detailsLoader.load(
        widget.entry,
      );
      if (mounted) {
        setState(() => _details = details);
      }
    } catch (e, s) {
      logger.w('Failed to load library entry details: $e');
      logger.w(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.selectionMode && widget.selected;
    return SizedBox(
      height: kGalleryListRowHeight,
      child: Material(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.overlay(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: highlighted
              ? BorderSide(color: AppColors.primary, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GalleryListCover(
                  key: ValueKey<bool>(widget.headers != null),
                  uid: widget.entry.uid,
                  cover: widget.entry.cover ?? '',
                  headers: widget.headers ?? const <String, String>{},
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails()),
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final String? meta = _metaLine();
    final String? lastOpened = _details.lastOpened;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.entry.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: semibold(size: 15),
        ),
        const Spacer(),
        if (meta != null) _buildSecondaryText(meta),
        if (meta != null && lastOpened != null) const SizedBox(height: 4),
        if (lastOpened != null)
          _buildSecondaryText(S.current.gallery_last_opened(lastOpened)),
      ],
    );
  }

  String? _metaLine() {
    final List<String> parts = <String>[
      if (_details.sourceName != null) _details.sourceName!,
      if (titleStatusLabel(_details.status) != null)
        titleStatusLabel(_details.status)!,
    ];
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' · ');
  }

  Widget _buildSecondaryText(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: regular(size: 12, color: AppColors.mainGrey),
    );
  }

  Widget _buildTrailing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (widget.selectionMode) _buildSelectionIcon() else _buildMenuButton(),
        const Spacer(),
        if (widget.unseenCount > 0) _buildUnseenBadge(),
      ],
    );
  }

  Widget _buildSelectionIcon() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(
        widget.selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: widget.selected ? AppColors.primary : AppColors.mainGrey,
        size: 24,
      ),
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
      icon: Icon(Icons.more_vert_rounded, color: AppColors.mainGrey, size: 20),
      onPressed: widget.onMenu,
    );
  }

  Widget _buildUnseenBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          S.current.library_new_chapters(widget.unseenCount),
          style: medium(size: 12, color: AppColors.mainBlack),
        ),
      ),
    );
  }
}
