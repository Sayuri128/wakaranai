import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout_transition.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/library_page/library_card.dart';
import 'package:wakaranai/ui/home/library_page/library_entry_details.dart';
import 'package:wakaranai/ui/home/library_page/library_grid_geometry.dart';
import 'package:wakaranai/ui/home/library_page/library_list_tile.dart';
import 'package:wakaranai/ui/home/library_page/source_attention_prompt.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';

typedef LibraryEntryCallback = void Function(LibraryEntryDomain entry);

class LibraryEntriesView extends StatelessWidget {
  const LibraryEntriesView({
    super.key,
    required this.state,
    required this.entries,
    required this.controller,
    required this.detailsLoader,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onMenu,
  });

  final LibraryState state;
  final List<LibraryEntryDomain> entries;
  final ScrollController controller;
  final LibraryEntryDetailsLoader detailsLoader;
  final Set<String> selected;
  final LibraryEntryCallback onTap;
  final LibraryEntryCallback onLongPress;
  final LibraryEntryCallback onMenu;

  static const ScrollPhysics _entriesPhysics = AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  );

  bool get _selectionMode => selected.isNotEmpty;

  EdgeInsets get _entriesPadding => EdgeInsets.fromLTRB(
    LibraryGridGeometry.horizontalPadding,
    LibraryGridGeometry.top,
    LibraryGridGeometry.horizontalPadding,
    _selectionMode ? 150 : 24,
  );

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => checkLibraryUpdatesNow(context),
      color: AppColors.primary,
      backgroundColor: AppColors.dialogSurface,
      child: entries.isEmpty ? _buildEmpty() : _buildEntries(context),
    );
  }

  Widget _buildEntries(BuildContext context) {
    return GalleryLayoutTransition(
      layout: context.watch<LibraryLayoutCubit>().state,
      geometry: const LibraryGridGeometry(),
      position: () => controller.hasClients ? controller.position : null,
      builder:
          (BuildContext context, GalleryLayout layout, GalleryMorph? morph) {
            if (layout == GalleryLayout.list) {
              return _buildList();
            }
            return _buildGrid(layout, morph);
          },
    );
  }

  Widget _buildGrid(GalleryLayout layout, GalleryMorph? morph) {
    final bool compact = layout == GalleryLayout.compact;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          controller: controller,
          padding: _entriesPadding,
          physics: _entriesPhysics,
          gridDelegate: LibraryGridGeometry.delegate(
            layout,
            constraints.maxWidth,
          ),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            final LibraryEntryDomain entry = entries[index];
            return GalleryMorphCell(
              morph: morph,
              index: index,
              child:
                  BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, int>(
                    selector: (LibraryUpdatesState updates) =>
                        updates.unseenForEntry(entry.uid),
                    builder: (BuildContext context, int unseenCount) =>
                        LibraryCard(
                          entry: entry,
                          compact: compact,
                          unseenCount: unseenCount,
                          headers: state.coverHeaders[entry.extensionUid],
                          selected: selected.contains(entry.uid),
                          selectionMode: _selectionMode,
                          onTap: () => onTap(entry),
                          onLongPress: () => onLongPress(entry),
                          onMenu: () => onMenu(entry),
                        ),
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildList() {
    return ListView.separated(
      controller: controller,
      padding: _entriesPadding,
      physics: _entriesPhysics,
      itemCount: entries.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: kGalleryListRowSpacing),
      itemBuilder: (BuildContext context, int index) {
        final LibraryEntryDomain entry = entries[index];
        return BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, int>(
          key: ValueKey<String>(entry.uid),
          selector: (LibraryUpdatesState updates) =>
              updates.unseenForEntry(entry.uid),
          builder: (BuildContext context, int unseenCount) => LibraryListTile(
            entry: entry,
            headers: state.coverHeaders[entry.extensionUid],
            selected: selected.contains(entry.uid),
            selectionMode: _selectionMode,
            unseenCount: unseenCount,
            detailsLoader: detailsLoader,
            onTap: () => onTap(entry),
            onLongPress: () => onLongPress(entry),
            onMenu: () => onMenu(entry),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: state.searching
                ? ServiceViewerMessage(
                    icon: Icons.search_off_rounded,
                    title: S.current.library_search_no_results_title,
                    message: S.current.library_search_no_results_message(
                      state.searchQuery,
                    ),
                  )
                : ServiceViewerMessage(
                    icon: Icons.favorite_border_rounded,
                    title: S.current.library_empty_title,
                    message: S.current.library_empty_message,
                  ),
          ),
        );
      },
    );
  }
}

Future<void> checkLibraryUpdatesNow(BuildContext context) async {
  final LibraryUpdatesCubit cubit = context.read<LibraryUpdatesCubit>();
  final LibraryUpdateCheckResult? result = await cubit.checkNow();

  if (result == null || !context.mounted) {
    return;
  }

  if (result.needsAttention.isNotEmpty) {
    SourceAttentionPrompt.show(context, result.needsAttention);
  } else if (result.updates.isNotEmpty) {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.updates_check_found(result.updates.length),
    );
  } else if (result.removedFromSource.isNotEmpty) {
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.current.source_error_removed_titles_found(
        result.removedFromSource.length,
      ),
    );
  } else if (result.failed > 0) {
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.current.updates_check_failed(result.failed),
    );
  } else {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.updates_check_none,
    );
  }
}
