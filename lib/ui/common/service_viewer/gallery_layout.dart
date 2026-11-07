import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';

enum GalleryLayout { comfortable, compact, list }

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

const SliverGridDelegateWithMaxCrossAxisExtent kCompactGalleryGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 130,
      childAspectRatio: 0.66,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
    );

const double kGalleryListRowHeight = 120;
const double kGalleryListRowSpacing = 8;

SliverGridDelegate galleryGridDelegateFor(GalleryLayout layout) {
  if (layout == GalleryLayout.compact) {
    return kCompactGalleryGridDelegate;
  }
  return kGalleryGridDelegate;
}

GalleryLayout galleryLayoutFromName(String? name) {
  for (final GalleryLayout layout in GalleryLayout.values) {
    if (layout.name == name) {
      return layout;
    }
  }
  return GalleryLayout.comfortable;
}

GalleryLayout nextGalleryLayout(GalleryLayout layout) {
  final List<GalleryLayout> layouts = GalleryLayout.values;
  return layouts[(layout.index + 1) % layouts.length];
}

IconData galleryLayoutIcon(GalleryLayout layout) {
  switch (layout) {
    case GalleryLayout.comfortable:
      return Icons.grid_view_rounded;
    case GalleryLayout.compact:
      return Icons.apps_rounded;
    case GalleryLayout.list:
      return Icons.view_list_rounded;
  }
}

String galleryLayoutLabel(GalleryLayout layout) {
  switch (layout) {
    case GalleryLayout.comfortable:
      return S.current.gallery_layout_comfortable;
    case GalleryLayout.compact:
      return S.current.gallery_layout_compact;
    case GalleryLayout.list:
      return S.current.gallery_layout_list;
  }
}
