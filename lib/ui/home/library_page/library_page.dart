import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/ui/home/library_page/library_download_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout_transition.dart';
import 'package:wakaranai/ui/home/library_page/library_grid_geometry.dart';
import 'package:wakaranai/ui/home/library_page/library_entry_details.dart';
import 'package:wakaranai/ui/home/library_page/library_list_tile.dart';
import 'package:wakaranai/ui/home/library_page/source_attention_prompt.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/search_field.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const int _allCategoryId = -1;
const int _uncategorizedId = -2;

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedCategory = _allCategoryId;
  final Set<String> _selected = <String>{};

  late final TextEditingController _searchController;
  late final LibraryEntryDetailsLoader _detailsLoader;
  final ScrollController _entriesController = ScrollController();

  bool get _selectionMode => _selected.isNotEmpty;

  List<LibraryEntryDomain>? _visibleCache;
  Object? _visibleCacheKey;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<LibraryCubit>().state.searchQuery,
    );
    _detailsLoader = LibraryEntryDetailsLoader(
      extensionRepository: context.read<ExtensionRepository>(),
      concreteDataRepository: context.read<ConcreteDataRepository>(),
      chapterActivityRepository: context.read<ChapterActivityRepository>(),
      animeEpisodeActivityRepository: context
          .read<AnimeEpisodeActivityRepository>(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entriesController.dispose();
    super.dispose();
  }

  void _toggleSelect(String uid) {
    setState(() {
      if (!_selected.remove(uid)) {
        _selected.add(uid);
      }
    });
  }

  void _clearSelection() => setState(_selected.clear);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (BuildContext context, LibraryState state) {
        return PopScope<Object?>(
          canPop: !_selectionMode,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop && _selectionMode) _clearSelection();
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (!widget.embedded) _buildHeader(context, state),
                      _buildSearchField(context, state),
                      if (state.categories.isNotEmpty ||
                          _hasUncategorized(state))
                        _buildCategoryChips(context, state),
                      Expanded(child: _buildGrid(context, state)),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildSelectionBar(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionBar(BuildContext context, LibraryState state) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      offset: _selectionMode ? Offset.zero : const Offset(0, 1.6),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _selectionMode ? 1 : 0,
        child: IgnorePointer(
          ignoring: !_selectionMode,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Material(
                color: AppColors.dialogSurface,
                elevation: 10,
                shadowColor: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              S.current.library_selected_count(
                                _selected.length,
                              ),
                              style: semibold(size: 15),
                            ),
                          ),
                          _CircleIconButton(
                            icon: Icons.select_all_rounded,
                            small: true,
                            onTap: () => _selectAllVisible(state),
                          ),
                          const SizedBox(width: 6),
                          _CircleIconButton(
                            icon: Icons.close_rounded,
                            small: true,
                            onTap: _clearSelection,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.overlay(0.06),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _SelectionAction(
                              icon: Icons.drive_file_move_outline,
                              label: S.current.library_move_to_category,
                              color: AppColors.primary,
                              onTap: () => _showMoveToCategorySheet(
                                context,
                                state,
                                _selectedEntries(state),
                                fromSelection: true,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.overlay(0.08),
                          ),
                          Expanded(
                            child: _SelectionAction(
                              icon: Icons.more_horiz_rounded,
                              label: S.current.library_more_actions,
                              color: AppColors.mainWhite,
                              onTap: () =>
                                  _showSelectionActions(context, state),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.overlay(0.08),
                          ),
                          Expanded(
                            child: _SelectionAction(
                              icon: Icons.delete_outline_rounded,
                              label: S.current.library_remove,
                              color: AppColors.red,
                              onTap: () {
                                context.read<LibraryCubit>().removeMany(
                                  _selected.toList(),
                                );
                                _clearSelection();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasUncategorized(LibraryState state) =>
      state.entries.any((LibraryEntryDomain e) => e.categoryId == null) &&
      state.categories.isNotEmpty;

  List<LibraryEntryDomain> _visibleEntries(LibraryState state) {
    final Object key = Object.hash(
      identityHashCode(state.entries),
      state.searchQuery,
      state.sort,
      _selectedCategory,
    );

    final List<LibraryEntryDomain>? cached = _visibleCache;
    if (cached != null && _visibleCacheKey == key) {
      return cached;
    }

    final List<LibraryEntryDomain> computed = _computeVisibleEntries(state);
    _visibleCache = computed;
    _visibleCacheKey = key;
    return computed;
  }

  List<LibraryEntryDomain> _computeVisibleEntries(LibraryState state) {
    Iterable<LibraryEntryDomain> entries = state.entries;
    if (_selectedCategory == _uncategorizedId) {
      entries = entries.where((LibraryEntryDomain e) => e.categoryId == null);
    } else if (_selectedCategory != _allCategoryId) {
      entries = entries.where(
        (LibraryEntryDomain e) => e.categoryId == _selectedCategory,
      );
    }
    entries = entries.where(state.matchesSearch);
    return state.sortedEntries(entries.toList());
  }

  Widget _buildHeader(BuildContext context, LibraryState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              S.current.home_navigation_bar_library_title,
              style: semibold(size: 24),
            ),
          ),
          ..._buildHeaderActions(context, state),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderActions(BuildContext context, LibraryState state) {
    return <Widget>[
      BlocBuilder<LibraryUpdatesCubit, LibraryUpdatesState>(
        builder: (BuildContext context, LibraryUpdatesState updatesState) {
          return _UpdatesButton(
            unseenCount: updatesState.unseenCount,
            onTap: () => Navigator.of(context).pushNamed(Routes.updates),
          );
        },
      ),
      const SizedBox(width: 8),
      BlocBuilder<LibraryLayoutCubit, GalleryLayout>(
        builder: (BuildContext context, GalleryLayout layout) =>
            _CircleIconButton(
              icon: galleryLayoutIcon(layout),
              onTap: () => context.read<LibraryLayoutCubit>().cycle(),
            ),
      ),
      const SizedBox(width: 8),
      _CircleIconButton(
        icon: Icons.sort_rounded,
        onTap: () => _showSortSheet(context, state),
      ),
      const SizedBox(width: 8),
      _CircleIconButton(
        icon: Icons.folder_outlined,
        onTap: () => _showManageCategoriesSheet(context, state),
      ),
    ];
  }

  Widget _buildSearchField(BuildContext context, LibraryState state) {
    final Widget field = SearchField(
      controller: _searchController,
      hintText: S.current.library_search_hint,
      onChanged: (String value) =>
          context.read<LibraryCubit>().setSearchQuery(value),
      onClear: () => context.read<LibraryCubit>().setSearchQuery(''),
    );
    if (!widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: field,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(
        children: <Widget>[
          Expanded(child: field),
          const SizedBox(width: 8),
          ..._buildHeaderActions(context, state),
        ],
      ),
    );
  }

  void _selectAllVisible(LibraryState state) {
    setState(() {
      _selected
        ..clear()
        ..addAll(_visibleEntries(state).map((LibraryEntryDomain e) => e.uid));
    });
  }

  Widget _buildCategoryChips(BuildContext context, LibraryState state) {
    final List<_CategoryChipData> chips = <_CategoryChipData>[
      _CategoryChipData(_allCategoryId, S.current.library_category_all),
      for (final CategoryDomain c in state.categories)
        _CategoryChipData(c.id, c.name),
      if (_hasUncategorized(state))
        _CategoryChipData(
          _uncategorizedId,
          S.current.library_category_uncategorized,
        ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final _CategoryChipData chip = chips[index];
          final bool selected = chip.id == _selectedCategory;
          return _SelectablePill(
            label: chip.label,
            selected: selected,
            onTap: () => setState(() => _selectedCategory = chip.id),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final LibraryUpdatesCubit cubit = context.read<LibraryUpdatesCubit>();
    final LibraryUpdateCheckResult? result = await cubit.checkNow();

    if (result == null || !context.mounted) return;

    if (result.needsAttention.isNotEmpty) {
      SourceAttentionPrompt.show(context, result.needsAttention);
    } else if (result.updates.isNotEmpty) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.updates_check_found(result.updates.length),
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

  Widget _buildGrid(BuildContext context, LibraryState state) {
    if (state.loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final List<LibraryEntryDomain> entries = _visibleEntries(state);

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppColors.primary,
      backgroundColor: AppColors.dialogSurface,
      child: entries.isEmpty
          ? _buildEmpty(state)
          : _buildEntries(context, state, entries),
    );
  }

  EdgeInsets get _entriesPadding => EdgeInsets.fromLTRB(
    LibraryGridGeometry.horizontalPadding,
    LibraryGridGeometry.top,
    LibraryGridGeometry.horizontalPadding,
    _selectionMode ? 150 : 24,
  );

  static const ScrollPhysics _entriesPhysics = AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  );

  Widget _buildEntries(
    BuildContext context,
    LibraryState state,
    List<LibraryEntryDomain> entries,
  ) {
    return GalleryLayoutTransition(
      layout: context.watch<LibraryLayoutCubit>().state,
      geometry: const LibraryGridGeometry(),
      position: () =>
          _entriesController.hasClients ? _entriesController.position : null,
      builder:
          (BuildContext context, GalleryLayout layout, GalleryMorph? morph) {
            if (layout == GalleryLayout.list) {
              return _buildList(context, state, entries);
            }
            return _buildGridOf(context, state, entries, layout, morph);
          },
    );
  }

  Widget _buildGridOf(
    BuildContext context,
    LibraryState state,
    List<LibraryEntryDomain> entries,
    GalleryLayout layout,
    GalleryMorph? morph,
  ) {
    final bool compact = layout == GalleryLayout.compact;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          controller: _entriesController,
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
                        _LibraryCard(
                          entry: entry,
                          compact: compact,
                          unseenCount: unseenCount,
                          headers: state.coverHeaders[entry.extensionUid],
                          selected: _selected.contains(entry.uid),
                          selectionMode: _selectionMode,
                          onTap: () => _onEntryTap(context, entry),
                          onLongPress: () => _toggleSelect(entry.uid),
                          onMenu: () =>
                              _showEntryActions(context, state, entry),
                        ),
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    LibraryState state,
    List<LibraryEntryDomain> entries,
  ) {
    return ListView.separated(
      controller: _entriesController,
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
            selected: _selected.contains(entry.uid),
            selectionMode: _selectionMode,
            unseenCount: unseenCount,
            detailsLoader: _detailsLoader,
            onTap: () => _onEntryTap(context, entry),
            onLongPress: () => _toggleSelect(entry.uid),
            onMenu: () => _showEntryActions(context, state, entry),
          ),
        );
      },
    );
  }

  void _onEntryTap(BuildContext context, LibraryEntryDomain entry) {
    if (_selectionMode) {
      _toggleSelect(entry.uid);
    } else {
      _openEntry(context, entry);
    }
  }

  Widget _buildEmpty(LibraryState state) {
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

  void _openEntry(BuildContext context, LibraryEntryDomain entry) {
    context.read<LibraryCubit>().markRead(entry.uid);
    Navigator.of(context).pushNamed(
      Routes.libraryConcreteViewer,
      arguments: LibraryConcreteViewerData(entry: entry),
    );
  }

  void _showSortSheet(BuildContext context, LibraryState state) {
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

  List<LibraryEntryDomain> _selectedEntries(LibraryState state) {
    return state.entries
        .where((LibraryEntryDomain e) => _selected.contains(e.uid))
        .toList();
  }

  Future<void> _showEntryActions(
    BuildContext context,
    LibraryState state,
    LibraryEntryDomain entry,
  ) {
    return _showActions(context, state, <LibraryEntryDomain>[
      entry,
    ], fromSelection: false);
  }

  Future<void> _showSelectionActions(BuildContext context, LibraryState state) {
    return _showActions(
      context,
      state,
      _selectedEntries(state),
      fromSelection: true,
    );
  }

  Future<Set<String>> _mangaExtensionUids(
    BuildContext context,
    List<LibraryEntryDomain> entries,
  ) async {
    final ExtensionRepository extensions = context.read<ExtensionRepository>();
    final Set<String> manga = <String>{};
    final Set<String> extensionUids = entries
        .map((LibraryEntryDomain e) => e.extensionUid)
        .toSet();
    for (final String uid in extensionUids) {
      final ExtensionDomain? extension = await extensions.getByUid(uid);
      if (extension?.config.type == ConfigInfoType.MANGA) {
        manga.add(uid);
      }
    }
    return manga;
  }

  Future<void> _showActions(
    BuildContext context,
    LibraryState state,
    List<LibraryEntryDomain> entries, {
    required bool fromSelection,
  }) async {
    if (entries.isEmpty) {
      return;
    }
    final Set<String> mangaExtensions = await _mangaExtensionUids(
      context,
      entries,
    );
    if (!context.mounted) {
      return;
    }
    final List<LibraryEntryDomain> downloadable = entries
        .where(
          (LibraryEntryDomain e) => mangaExtensions.contains(e.extensionUid),
        )
        .toList();
    final bool allTracked = entries.every(
      (LibraryEntryDomain e) => e.trackUpdates,
    );
    final bool allNotify = entries.every(
      (LibraryEntryDomain e) => e.notifyUpdates,
    );
    final LibraryCubit library = context.read<LibraryCubit>();

    void finish(BuildContext sheetContext) {
      Navigator.of(sheetContext).pop();
      if (fromSelection) {
        _clearSelection();
      }
    }

    await showActionSheet(
      context,
      title: entries.length == 1
          ? entries.single.title
          : S.current.library_selected_count(entries.length),
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ActionSheetRow(
              icon: Icons.drive_file_move_outline,
              label: S.current.library_move_to_category,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showMoveToCategorySheet(
                  context,
                  state,
                  entries,
                  fromSelection: fromSelection,
                );
              },
            ),
            if (downloadable.isNotEmpty)
              ActionSheetRow(
                icon: Icons.download_rounded,
                label: S.current.title_download,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _download(
                    context,
                    downloadable,
                    fromSelection: fromSelection,
                  );
                },
              ),
            ActionSheetRow(
              icon: Icons.autorenew_rounded,
              label: S.current.library_track_updates,
              selected: allTracked,
              onTap: () {
                library.setTrackUpdatesMany(entries, !allTracked);
                finish(sheetContext);
              },
            ),
            ActionSheetRow(
              icon: allNotify
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_active_outlined,
              label: allNotify
                  ? S.current.library_mute_notifications
                  : S.current.library_unmute_notifications,
              onTap: () {
                library.setNotifyUpdatesMany(entries, !allNotify);
                finish(sheetContext);
              },
            ),
            ActionSheetRow(
              icon: Icons.delete_outline_rounded,
              label: S.current.library_remove,
              destructive: true,
              onTap: () {
                library.removeMany(
                  entries.map((LibraryEntryDomain e) => e.uid).toList(),
                );
                finish(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _download(
    BuildContext context,
    List<LibraryEntryDomain> entries, {
    required bool fromSelection,
  }) {
    if (entries.length == 1) {
      showLibraryDownloadSheet(context, entries.single);
      if (fromSelection) {
        _clearSelection();
      }
      return;
    }
    showLibraryBulkDownloadSheet(
      context,
      entries,
      onStarted: fromSelection ? _clearSelection : null,
    );
  }

  void _showMoveToCategorySheet(
    BuildContext context,
    LibraryState state,
    List<LibraryEntryDomain> entries, {
    required bool fromSelection,
  }) {
    final LibraryCubit library = context.read<LibraryCubit>();
    bool allIn(int? categoryId) =>
        entries.every((LibraryEntryDomain e) => e.categoryId == categoryId);

    void move(BuildContext sheetContext, int? categoryId) {
      library.moveManyToCategory(entries, categoryId);
      Navigator.of(sheetContext).pop();
      if (fromSelection) {
        _clearSelection();
      }
    }

    showActionSheet(
      context,
      title: S.current.library_move_to_category,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ActionSheetRow(
              label: S.current.library_no_category,
              selected: allIn(null),
              onTap: () => move(sheetContext, null),
            ),
            for (final CategoryDomain c in state.categories)
              ActionSheetRow(
                label: c.name,
                selected: allIn(c.id),
                onTap: () => move(sheetContext, c.id),
              ),
          ],
        ),
      ),
    );
  }

  void _showManageCategoriesSheet(BuildContext context, LibraryState state) {
    showActionSheet(
      context,
      title: S.current.library_manage_categories,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final CategoryDomain c in state.categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(c.name, style: medium(size: 15))),
                  _CircleIconButton(
                    icon: Icons.edit_outlined,
                    small: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showCategoryNameDialog(context, category: c);
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.delete_outline_rounded,
                    small: true,
                    destructive: true,
                    onTap: () => context.read<LibraryCubit>().deleteCategory(c),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: _PrimaryPillButton(
              icon: Icons.add_rounded,
              label: S.current.library_add_category,
              onTap: () {
                Navigator.of(context).pop();
                _showCategoryNameDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryNameDialog(
    BuildContext context, {
    CategoryDomain? category,
  }) {
    final TextEditingController controller = TextEditingController(
      text: category?.name ?? '',
    );
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.dialogSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  category == null
                      ? S.current.library_add_category
                      : S.current.library_rename_category,
                  style: semibold(size: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: AppColors.primary,
                  style: medium(size: 15),
                  decoration: InputDecoration(
                    hintText: S.current.library_category_name_hint,
                    hintStyle: regular(size: 15, color: AppColors.mainGrey),
                    filled: true,
                    fillColor: AppColors.overlay(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _PillButton(
                        label: S.current.common_cancel,
                        background: AppColors.overlay(0.06),
                        foreground: AppColors.mainWhite,
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillButton(
                        label: category == null
                            ? S.current.common_add
                            : S.current.common_save,
                        background: AppColors.primary,
                        foreground: AppColors.mainBlack,
                        onTap: () {
                          final String name = controller.text.trim();
                          if (name.isEmpty) return;
                          if (category == null) {
                            context.read<LibraryCubit>().addCategory(name);
                          } else {
                            context.read<LibraryCubit>().renameCategory(
                              category,
                              name,
                            );
                          }
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChipData {
  const _CategoryChipData(this.id, this.label);

  final int id;
  final String label;
}

class _SelectionAction extends StatelessWidget {
  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: medium(size: 14, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.entry,
    required this.headers,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMenu,
    this.compact = false,
    this.unseenCount = 0,
  });

  final LibraryEntryDomain entry;
  final bool compact;
  final int unseenCount;
  final Map<String, String>? headers;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GalleryViewCard(
            key: ValueKey<bool>(headers != null),
            uid: entry.uid,
            headers: headers ?? const <String, String>{},
            cover: entry.cover ?? '',
            title: entry.title,
            compact: compact,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
        if (selectionMode)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.15),
                  border: selected
                      ? Border.all(color: AppColors.primary, width: 2.5)
                      : null,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? AppColors.primary : AppColors.onMedia,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          )
        else ...<Widget>[
          if (unseenCount > 0)
            Positioned(top: 6, left: 6, child: _buildUnseenBadge()),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onMenu,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.onMedia,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnseenBadge() {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$unseenCount',
          style: semibold(size: compact ? 11 : 12, color: AppColors.mainBlack),
        ),
      ),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: medium(
                size: 14,
                color: selected ? AppColors.mainBlack : AppColors.mainWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatesButton extends StatelessWidget {
  const _UpdatesButton({required this.unseenCount, required this.onTap});

  final int unseenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _CircleIconButton(icon: Icons.notifications_none_rounded, onTap: onTap),
        if (unseenCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.backgroundColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                unseenCount > 99 ? '99+' : '$unseenCount',
                textAlign: TextAlign.center,
                style: medium(size: 10, color: AppColors.mainBlack),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.small = false,
    this.destructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool small;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(small ? 6 : 8),
          child: Icon(
            icon,
            size: small ? 18 : 22,
            color: destructive ? AppColors.red : AppColors.mainWhite,
          ),
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: medium(size: 15, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(label, style: semibold(size: 15, color: foreground)),
        ),
      ),
    );
  }
}
