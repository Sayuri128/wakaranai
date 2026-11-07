import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_items_view.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryListTile extends StatefulWidget {
  const GalleryListTile({
    super.key,
    required this.item,
    required this.inLibrary,
    required this.activityLoader,
  });

  final GalleryItem item;
  final bool inLibrary;
  final GalleryActivityLoader activityLoader;

  @override
  State<GalleryListTile> createState() => _GalleryListTileState();
}

class _GalleryListTileState extends State<GalleryListTile> {
  String? _lastActivity;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final String? activity = await widget.activityLoader(widget.item.uid);
      if (mounted && activity != _lastActivity) {
        setState(() => _lastActivity = activity);
      }
    } catch (e, s) {
      logger.w('Failed to load gallery activity: $e');
      logger.w(s);
    }
  }

  Future<void> _onTap() async {
    await widget.item.onTap();
    if (mounted) {
      await _loadActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kGalleryListRowHeight,
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: _onTap,
          onLongPress: widget.item.onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GalleryListCover(
                  uid: widget.item.uid,
                  cover: widget.item.cover,
                  headers: widget.item.headers,
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: semibold(size: 15),
        ),
        const Spacer(),
        if (_lastActivity != null) ...<Widget>[
          Text(
            S.current.gallery_last_opened(_lastActivity!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: regular(size: 12, color: AppColors.mainGrey),
          ),
          const SizedBox(height: 6),
        ],
        if (widget.inLibrary) _buildLibraryChip(),
      ],
    );
  }

  Widget _buildLibraryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.favorite_rounded, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            S.current.gallery_in_library,
            style: medium(size: 12, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class GalleryListCover extends StatelessWidget {
  const GalleryListCover({
    super.key,
    required this.uid,
    required this.cover,
    required this.headers,
  });

  static const double width = 74;

  final String uid;
  final String cover;
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: Heroes.galleryViewToConcreteView(uid),
        flightShuttleBuilder: Heroes.crossfadeFlightShuttle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Heroes.galleryCardRadius),
          child: ColoredBox(
            color: AppColors.shimmerBase,
            child: cover.isEmpty ? _buildPlaceholder() : _buildImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Image(
      fit: BoxFit.cover,
      image: getImageProvider(
        cover,
        headers: headers,
        decodeWidth: decodeWidthFor(context, width),
      ),
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.image_outlined, color: Colors.white24, size: 24),
    );
  }
}
