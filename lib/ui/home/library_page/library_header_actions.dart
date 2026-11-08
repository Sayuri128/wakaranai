import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/home/library_page/library_buttons.dart';
import 'package:wakaranai/ui/home/library_page/library_category_sheets.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';

class LibraryHeaderActions extends StatelessWidget {
  const LibraryHeaderActions({super.key, required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlocBuilder<LibraryUpdatesCubit, LibraryUpdatesState>(
          builder: (BuildContext context, LibraryUpdatesState updatesState) {
            return LibraryUpdatesButton(
              unseenCount: updatesState.unseenCount,
              onTap: () => Navigator.of(context).pushNamed(Routes.updates),
            );
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<LibraryLayoutCubit, GalleryLayout>(
          builder: (BuildContext context, GalleryLayout layout) =>
              LibraryCircleIconButton(
                icon: galleryLayoutIcon(layout),
                onTap: () => context.read<LibraryLayoutCubit>().cycle(),
              ),
        ),
        const SizedBox(width: 8),
        LibraryCircleIconButton(
          icon: Icons.sort_rounded,
          onTap: () => showLibrarySortSheet(context, state),
        ),
        const SizedBox(width: 8),
        LibraryCircleIconButton(
          icon: Icons.folder_outlined,
          onTap: () => showLibraryManageCategoriesSheet(context, state),
        ),
      ],
    );
  }
}

void showLibrarySortSheet(BuildContext context, LibraryState state) {
  final Map<LibrarySort, String> labels = <LibrarySort, String>{
    LibrarySort.addedNewest: S.current.library_sort_added_newest,
    LibrarySort.addedOldest: S.current.library_sort_added_oldest,
    LibrarySort.title: S.current.library_sort_alphabetical,
    LibrarySort.lastRead: S.current.library_sort_last_read,
  };
  showActionSheet(
    context,
    title: S.current.library_sort_title,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MapEntry<LibrarySort, String> e in labels.entries)
          ActionSheetRow(
            icon: _librarySortIcon(e.key),
            label: e.value,
            selected: state.sort == e.key,
            onTap: () {
              context.read<LibraryCubit>().setSort(e.key);
              Navigator.of(context).pop();
            },
          ),
      ],
    ),
  );
}

IconData _librarySortIcon(LibrarySort sort) {
  switch (sort) {
    case LibrarySort.addedNewest:
      return Icons.arrow_downward_rounded;
    case LibrarySort.addedOldest:
      return Icons.arrow_upward_rounded;
    case LibrarySort.title:
      return Icons.sort_by_alpha_rounded;
    case LibrarySort.lastRead:
      return Icons.history_rounded;
  }
}
