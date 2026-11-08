import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/library_entry_table.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';

class AutoDownloadPolicy {
  const AutoDownloadPolicy(this.settings);

  final AutoDownloadSettings settings;

  bool appliesTo(LibraryEntryDomain entry) {
    if (!settings.enabled) {
      return false;
    }
    switch (entry.autoDownload) {
      case AutoDownloadOverride.never:
        return false;
      case AutoDownloadOverride.always:
        return true;
      case AutoDownloadOverride.followSettings:
        return _inScope(entry);
    }
  }

  bool _inScope(LibraryEntryDomain entry) {
    switch (settings.scope) {
      case AutoDownloadScope.allTitles:
        return true;
      case AutoDownloadScope.selectedCategories:
        final int? categoryId = entry.categoryId;
        return categoryId != null && settings.categoryIds.contains(categoryId);
    }
  }

  List<T> pick<T extends ElementOfElementsGroupOfConcrete>(
    List<T> newItemsInReadingOrder, {
    required Set<String> keptUids,
  }) {
    final List<T> picked = <T>[];
    final Set<String> seen = <String>{};
    for (final T item in newItemsInReadingOrder) {
      if (!settings.unlimited && picked.length >= settings.maxPerTitle) {
        break;
      }
      if (keptUids.contains(item.uid) || !seen.add(item.uid)) {
        continue;
      }
      picked.add(item);
    }
    return picked;
  }
}
