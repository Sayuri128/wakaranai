import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/library_page/library_buttons.dart';

const int kLibraryAllCategoryId = -1;
const int kLibraryUncategorizedId = -2;

class LibraryCategoryChips extends StatelessWidget {
  const LibraryCategoryChips({
    super.key,
    required this.categories,
    required this.hasUncategorized,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<CategoryDomain> categories;
  final bool hasUncategorized;
  final int selectedCategory;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<_CategoryChipData> chips = <_CategoryChipData>[
      _CategoryChipData(kLibraryAllCategoryId, S.current.library_category_all),
      for (final CategoryDomain c in categories)
        _CategoryChipData(c.id, c.name),
      if (hasUncategorized)
        _CategoryChipData(
          kLibraryUncategorizedId,
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
          final bool selected = chip.id == selectedCategory;
          return LibrarySelectablePill(
            label: chip.label,
            selected: selected,
            onTap: () => onSelected(chip.id),
          );
        },
      ),
    );
  }
}

class _CategoryChipData {
  const _CategoryChipData(this.id, this.label);

  final int id;
  final String label;
}
