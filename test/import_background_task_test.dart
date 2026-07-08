import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/services/import_export/import_export_task.dart';
import 'package:wakaranai/services/import_export/import_task_store.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.docs);

  final String docs;

  @override
  Future<String?> getApplicationDocumentsPath() async => docs;
}

ExportBundle _bundle() => ExportBundle(
      version: ImportExportService.exportVersion,
      exportedAt: DateTime(2024),
      concreteData: <ExportConcrete>[
        ExportConcrete(
          uid: 'manga-a',
          extensionUid: 'ext',
          title: 'Manga A',
          createdAt: DateTime(2024),
        ),
      ],
      mangaChapterActivities: <ExportChapterActivity>[
        ExportChapterActivity(
          uid: 'ch-1',
          concreteUid: 'manga-a',
          title: 'Chapter 1',
          readPages: 4,
          totalPages: 10,
          createdAt: DateTime(2024),
        ),
      ],
      categories: <ExportCategory>[
        ExportCategory(name: 'Reading', sortOrder: 0, createdAt: DateTime(2024)),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wakaranai_bg_import');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      return;
    }
  });

  Future<File> writeBundle(ExportBundle bundle) async {
    final File file = File(p.join(tempDir.path, 'pending_import.json'));
    await file.writeAsString(jsonEncode(bundle.toJson()));
    return file;
  }

  test('background task imports the bundle and marks itself done', () async {
    final File file = await writeBundle(_bundle());

    final bool ok = await runImportTask(<String, dynamic>{
      importTaskPathKey: file.path,
      importTaskSectionsKey: encodeExportSections(<ExportSection>{
        ExportSection.history,
        ExportSection.categories,
      }),
      importTaskLocaleKey: 'en',
    });

    expect(ok, isTrue);

    final ImportTaskSnapshot snapshot = await ImportTaskStore().read();
    expect(snapshot.status, ImportTaskStatus.done);
    expect(snapshot.imported, 2);
    expect(snapshot.skipped, 0);
    expect(snapshot.processed, snapshot.total);

    expect(file.existsSync(), isFalse);
    expect(File(p.join(tempDir.path, 'smt.sqlite')).existsSync(), isTrue);

    final WakaranaiDatabase db = WakaranaiDatabase();
    final ConcreteDataDomain? concrete =
        await ConcreteDataRepository(database: db).getByUid('manga-a');
    expect(concrete, isNotNull);

    final List<ChapterActivityDomain> activities =
        await ChapterActivityRepository(database: db).getAll();
    expect(activities.single.uid, 'ch-1');
    expect(activities.single.readPages, 4);
    expect(activities.single.concreteId, concrete!.id);

    final List<CategoryDomain> categories =
        await CategoryRepository(database: db).getAll();
    expect(categories.single.name, 'Reading');

    await db.close();
  });

  test('a late progress write cannot flip a finished task back to running',
      () async {
    final ImportTaskStore store = ImportTaskStore();
    await store.setRunning();
    await store.setDone(imported: 5, total: 5, skipped: 0);

    await store.setProgress(
        section: ExportSection.history, processed: 2, total: 5);

    expect((await store.read()).status, ImportTaskStatus.done);
  });

  test('missing path fails the task instead of throwing', () async {
    final bool ok = await runImportTask(<String, dynamic>{
      importTaskSectionsKey: encodeExportSections(<ExportSection>{
        ExportSection.history,
      }),
    });
    expect(ok, isFalse);
  });

  test('empty section selection fails the task', () async {
    final File file = await writeBundle(_bundle());
    final bool ok = await runImportTask(<String, dynamic>{
      importTaskPathKey: file.path,
      importTaskSectionsKey: '',
    });
    expect(ok, isFalse);
  });

  test('a corrupt bundle marks the task failed and clears the notification',
      () async {
    final File file = File(p.join(tempDir.path, 'pending_import.json'));
    await file.writeAsString('{not json');

    final bool ok = await runImportTask(<String, dynamic>{
      importTaskPathKey: file.path,
      importTaskSectionsKey:
          encodeExportSections(<ExportSection>{ExportSection.history}),
    });

    expect(ok, isFalse);
    expect((await ImportTaskStore().read()).status, ImportTaskStatus.failed);
  });

  test('export sections survive an encode/decode round trip', () {
    const Set<ExportSection> sections = <ExportSection>{
      ExportSection.history,
      ExportSection.settings,
    };
    expect(decodeExportSections(encodeExportSections(sections)), sections);
    expect(decodeExportSections(''), isEmpty);
    expect(decodeExportSections('history,bogus'),
        <ExportSection>{ExportSection.history});
  });
}
