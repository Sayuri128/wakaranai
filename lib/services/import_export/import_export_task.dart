import 'dart:convert';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/widgets.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/category_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/services/import_export/export_section_labels.dart';
import 'package:wakaranai/services/import_export/import_export_notification_service.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/services/import_export/import_task_store.dart';
import 'package:workmanager/workmanager.dart';

const String importTaskName = 'wakaranai.import';
const String importTaskUniqueName = 'wakaranai.import.oneoff';

const String importTaskPathKey = 'path';
const String importTaskSectionsKey = 'sections';
const String importTaskLocaleKey = 'locale';

@pragma('vm:entry-point')
void importExportCallbackDispatcher() {
  Workmanager().executeTask(
    (String taskName, Map<String, dynamic>? inputData) async {
      if (taskName != importTaskName) return true;
      return runImportTask(inputData);
    },
  );
}

Future<bool> runImportTask(Map<String, dynamic>? inputData) async {
  DartPluginRegistrant.ensureInitialized();

  final String? path = inputData?[importTaskPathKey] as String?;
  final String sectionsRaw =
      inputData?[importTaskSectionsKey] as String? ?? '';
  final String localeName = inputData?[importTaskLocaleKey] as String? ?? 'en';

  if (path == null) return false;

  final Set<ExportSection> sections = decodeExportSections(sectionsRaw);
  if (sections.isEmpty) return false;

  await S.load(Locale(localeName));

  final ImportTaskStore store = ImportTaskStore();
  final ImportExportNotificationService notifications =
      ImportExportNotificationService();

  final File file = File(path);
  WakaranaiDatabase? database;

  try {
    await store.setRunning();

    final ExportBundle bundle = ExportBundle.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>);

    database = WakaranaiDatabase();

    final ImportExportService service = ImportExportService(
      concreteDataRepository: ConcreteDataRepository(database: database),
      chapterActivityRepository: ChapterActivityRepository(database: database),
      animeEpisodeActivityRepository:
          AnimeEpisodeActivityRepository(database: database),
      categoryRepository: CategoryRepository(database: database),
      libraryEntryRepository: LibraryEntryRepository(database: database),
      extensionSourceRepository: ExtensionSourceRepository(database: database),
    );

    DateTime lastPublish = DateTime.fromMillisecondsSinceEpoch(0);
    Future<void> publishChain = Future<void>.value();

    final ImportResult result = await service.applyImport(
      bundle,
      sections,
      onProgress: (ImportExportProgress progress) {
        final DateTime now = DateTime.now();
        final bool finished =
            progress.total > 0 && progress.processed >= progress.total;
        if (!finished &&
            now.difference(lastPublish) < const Duration(milliseconds: 400)) {
          return;
        }
        lastPublish = now;

        publishChain = publishChain.then((_) async {
          await store.setProgress(
            section: progress.section,
            processed: progress.processed,
            total: progress.total,
          );
          await notifications.showProgress(
            title: S.current.settings_import_progress_title,
            body: progress.section != null
                ? exportSectionTitle(progress.section!)
                : S.current.settings_progress_preparing,
            processed: progress.processed,
            total: progress.total,
          );
        });
      },
    );

    await publishChain;

    await store.setDone(
      imported: result.imported,
      total: result.total,
      skipped: result.skipped,
    );

    await notifications.showComplete(
      title: S.current.settings_import_notification_complete,
      body: S.current.settings_import_success(
          result.imported, result.total),
    );

    return true;
  } catch (e, s) {
    logger.e(e);
    logger.e(s);
    await store.setFailed();
    await notifications.cancelProgress();
    return false;
  } finally {
    await database?.close();
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      logger.w('Failed to delete pending import file: $e');
    }
  }
}
