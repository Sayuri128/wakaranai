part of 'page_translation_cubit.dart';

enum PageTranslationPhase {
  off,
  choosingLanguages,
  preparing,
  needsModels,
  downloading,
  active,
}

enum PageTranslationStatus { queued, running, done, failed, modelPending }

class PageTranslationEntry extends Equatable {
  const PageTranslationEntry(this.status, {this.result});

  final PageTranslationStatus status;
  final PageTranslationResult? result;

  @override
  List<Object?> get props => <Object?>[status, result];
}

class PageTranslationState extends Equatable {
  const PageTranslationState({
    this.phase = PageTranslationPhase.off,
    this.pages = const <String, PageTranslationEntry>{},
    this.hidden = const <String>{},
    this.downloadFailed = false,
    this.languages,
    this.pinned = const <String>{},
  });

  final PageTranslationPhase phase;
  final Map<String, PageTranslationEntry> pages;
  final Set<String> hidden;
  final bool downloadFailed;
  final TitleLanguages? languages;
  final Set<String> pinned;

  int get pinnedDone => pinned
      .where((String path) => pages[path]?.status == PageTranslationStatus.done)
      .length;

  bool get translatingChapter =>
      pinned.isNotEmpty && pinnedDone < pinned.length;

  bool get active => phase == PageTranslationPhase.active;

  bool get busy =>
      phase == PageTranslationPhase.preparing ||
      phase == PageTranslationPhase.downloading;

  PageTranslationEntry? entry(String path) => pages[path];

  bool isHidden(String path, int index) => hidden.contains('$path#$index');

  PageTranslationState copyWith({
    PageTranslationPhase? phase,
    Map<String, PageTranslationEntry>? pages,
    Set<String>? hidden,
    bool? downloadFailed,
    TitleLanguages? languages,
    Set<String>? pinned,
  }) {
    return PageTranslationState(
      phase: phase ?? this.phase,
      pages: pages ?? this.pages,
      hidden: hidden ?? this.hidden,
      downloadFailed: downloadFailed ?? this.downloadFailed,
      languages: languages ?? this.languages,
      pinned: pinned ?? this.pinned,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    phase,
    pages,
    hidden,
    downloadFailed,
    languages,
    pinned,
  ];
}
