import 'dart:io';

import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';
import 'package:wakaranai/services/novels/novel_progress.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_cubit.dart';

const List<Chapter> _chapters = <Chapter>[
  Chapter(uid: 'c1', title: 'One', data: <String, dynamic>{}),
  Chapter(uid: 'c2', title: 'Two', data: <String, dynamic>{}),
  Chapter(uid: 'c3', title: 'Three', data: <String, dynamic>{}),
];

void main() {
  late WakaranaiDatabase database;
  late ChapterActivityRepository activities;
  late ConcreteDataRepository concretes;
  late int concreteId;

  setUp(() async {
    IncognitoMode.active = false;
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    activities = ChapterActivityRepository(database: database);
    concretes = ConcreteDataRepository(database: database);
    final ConcreteDataDomain? concrete = await concretes.create(
      ConcreteDataDomain(
        id: 0,
        uid: 'novel-1',
        extensionUid: 'ext',
        title: 'Novel',
        createdAt: DateTime(2025),
      ),
    );
    concreteId = concrete!.id;
  });

  tearDown(() async {
    IncognitoMode.active = false;
    await database.close();
  });

  NovelReaderCubit cubit({NovelChapterTextLoader? loader}) {
    return NovelReaderCubit(
      concreteUid: 'novel-1',
      chapters: _chapters,
      chapterActivityRepository: activities,
      concreteDataRepository: concretes,
      loadChapterText:
          loader ?? (Chapter chapter) async => '<p>${chapter.title}</p>',
      activityWriteDelay: Duration.zero,
    );
  }

  Future<ChapterActivityDomain?> stored(String uid) {
    return activities.getBy<$ChapterActivityTableTable>(
      uid,
      where: (tbl) => tbl.uid,
    );
  }

  test('opening a chapter records it with the novel progress scale', () async {
    final NovelReaderCubit reader = cubit();

    await reader.open(_chapters[1]);

    final NovelReaderState state = reader.state;
    expect(state, isA<NovelReaderLoaded>());
    final NovelReaderLoaded loaded = state as NovelReaderLoaded;
    expect(loaded.html, '<p>Two</p>');
    expect(loaded.previous?.uid, 'c1');
    expect(loaded.next?.uid, 'c3');
    final ChapterActivityDomain? activity = await stored('c2');
    expect(activity?.readPages, 0);
    expect(activity?.totalPages, NovelProgress.scale);
    expect(activity?.concreteId, concreteId);
    await reader.close();
  });

  test('scroll progress is saved and finishing marks the chapter read',
      () async {
    final NovelReaderCubit reader = cubit();
    await reader.open(_chapters[0]);

    reader.recordProgress(0.4);
    await reader.flushProgress();
    expect((await stored('c1'))?.readPages, 400);

    reader.recordProgress(0.99);
    await reader.flushProgress();
    final ChapterActivityDomain? finished = await stored('c1');
    expect(finished?.readPages, NovelProgress.scale);
    expect(NovelProgress.isFinished(finished), isTrue);
    await reader.close();
  });

  test('resumes at the saved position and keeps finished chapters read',
      () async {
    final NovelReaderCubit first = cubit();
    await first.open(_chapters[0]);
    first.recordProgress(0.3);
    await first.close();

    final NovelReaderCubit resumed = cubit();
    await resumed.open(_chapters[0]);
    expect((resumed.state as NovelReaderLoaded).initialFraction, 0.3);
    resumed.recordProgress(1);
    await resumed.close();

    final NovelReaderCubit reread = cubit();
    await reread.open(_chapters[0]);
    final NovelReaderLoaded loaded = reread.state as NovelReaderLoaded;
    expect(loaded.initialFraction, 0);
    expect(loaded.wasFinished, isTrue);
    reread.recordProgress(0.1);
    await reread.close();

    expect((await stored('c1'))?.readPages, NovelProgress.scale);
  });

  test('incognito mode writes no progress', () async {
    IncognitoMode.active = true;
    final NovelReaderCubit reader = cubit();

    await reader.open(_chapters[0]);
    reader.recordProgress(0.5);
    await reader.close();

    expect(await stored('c1'), isNull);
  });

  test('next and previous move through the reading order', () async {
    final NovelReaderCubit reader = cubit();
    await reader.open(_chapters[0]);

    await reader.openNext();
    expect(reader.state.chapter?.uid, 'c2');
    await reader.openNext();
    expect((reader.state as NovelReaderLoaded).next, isNull);
    await reader.openPrevious();
    expect(reader.state.chapter?.uid, 'c2');
    await reader.close();
  });

  test('a failing source surfaces an error that can be retried', () async {
    int attempts = 0;
    final NovelReaderCubit reader = cubit(loader: (Chapter chapter) async {
      attempts++;
      if (attempts == 1) {
        throw StateError('offline');
      }
      return '<p>ok</p>';
    });

    await reader.open(_chapters[0]);
    expect(reader.state, isA<NovelReaderError>());

    await reader.retry();
    expect((reader.state as NovelReaderLoaded).html, '<p>ok</p>');
    await reader.close();
  });

  test('a saved chapter file is read back for offline reading', () async {
    final Directory dir =
        await Directory.systemTemp.createTemp('novel_download_test');
    addTearDown(() => dir.delete(recursive: true));
    await DownloadManagerCubit.writeNovelChapterFile(dir.path, '<p>saved</p>');

    DownloadDomain download(DownloadKind kind, DownloadStatus status) {
      return DownloadDomain(
        id: 0,
        uid: 'c1',
        extensionUid: 'ext',
        concreteUid: 'novel-1',
        concreteId: concreteId,
        concreteTitle: 'Novel',
        title: 'One',
        status: status,
        downloadedPages: 1,
        totalPages: 1,
        dirPath: dir.path,
        kind: kind,
        createdAt: DateTime(2025),
      );
    }

    expect(
      await DownloadManagerCubit.readNovelChapterFile(
        download(DownloadKind.novelChapter, DownloadStatus.done),
      ),
      '<p>saved</p>',
    );
    expect(
      await DownloadManagerCubit.readNovelChapterFile(
        download(DownloadKind.novelChapter, DownloadStatus.queued),
      ),
      isNull,
    );
    expect(
      await DownloadManagerCubit.readNovelChapterFile(
        download(DownloadKind.chapter, DownloadStatus.done),
      ),
      isNull,
    );
  });

  test('novel downloads keep the stored kind indexes stable', () {
    expect(DownloadKind.chapter.index, 0);
    expect(DownloadKind.episode.index, 1);
    expect(DownloadKind.novelChapter.index, 2);
  });

  test('marking a novel chapter read fills the whole progress scale',
      () async {
    await activities.markCompleted(
      ChapterActivityDomain(
        id: 0,
        uid: 'c3',
        title: 'Three',
        timestamp: null,
        data: '{}',
        concreteId: concreteId,
        readPages: 0,
        totalPages: 0,
        createdAt: DateTime(2025),
      ),
      completedPages: NovelProgress.scale,
    );

    final ChapterActivityDomain? activity = await stored('c3');
    expect(activity?.readPages, NovelProgress.scale);
    expect(activity?.totalPages, NovelProgress.scale);
    expect(NovelProgress.isFinished(activity), isTrue);
  });
}
