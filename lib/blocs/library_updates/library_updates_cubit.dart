import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/library_updates/library_update_service.dart';

part 'library_updates_state.dart';

class LibraryUpdatesCubit extends Cubit<LibraryUpdatesState> {
  LibraryUpdatesCubit({
    required this.libraryEntryRepository,
    required this.libraryUpdateRepository,
    required this.concreteDataRepository,
    required this.extensionRepository,
  }) : super(const LibraryUpdatesState());

  final LibraryEntryRepository libraryEntryRepository;
  final LibraryUpdateRepository libraryUpdateRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ExtensionRepository extensionRepository;

  StreamSubscription<List<LibraryUpdateDomain>>? _updatesSub;
  StreamSubscription<int>? _unseenSub;

  void init() {
    _updatesSub?.cancel();
    _unseenSub?.cancel();

    _updatesSub = libraryUpdateRepository.watchAll().listen(
      (List<LibraryUpdateDomain> updates) {
        emit(state.copyWith(updates: updates));
      },
    );

    _unseenSub = libraryUpdateRepository.watchUnseenCount().listen(
      (int count) {
        emit(state.copyWith(unseenCount: count));
      },
    );
  }

  Future<LibraryUpdateCheckResult?> checkNow() async {
    if (state.checking) return null;

    emit(state.copyWith(checking: true, clearLastResult: true));

    final LibraryUpdateService service = LibraryUpdateService(
      libraryEntryRepository: libraryEntryRepository,
      libraryUpdateRepository: libraryUpdateRepository,
      concreteDataRepository: concreteDataRepository,
      extensionRepository: extensionRepository,
    );

    try {
      final LibraryUpdateCheckResult result = await service.check();
      emit(state.copyWith(checking: false, lastResult: result));
      return result;
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      emit(state.copyWith(checking: false));
      return null;
    }
  }

  Future<void> markSeen(String uid) async {
    await libraryUpdateRepository.markSeen(uid);
  }

  Future<void> markAllSeen() async {
    await libraryUpdateRepository.markAllSeen();
  }

  Future<void> clearAll() async {
    await libraryUpdateRepository.deleteAll();
  }

  Future<void> dismiss(String uid) async {
    await libraryUpdateRepository.deleteByUid(uid);
  }

  @override
  Future<void> close() {
    _updatesSub?.cancel();
    _unseenSub?.cancel();
    return super.close();
  }
}
