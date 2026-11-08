import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/library_page/library_category_chips.dart';
import 'package:wakaranai/ui/home/library_page/library_category_sheets.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/home/library_page/library_entries_view.dart';
import 'package:wakaranai/ui/home/library_page/library_entry_actions.dart';
import 'package:wakaranai/ui/home/library_page/library_entry_details.dart';
import 'package:wakaranai/ui/home/library_page/library_header_actions.dart';
import 'package:wakaranai/ui/home/library_page/library_selection_bar.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/search_field.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedCategory = kLibraryAllCategoryId;
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
    context.watch<NsfwTitlesCubit>();
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (BuildContext context, LibraryState state) {
        return PopScope<Object?>(
          canPop: !_selectionMode,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop && _selectionMode) {
              _clearSelection();
            }
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
                      if (!widget.embedded) _buildHeader(state),
                      _buildSearchField(context, state),
                      if (state.categories.isNotEmpty ||
                          _hasUncategorized(state))
                        LibraryCategoryChips(
                          categories: state.categories,
                          hasUncategorized: _hasUncategorized(state),
                          selectedCategory: _selectedCategory,
                          onSelected: (int id) =>
                              setState(() => _selectedCategory = id),
                        ),
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
    return LibrarySelectionBar(
      visible: _selectionMode,
      selectedCount: _selected.length,
      onSelectAll: () => _selectAllVisible(state),
      onClear: _clearSelection,
      onMoveToCategory: () => showLibraryMoveToCategorySheet(
        context,
        state,
        _selectedEntries(state),
        onMoved: _clearSelection,
      ),
      onMoreActions: () => showLibraryEntryActions(
        context,
        state,
        _selectedEntries(state),
        clearSelection: _clearSelection,
      ),
      onRemove: () {
        context.read<LibraryCubit>().removeMany(_selected.toList());
        _clearSelection();
      },
    );
  }

  bool _hasUncategorized(LibraryState state) =>
      state.entries.any((LibraryEntryDomain e) => e.categoryId == null) &&
      state.categories.isNotEmpty;

  List<LibraryEntryDomain> _visibleEntries(LibraryState state) {
    final NsfwTitlesState nsfw = context.read<NsfwTitlesCubit>().state;
    final Object key = Object.hash(
      identityHashCode(state.entries),
      state.searchQuery,
      state.sort,
      _selectedCategory,
      nsfw.hideTitles,
      identityHashCode(nsfw.nsfwExtensionUids),
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
    final NsfwTitlesState nsfw = context.read<NsfwTitlesCubit>().state;
    Iterable<LibraryEntryDomain> entries = state.entries
        .where((LibraryEntryDomain e) => !nsfw.hides(e.extensionUid));
    if (_selectedCategory == kLibraryUncategorizedId) {
      entries = entries.where((LibraryEntryDomain e) => e.categoryId == null);
    } else if (_selectedCategory != kLibraryAllCategoryId) {
      entries = entries.where(
        (LibraryEntryDomain e) => e.categoryId == _selectedCategory,
      );
    }
    entries = entries.where(state.matchesSearch);
    return state.sortedEntries(entries.toList());
  }

  Widget _buildHeader(LibraryState state) {
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
          LibraryHeaderActions(state: state),
        ],
      ),
    );
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
          LibraryHeaderActions(state: state),
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

  Widget _buildGrid(BuildContext context, LibraryState state) {
    if (state.loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return LibraryEntriesView(
      state: state,
      entries: _visibleEntries(state),
      controller: _entriesController,
      detailsLoader: _detailsLoader,
      selected: _selected,
      onTap: (LibraryEntryDomain entry) => _onEntryTap(context, entry),
      onLongPress: (LibraryEntryDomain entry) => _toggleSelect(entry.uid),
      onMenu: (LibraryEntryDomain entry) => showLibraryEntryActions(
        context,
        state,
        <LibraryEntryDomain>[entry],
        onContinue: () => _openEntry(context, entry, continueOnOpen: true),
      ),
    );
  }

  void _onEntryTap(BuildContext context, LibraryEntryDomain entry) {
    if (_selectionMode) {
      _toggleSelect(entry.uid);
    } else {
      _openEntry(context, entry);
    }
  }

  void _openEntry(
    BuildContext context,
    LibraryEntryDomain entry, {
    bool continueOnOpen = false,
  }) {
    context.read<LibraryCubit>().markRead(entry.uid);
    Navigator.of(context).pushNamed(
      Routes.libraryConcreteViewer,
      arguments: LibraryConcreteViewerData(
        entry: entry,
        continueOnOpen: continueOnOpen,
      ),
    );
  }

  List<LibraryEntryDomain> _selectedEntries(LibraryState state) {
    return state.entries
        .where((LibraryEntryDomain e) => _selected.contains(e.uid))
        .toList();
  }
}
