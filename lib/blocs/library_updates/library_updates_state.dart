part of 'library_updates_cubit.dart';

class LibraryUpdatesState {
  final List<LibraryUpdateDomain> updates;
  final int unseenCount;
  final bool checking;
  final LibraryUpdateCheckResult? lastResult;

  const LibraryUpdatesState({
    this.updates = const <LibraryUpdateDomain>[],
    this.unseenCount = 0,
    this.checking = false,
    this.lastResult,
  });

  LibraryUpdatesState copyWith({
    List<LibraryUpdateDomain>? updates,
    int? unseenCount,
    bool? checking,
    LibraryUpdateCheckResult? lastResult,
    bool clearLastResult = false,
  }) {
    return LibraryUpdatesState(
      updates: updates ?? this.updates,
      unseenCount: unseenCount ?? this.unseenCount,
      checking: checking ?? this.checking,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
    );
  }
}
