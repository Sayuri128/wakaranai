import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const int _allCategoryId = -1;
const int _uncategorizedId = -2;

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedCategory = _allCategoryId;
  final Set<String> _selected = <String>{};

  bool get _selectionMode => _selected.isNotEmpty;

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
                      _buildHeader(context, state),
                      if (!_selectionMode &&
                          (state.categories.isNotEmpty ||
                              _hasUncategorized(state)))
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
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _SelectionAction(
                          icon: Icons.drive_file_move_outline,
                          label: S.current.library_move_to_category,
                          color: AppColors.primary,
                          onTap: () => _showBulkMoveSheet(context, state),
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
                            context
                                .read<LibraryCubit>()
                                .removeMany(_selected.toList());
                            _clearSelection();
                          },
                        ),
                      ),
                    ],
                  ),
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
    Iterable<LibraryEntryDomain> entries = state.entries;
    if (_selectedCategory == _uncategorizedId) {
      entries = entries.where((LibraryEntryDomain e) => e.categoryId == null);
    } else if (_selectedCategory != _allCategoryId) {
      entries = entries
          .where((LibraryEntryDomain e) => e.categoryId == _selectedCategory);
    }
    return state.sortedEntries(entries.toList());
  }

  Widget _buildHeader(BuildContext context, LibraryState state) {
    if (_selectionMode) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Row(
          children: <Widget>[
            _CircleIconButton(
              icon: Icons.close_rounded,
              onTap: _clearSelection,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.current.library_selected_count(_selected.length),
                style: semibold(size: 20),
              ),
            ),
            _CircleIconButton(
              icon: Icons.select_all_rounded,
              onTap: () => setState(() {
                _selected
                  ..clear()
                  ..addAll(_visibleEntries(state)
                      .map((LibraryEntryDomain e) => e.uid));
              }),
            ),
          ],
        ),
      );
    }
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
          _CircleIconButton(
            icon: Icons.sort_rounded,
            onTap: () => _showSortSheet(context, state),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.folder_outlined,
            onTap: () => _showManageCategoriesSheet(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, LibraryState state) {
    final List<_CategoryChipData> chips = <_CategoryChipData>[
      _CategoryChipData(_allCategoryId, S.current.library_category_all),
      for (final CategoryDomain c in state.categories)
        _CategoryChipData(c.id, c.name),
      if (_hasUncategorized(state))
        _CategoryChipData(
            _uncategorizedId, S.current.library_category_uncategorized),
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

  Widget _buildGrid(BuildContext context, LibraryState state) {
    if (state.loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final List<LibraryEntryDomain> entries = _visibleEntries(state);
    if (entries.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.favorite_border_rounded,
        title: S.current.library_empty_title,
        message: S.current.library_empty_message,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount =
            (constraints.maxWidth / 180).floor().clamp(2, 6);
        final double itemWidth = constraints.maxWidth / crossAxisCount;
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(12, 4, 12, _selectionMode ? 120 : 24),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: GalleryViewCard.aspectRatio(itemWidth),
          ),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            final LibraryEntryDomain entry = entries[index];
            return _LibraryCard(
              entry: entry,
              selected: _selected.contains(entry.uid),
              selectionMode: _selectionMode,
              onTap: () => _selectionMode
                  ? _toggleSelect(entry.uid)
                  : _openEntry(context, entry),
              onLongPress: () => _toggleSelect(entry.uid),
              onMenu: () => _showEntryActions(context, state, entry),
            );
          },
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
    _showSheet(
      context,
      title: S.current.library_sort_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final MapEntry<LibrarySort, String> e in labels.entries)
            _SheetRow(
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

  void _showEntryActions(
      BuildContext context, LibraryState state, LibraryEntryDomain entry) {
    _showSheet(
      context,
      title: entry.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SheetRow(
            icon: Icons.drive_file_move_outline,
            label: S.current.library_move_to_category,
            onTap: () {
              Navigator.of(context).pop();
              _showMoveToCategorySheet(context, state, entry);
            },
          ),
          _SheetRow(
            icon: Icons.delete_outline_rounded,
            label: S.current.library_remove,
            destructive: true,
            onTap: () {
              context.read<LibraryCubit>().removeFromLibrary(entry.uid);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showMoveToCategorySheet(
      BuildContext context, LibraryState state, LibraryEntryDomain entry) {
    _showSheet(
      context,
      title: S.current.library_move_to_category,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SheetRow(
            label: S.current.library_no_category,
            selected: entry.categoryId == null,
            onTap: () {
              context.read<LibraryCubit>().moveToCategory(entry, null);
              Navigator.of(context).pop();
            },
          ),
          for (final CategoryDomain c in state.categories)
            _SheetRow(
              label: c.name,
              selected: entry.categoryId == c.id,
              onTap: () {
                context.read<LibraryCubit>().moveToCategory(entry, c.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  void _showBulkMoveSheet(BuildContext context, LibraryState state) {
    final List<LibraryEntryDomain> selectedEntries = state.entries
        .where((LibraryEntryDomain e) => _selected.contains(e.uid))
        .toList();
    _showSheet(
      context,
      title: S.current.library_move_to_category,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SheetRow(
            label: S.current.library_no_category,
            onTap: () {
              context
                  .read<LibraryCubit>()
                  .moveManyToCategory(selectedEntries, null);
              Navigator.of(context).pop();
              _clearSelection();
            },
          ),
          for (final CategoryDomain c in state.categories)
            _SheetRow(
              label: c.name,
              onTap: () {
                context
                    .read<LibraryCubit>()
                    .moveManyToCategory(selectedEntries, c.id);
                Navigator.of(context).pop();
                _clearSelection();
              },
            ),
        ],
      ),
    );
  }

  void _showManageCategoriesSheet(BuildContext context, LibraryState state) {
    _showSheet(
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
                    onTap: () =>
                        context.read<LibraryCubit>().deleteCategory(c),
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

  void _showCategoryNameDialog(BuildContext context, {CategoryDomain? category}) {
    final TextEditingController controller =
        TextEditingController(text: category?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.dialogSurface,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                            context
                                .read<LibraryCubit>()
                                .renameCategory(category, name);
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

  void _showSheet(BuildContext context,
      {required String title, required Widget child}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.overlay(0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(title,
                    style: semibold(size: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Flexible(child: SingleChildScrollView(child: child)),
              const SizedBox(height: 8),
            ],
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
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMenu,
  });

  final LibraryEntryDomain entry;
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
            uid: entry.uid,
            headers: const <String, String>{},
            cover: entry.cover ?? '',
            title: entry.title,
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
        else
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
                  child: Icon(Icons.more_vert_rounded,
                      color: AppColors.onMedia, size: 20),
                ),
              ),
            ),
          ),
      ],
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

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    this.icon,
    this.selected = false,
    this.destructive = false,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive
        ? AppColors.red
        : (selected ? AppColors.primary : AppColors.mainWhite);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
            ],
            Expanded(child: Text(label, style: medium(size: 15, color: color))),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
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
