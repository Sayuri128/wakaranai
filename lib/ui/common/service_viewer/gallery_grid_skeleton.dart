import 'package:flutter/material.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';

/// Shared layout for the gallery grid so the real grid and its loading
/// skeleton always line up.
const EdgeInsets kGalleryGridPadding = EdgeInsets.fromLTRB(12, 12, 12, 24);

const SliverGridDelegateWithMaxCrossAxisExtent kGalleryGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 200,
  childAspectRatio: 0.66,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
);

/// A shimmering placeholder grid shown during the initial (cold) load, before
/// any gallery items exist.
class GalleryGridSkeleton extends StatelessWidget {
  const GalleryGridSkeleton({super.key, this.itemCount = 12});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: kGalleryGridPadding,
        gridDelegate: kGalleryGridDelegate,
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) =>
            const ShimmerBox(borderRadius: 10),
      ),
    );
  }
}
