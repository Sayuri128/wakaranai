import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

void main() {
  late WakaranaiDatabase database;
  late ChapterActivityRepository activityRepository;
  late int concreteId;

  setUp(() async {
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    activityRepository = ChapterActivityRepository(database: database);
    final ConcreteDataDomain? concrete =
        await ConcreteDataRepository(database: database).create(
          ConcreteDataDomain(
            id: 0,
            uid: 'manga-1',
            extensionUid: 'ext',
            title: 'Manga',
            createdAt: DateTime(2024),
          ),
        );
    concreteId = concrete!.id;
  });

  tearDown(() async {
    await database.close();
  });

  ChapterActivityDomain activity({
    int readPages = 0,
    int totalPages = 0,
    DateTime? createdAt,
  }) {
    return ChapterActivityDomain(
      id: 0,
      uid: 'chapter-1',
      title: 'Chapter 1',
      timestamp: null,
      concreteId: concreteId,
      data: '{}',
      readPages: readPages,
      totalPages: totalPages,
      createdAt: createdAt ?? DateTime(2024, 5),
    );
  }

  Future<ChapterActivityDomain?> readActivity() {
    return activityRepository.getBy<$ChapterActivityTableTable>(
      'chapter-1',
      where: (tbl) => tbl.uid,
    );
  }

  test(
    'marking a partly read chapter as read fills its known page count',
    () async {
      await activityRepository.create(
        activity(readPages: 7, totalPages: 20, createdAt: DateTime(2024, 1)),
      );

      await activityRepository.markCompleted(
        activity(createdAt: DateTime(2025)),
      );

      final ChapterActivityDomain? stored = await readActivity();
      expect(stored, isNotNull);
      expect(stored!.readPages, 20);
      expect(stored.totalPages, 20);
      expect(stored.isCompleted, isTrue);
      expect(stored.createdAt, DateTime(2024, 1));
    },
  );

  test('marking a finished chapter as read keeps its progress', () async {
    await activityRepository.create(activity(readPages: 20, totalPages: 20));

    await activityRepository.markCompleted(activity());

    final ChapterActivityDomain? stored = await readActivity();
    expect(stored!.readPages, 20);
    expect(stored.totalPages, 20);
  });

  test(
    'marking an unopened chapter as read records it without pages',
    () async {
      await activityRepository.markCompleted(activity(readPages: 5));

      final ChapterActivityDomain? stored = await readActivity();
      expect(stored, isNotNull);
      expect(stored!.readPages, 0);
      expect(stored.totalPages, 0);
      expect(stored.isCompleted, isTrue);
    },
  );

  test('marking a chapter read twice does not duplicate the row', () async {
    await activityRepository.create(activity(readPages: 3, totalPages: 10));

    await activityRepository.markCompleted(activity());
    await activityRepository.markCompleted(activity());

    final List<ChapterActivityDomain> all = await activityRepository.getAll();
    expect(all, hasLength(1));
    expect(all.single.readPages, 10);
  });
}
