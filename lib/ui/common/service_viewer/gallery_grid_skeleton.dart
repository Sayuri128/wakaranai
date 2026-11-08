import 'package:flutter/material.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';

/// A shimmering placeholder grid shown during the initial (cold) load, before
/// any gallery items exist.
class GalleryGridSkeleton extends StatelessWidget {
  const GalleryGridSkeleton({
    super.key,
    this.layout = GalleryLayout.comfortable,
    this.itemCount = 12,
  });

  final GalleryLayout layout;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: _buildLayout());
  }

  Widget _buildLayout() {
    if (layout == GalleryLayout.list) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: kGalleryGridPadding,
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: kGalleryListRowSpacing),
        itemBuilder: (BuildContext context, int index) => const SizedBox(
          height: kGalleryListRowHeight,
          child: ShimmerBox(borderRadius: 14),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: kGalleryGridPadding,
      gridDelegate: galleryGridDelegateFor(layout),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) =>
          const ShimmerBox(borderRadius: 10),
    );
  }
}
