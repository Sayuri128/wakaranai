import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_list_tile.dart';
import 'package:wakaranai/ui/common/title_status.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';

class GalleryItem {
  const GalleryItem({
    required this.uid,
    required this.title,
    required this.cover,
    required this.headers,
    required this.onTap,
    this.onLongPress,
    this.subtitle,
    this.status,
    this.tags = const <String>[],
    this.year,
    this.rating,
    this.latestChapter,
  });

  final String uid;
  final String title;
  final String cover;
  final Map<String, String> headers;
  final Future<void> Function() onTap;
  final VoidCallback? onLongPress;
  final String? subtitle;
  final String? status;
  final List<String> tags;
  final int? year;
  final num? rating;
  final String? latestChapter;
}

String? galleryItemMetaLine(GalleryItem item) {
  final String? status = titleStatusLabel(item.status);
  final List<String> parts = <String>[
    if (item.year != null) item.year.toString(),
    if (status != null) status,
    if (item.latestChapter != null) item.latestChapter!,
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' · ');
}

String formatGalleryRating(num rating) {
  if (rating == rating.roundToDouble()) {
    return rating.toInt().toString();
  }
  return rating.toStringAsFixed(1);
}

typedef GalleryActivityLoader = Future<String?> Function(String uid);

String? latestActivityTitle(List<BaseActivityDomain>? activities) {
  if (activities == null || activities.isEmpty) {
    return null;
  }
  BaseActivityDomain latest = activities.first;
  for (final BaseActivityDomain activity in activities.skip(1)) {
    if (_lastTouched(activity).isAfter(_lastTouched(latest))) {
      latest = activity;
    }
  }
  return latest.title;
}

DateTime _lastTouched(BaseActivityDomain activity) =>
    activity.updatedAt ?? activity.createdAt;

class GalleryItemsView {
  const GalleryItemsView({
    required this.layout,
    required this.itemCount,
    required this.itemAt,
    required this.activityLoader,
  });

  final GalleryLayout layout;
  final int itemCount;
  final GalleryItem Function(int index) itemAt;
  final GalleryActivityLoader activityLoader;

  static const ScrollPhysics _physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  ScrollView build(BuildContext context) {
    final EdgeInsets padding =
        kGalleryGridPadding +
        EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom);
    if (layout == GalleryLayout.list) {
      return _buildList(padding);
    }
    return _buildGrid(padding);
  }

  ScrollView _buildGrid(EdgeInsets padding) {
    return GridView.builder(
      physics: _physics,
      padding: padding,
      gridDelegate: galleryGridDelegateFor(layout),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        final GalleryItem item = itemAt(index);
        return _InLibrarySelector(
          uid: item.uid,
          builder: (bool inLibrary) => GalleryViewCard(
            cover: item.cover,
            uid: item.uid,
            title: item.title,
            inLibrary: inLibrary,
            compact: layout == GalleryLayout.compact,
            headers: item.headers,
            onLongPress: item.onLongPress,
            onTap: item.onTap,
          ),
        );
      },
    );
  }

  ScrollView _buildList(EdgeInsets padding) {
    return ListView.separated(
      physics: _physics,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: kGalleryListRowSpacing),
      itemBuilder: (BuildContext context, int index) {
        final GalleryItem item = itemAt(index);
        return _InLibrarySelector(
          key: ValueKey<String>(item.uid),
          uid: item.uid,
          builder: (bool inLibrary) => GalleryListTile(
            item: item,
            inLibrary: inLibrary,
            activityLoader: activityLoader,
          ),
        );
      },
    );
  }
}

class _InLibrarySelector extends StatelessWidget {
  const _InLibrarySelector({
    super.key,
    required this.uid,
    required this.builder,
  });

  final String uid;
  final Widget Function(bool inLibrary) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LibraryCubit, LibraryState, bool>(
      selector: (LibraryState library) =>
          library.entries.any((LibraryEntryDomain entry) => entry.uid == uid),
      builder: (BuildContext context, bool inLibrary) => builder(inLibrary),
    );
  }
}
