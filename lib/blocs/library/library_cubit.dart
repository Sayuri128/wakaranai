import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';

part 'library_state.dart';

enum LibrarySort { addedNewest, addedOldest, title, lastRead }

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required this.libraryEntryRepository,
    required this.categoryRepository,
  }) : super(const LibraryState());

  final LibraryEntryRepository libraryEntryRepository;
  final CategoryRepository categoryRepository;

  StreamSubscription<List<LibraryEntryDomain>>? _entriesSub;
  StreamSubscription<List<CategoryDomain>>? _categoriesSub;

  void init() {
    _entriesSub?.cancel();
    _categoriesSub?.cancel();

    _entriesSub = libraryEntryRepository.watchAll().listen(
      (List<LibraryEntryDomain> entries) {
        emit(state.copyWith(entries: entries, loading: false));
      },
    );

    _categoriesSub = categoryRepository.watchAll().listen(
      (List<CategoryDomain> categories) {
        emit(state.copyWith(categories: categories));
      },
    );
  }

  bool isFavorite(String uid) {
    return state.entries.any((LibraryEntryDomain e) => e.uid == uid);
  }

  Future<void> toggleFavorite(LibraryEntryDomain entry) async {
    final LibraryEntryDomain? existing =
        await libraryEntryRepository.getByUid(entry.uid);
    if (existing != null) {
      await libraryEntryRepository.deleteByUid(entry.uid);
    } else {
      await libraryEntryRepository.create(entry);
    }
  }

  Future<void> removeFromLibrary(String uid) async {
    await libraryEntryRepository.deleteByUid(uid);
  }

  Future<void> markRead(String uid) async {
    final LibraryEntryDomain? existing =
        await libraryEntryRepository.getByUid(uid);
    if (existing == null) return;
    await libraryEntryRepository.update(
      existing.copyWith(lastReadAt: DateTime.now()),
    );
  }

  Future<void> moveToCategory(LibraryEntryDomain entry, int? categoryId) async {
    await libraryEntryRepository.update(
      entry.copyWith(categoryId: categoryId, clearCategory: categoryId == null),
    );
  }

  Future<void> moveManyToCategory(
      Iterable<LibraryEntryDomain> entries, int? categoryId) async {
    for (final LibraryEntryDomain entry in entries) {
      await libraryEntryRepository.update(
        entry.copyWith(
            categoryId: categoryId, clearCategory: categoryId == null),
      );
    }
  }

  Future<void> removeMany(Iterable<String> uids) async {
    for (final String uid in uids) {
      await libraryEntryRepository.deleteByUid(uid);
    }
  }

  void setSort(LibrarySort sort) {
    emit(state.copyWith(sort: sort));
  }

  Future<void> addCategory(String name) async {
    final int nextOrder = state.categories.isEmpty
        ? 0
        : state.categories
                .map((CategoryDomain c) => c.sortOrder)
                .reduce((int a, int b) => a > b ? a : b) +
            1;
    await categoryRepository.create(
      CategoryDomain(
        id: 0,
        name: name,
        sortOrder: nextOrder,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> renameCategory(CategoryDomain category, String name) async {
    await categoryRepository.update(category.copyWith(name: name));
  }

  Future<void> deleteCategory(CategoryDomain category) async {
    await libraryEntryRepository.clearCategory(category.id);
    await categoryRepository.delete(category);
  }

  @override
  Future<void> close() {
    _entriesSub?.cancel();
    _categoriesSub?.cancel();
    return super.close();
  }
}
