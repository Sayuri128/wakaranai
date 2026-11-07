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
    final GalleryItem item = widget.item;
    final String? subtitle = item.subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          maxLines: subtitle == null ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: semibold(size: 15),
        ),
        if (subtitle != null) _buildSecondaryText(subtitle),
        if (item.tags.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          _buildSecondaryText(
            item.tags.take(_visibleTags).join(' · '),
            color: AppColors.mainWhite.withValues(alpha: 0.7),
          ),
        ],
        const Spacer(),
        if (_lastActivity != null) ...<Widget>[
          _buildSecondaryText(S.current.gallery_last_opened(_lastActivity!)),
          const SizedBox(height: 4),
        ],
        _buildFooter(item),
      ],
    );
  }

  static const int _visibleTags = 3;

  Widget _buildSecondaryText(String text, {Color? color}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: regular(size: 12, color: color ?? AppColors.mainGrey),
    );
  }

  Widget _buildFooter(GalleryItem item) {
    final String? meta = galleryItemMetaLine(item);
    return Row(
      children: <Widget>[
        if (item.rating != null) ...<Widget>[
          Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 2),
          Text(
            formatGalleryRating(item.rating!),
            style: medium(size: 12, color: AppColors.primary),
          ),
          if (meta != null) const SizedBox(width: 8),
        ],
        Expanded(
          child: meta == null ? const SizedBox() : _buildSecondaryText(meta),
        ),
        if (widget.inLibrary)
          Icon(Icons.favorite_rounded, size: 16, color: AppColors.primary),
      ],
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
