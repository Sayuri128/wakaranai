import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/novel/novel_chapter_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';
import 'package:wakaranai/services/novels/novel_progress.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

part 'novel_reader_state.dart';

typedef NovelChapterTextLoader = Future<String> Function(Chapter chapter);

class NovelReaderCubit extends Cubit<NovelReaderState> {
  NovelReaderCubit({
    required this.concreteUid,
    required this.chapters,
    required this.chapterActivityRepository,
    required this.concreteDataRepository,
    required this.loadChapterText,
    this.activityWriteDelay = const Duration(seconds: 1),
  }) : super(const NovelReaderLoading());

  factory NovelReaderCubit.forClient({
    required NovelApiClient client,
    required String concreteUid,
    required List<Chapter> chapters,
    required ChapterActivityRepository chapterActivityRepository,
    required ConcreteDataRepository concreteDataRepository,
    required DownloadRepository downloadRepository,
  }) {
    return NovelReaderCubit(
      concreteUid: concreteUid,
      chapters: chapters,
      chapterActivityRepository: chapterActivityRepository,
      concreteDataRepository: concreteDataRepository,
      loadChapterText: downloadFirstLoader(
        client: client,
        downloadRepository: downloadRepository,
      ),
    );
  }

  final String concreteUid;
  final List<Chapter> chapters;
  final ChapterActivityRepository chapterActivityRepository;
  final ConcreteDataRepository concreteDataRepository;
  final NovelChapterTextLoader loadChapterText;
  final Duration activityWriteDelay;

  Timer? _activityDebounce;
  ChapterActivityDomain? _pendingActivity;
  int? _lastWrittenUnits;
  int _openGeneration = 0;

  static NovelChapterTextLoader downloadFirstLoader({
    required NovelApiClient client,
    required DownloadRepository downloadRepository,
  }) {
    return (Chapter chapter) async {
      final DownloadDomain? download =
          await downloadRepository.getByUid(chapter.uid);
      if (download != null) {
        final String? saved =
            await DownloadFiles.readNovelChapterFile(download);
        if (saved != null) {
          return saved;
        }
      }
      final NovelChapterContent content = await runSerializedOn(
        client,
        () => client.getChapterText(uid: chapter.uid, data: chapter.data),
      );
      return content.html;
    };
  }

  Future<void> open(Chapter chapter, {double? initialFraction}) async {
    await flushProgress();
    final int generation = ++_openGeneration;
    if (isClosed) {
      return;
    }
    emit(NovelReaderLoading(chapter: chapter));
    try {
      final String html = await loadChapterText(chapter);
      final ConcreteDataDomain? concrete =
          await concreteDataRepository.getByUid(concreteUid);
      final ChapterActivityDomain? existing = await _activityOf(chapter.uid);
      if (isClosed || generation != _openGeneration) {
        return;
      }
      final bool wasFinished = NovelProgress.isFinished(existing);
      final double startFraction =
          initialFraction ?? NovelProgress.resumeFractionOf(existing);
      _lastWrittenUnits = null;
      emit(NovelReaderLoaded(
        chapter: chapter,
        html: html,
        concrete: concrete,
        initialFraction: NovelProgress.clampFraction(startFraction),
        fraction: NovelProgress.clampFraction(startFraction),
        wasFinished: wasFinished,
        previous: chapterBefore(chapters, chapter.uid),
        next: chapterAfter(chapters, chapter.uid),
      ));
      await _writeActivity(
        _activityFor(chapter, concrete, _storedUnitsOf(existing)),
      );
    } catch (error, stack) {
      logger.e('Failed to open novel chapter ${chapter.uid}: $error');
      logger.e(stack);
      if (isClosed || generation != _openGeneration) {
        return;
      }
      emit(NovelReaderError(chapter: chapter, error: error));
    }
  }

  Future<void> retry() async {
    final Chapter? chapter = state.chapter;
    if (chapter == null) {
      return;
    }
    await open(chapter);
  }

  Future<void> openNext() async {
    final NovelReaderState current = state;
    if (current is! NovelReaderLoaded) {
      return;
    }
    final Chapter? next = current.next;
    if (next == null) {
      return;
    }
    await open(next, initialFraction: 0);
  }

  Future<void> openPrevious() async {
    final NovelReaderState current = state;
    if (current is! NovelReaderLoaded) {
      return;
    }
    final Chapter? previous = current.previous;
    if (previous == null) {
      return;
    }
    await open(previous, initialFraction: 0);
  }

  void recordProgress(double fraction) {
    final NovelReaderState current = state;
    if (current is! NovelReaderLoaded) {
      return;
    }
    final double clamped = NovelProgress.clampFraction(fraction);
    if (clamped != current.fraction) {
      emit(current.copyWith(fraction: clamped));
    }
    final int units =
        NovelProgress.unitsFor(clamped, keepCompleted: current.wasFinished);
    if (units == _lastWrittenUnits) {
      return;
    }
    _lastWrittenUnits = units;
    _scheduleWrite(_activityFor(current.chapter, current.concrete, units));
  }

  static int _storedUnitsOf(ChapterActivityDomain? existing) {
    if (existing == null) {
      return 0;
    }
    if (NovelProgress.isFinished(existing)) {
      return NovelProgress.scale;
    }
    return NovelProgress.unitsFor(NovelProgress.fractionOf(existing));
  }

  ChapterActivityDomain? _activityFor(
    Chapter chapter,
    ConcreteDataDomain? concrete,
    int units,
  ) {
    if (concrete == null) {
      return null;
    }
    return ChapterActivityDomain(
      id: 0,
      uid: chapter.uid,
      concreteId: concrete.id,
      title: chapter.title,
      data: jsonEncode(chapter.data),
      timestamp: chapter.timestamp,
      readPages: units,
      totalPages: NovelProgress.scale,
      createdAt: DateTime.now(),
    );
  }

  Future<ChapterActivityDomain?> _activityOf(String uid) {
    return chapterActivityRepository.getBy<$ChapterActivityTableTable>(
      uid,
      where: (tbl) => tbl.uid,
    );
  }

  void _scheduleWrite(ChapterActivityDomain? activity) {
    if (activity == null) {
      return;
    }
    _pendingActivity = activity;
    _activityDebounce?.cancel();
    _activityDebounce = Timer(activityWriteDelay, () {
      unawaited(flushProgress());
    });
  }

  Future<void> flushProgress() async {
    _activityDebounce?.cancel();
    _activityDebounce = null;
    final ChapterActivityDomain? activity = _pendingActivity;
    _pendingActivity = null;
    await _writeActivity(activity);
  }

  Future<void> _writeActivity(ChapterActivityDomain? activity) async {
    if (activity == null || IncognitoMode.active) {
      return;
    }
    await chapterActivityRepository
        .createUpdateBy<$ChapterActivityTableTable, String>(
      activity,
      by: (tbl) => tbl.uid,
      where: (tbl) => tbl.uid,
    );
  }

  @override
  Future<void> close() async {
    await flushProgress();
    return super.close();
  }
}
