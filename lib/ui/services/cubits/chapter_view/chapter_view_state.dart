import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';

abstract class ChapterViewState {
  const ChapterViewState();
}

class ChapterViewInit extends ChapterViewState {}

class ChapterViewInitialized extends ChapterViewState {
  final ChapterViewerData data;

  final List<Pages> pages;
  final Pages currentPages;
  final Map<String, String> headers;

  final ChaptersGroup group;

  final ConcreteDataDomain? concreteData;

  final int currentPage;
  final int totalPages;

  final ChapterViewMode mode;
  final bool controlsVisible;
  final bool controlsEnabled;

  final bool canGetNextPages;
  final bool canGetPreviousPages;

  const ChapterViewInitialized({
    required this.data,
    required this.pages,
    required this.currentPages,
    required this.headers,
    required this.group,
    required this.concreteData,
    required this.currentPage,
    required this.totalPages,
    required this.mode,
    required this.controlsVisible,
    required this.controlsEnabled,
    required this.canGetNextPages,
    required this.canGetPreviousPages,
  });

  ChapterViewInitialized copyWith({
    ChapterViewerData? data,
    List<Pages>? pages,
    Pages? currentPages,
    Map<String, String>? headers,
    ChaptersGroup? group,
    ConcreteDataDomain? concreteData,
    int? currentPage,
    int? totalPages,
    ChapterViewMode? mode,
    bool? controlsVisible,
    bool? controlsEnabled,
    bool? canGetNextPages,
    bool? canGetPreviousPages,
  }) {
    return ChapterViewInitialized(
      data: data ?? this.data,
      pages: pages ?? this.pages,
      currentPages: currentPages ?? this.currentPages,
      headers: headers ?? this.headers,
      group: group ?? this.group,
      concreteData: concreteData ?? this.concreteData,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      mode: mode ?? this.mode,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      controlsEnabled: controlsEnabled ?? this.controlsEnabled,
      canGetNextPages: canGetNextPages ?? this.canGetNextPages,
      canGetPreviousPages: canGetPreviousPages ?? this.canGetPreviousPages,
    );
  }
}

class ChapterViewError extends ChapterViewState {
  final String message;

  const ChapterViewError({required this.message});
}
