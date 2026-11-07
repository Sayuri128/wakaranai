import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout_transition.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';

class LibraryGridGeometry extends GalleryGeometry {
  const LibraryGridGeometry();

  static const double horizontalPadding = 12;
  static const double top = 4;

  static double _spacing(GalleryLayout layout) =>
      layout == GalleryLayout.compact ? 6 : 8;

  static int _gridColumns(GalleryLayout layout, double width) {
    final bool compact = layout == GalleryLayout.compact;
    final double cellExtent = compact ? 120 : 180;
    return (width / cellExtent).floor().clamp(compact ? 3 : 2, compact ? 8 : 6);
  }

  static SliverGridDelegateWithFixedCrossAxisCount delegate(
    GalleryLayout layout,
    double width,
  ) {
    final int count = _gridColumns(layout, width);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      mainAxisSpacing: _spacing(layout),
      crossAxisSpacing: _spacing(layout),
      childAspectRatio: GalleryViewCard.aspectRatio(width / count),
    );
  }

  @override
  double get topPadding => top;

  @override
  double get leftPadding => horizontalPadding;

  @override
  double crossSpacing(GalleryLayout layout) {
    if (layout == GalleryLayout.list) {
      return 0;
    }
    return _spacing(layout);
  }

  @override
  Size cellSize(GalleryLayout layout, double width) {
    final double usable = max(1, width - horizontalPadding * 2);
    if (layout == GalleryLayout.list) {
      return Size(usable, kGalleryListRowHeight);
    }
    final SliverGridDelegateWithFixedCrossAxisCount grid = delegate(
      layout,
      width,
    );
    final int count = grid.crossAxisCount;
    final double childWidth =
        (usable - grid.crossAxisSpacing * (count - 1)) / count;
    return Size(childWidth, childWidth / grid.childAspectRatio);
  }

  @override
  int columns(GalleryLayout layout, double width) {
    if (layout == GalleryLayout.list) {
      return 1;
    }
    return _gridColumns(layout, width);
  }

  @override
  double rowStride(GalleryLayout layout, double width) {
    if (layout == GalleryLayout.list) {
      return kGalleryListRowHeight + kGalleryListRowSpacing;
    }
    return cellSize(layout, width).height + _spacing(layout);
  }
}
