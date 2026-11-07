import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_list_tile.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';

class GalleryItem {
  const GalleryItem({
    required this.uid,
    required this.title,
    required this.cover,
    required this.headers,
    required this.onTap,
    this.onLongPress,
  });

  final String uid;
  final String title;
  final String cover;
  final Map<String, String> headers;
  final Future<void> Function() onTap;
  final VoidCallback? onLongPress;
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

class GalleryItemsView extends StatelessWidget {
  const GalleryItemsView({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding =
        kGalleryGridPadding +
        EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom);
    if (layout == GalleryLayout.list) {
      return _buildList(padding);
    }
    return _buildGrid(padding);
  }

  Widget _buildGrid(EdgeInsets padding) {
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

  Widget _buildList(EdgeInsets padding) {
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
