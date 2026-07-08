import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';

enum ImportTaskStatus { idle, running, done, failed }

class ImportTaskSnapshot {
  final ImportTaskStatus status;
  final ExportSection? section;
  final int processed;
  final int total;
  final int imported;
  final int skipped;

  const ImportTaskSnapshot({
    required this.status,
    this.section,
    this.processed = 0,
    this.total = 0,
    this.imported = 0,
    this.skipped = 0,
  });
}

class ImportTaskStore {
  static const String _statusKey = 'IMPORT_TASK_STATUS';
  static const String _sectionKey = 'IMPORT_TASK_SECTION';
  static const String _processedKey = 'IMPORT_TASK_PROCESSED';
  static const String _totalKey = 'IMPORT_TASK_TOTAL';
  static const String _importedKey = 'IMPORT_TASK_IMPORTED';
  static const String _skippedKey = 'IMPORT_TASK_SKIPPED';

  Future<SharedPreferences> _prefs({bool reload = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (reload) {
      await prefs.reload();
    }
    return prefs;
  }

  Future<void> setRunning() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(_statusKey, ImportTaskStatus.running.name);
    await prefs.setInt(_processedKey, 0);
    await prefs.setInt(_totalKey, 0);
    await prefs.remove(_sectionKey);
  }

  Future<void> setProgress({
    ExportSection? section,
    required int processed,
    required int total,
  }) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setInt(_processedKey, processed);
    await prefs.setInt(_totalKey, total);
    if (section != null) {
      await prefs.setString(_sectionKey, section.name);
    } else {
      await prefs.remove(_sectionKey);
    }
  }

  Future<void> setDone({
    required int imported,
    required int total,
    required int skipped,
  }) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(_statusKey, ImportTaskStatus.done.name);
    await prefs.setInt(_importedKey, imported);
    await prefs.setInt(_totalKey, total);
    await prefs.setInt(_processedKey, total);
    await prefs.setInt(_skippedKey, skipped);
  }

  Future<void> setFailed() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(_statusKey, ImportTaskStatus.failed.name);
  }

  Future<ImportTaskSnapshot> read({bool reload = true}) async {
    final SharedPreferences prefs = await _prefs(reload: reload);

    final String? rawStatus = prefs.getString(_statusKey);
    final ImportTaskStatus status = ImportTaskStatus.values
            .where((ImportTaskStatus s) => s.name == rawStatus)
            .firstOrNull ??
        ImportTaskStatus.idle;

    final String? rawSection = prefs.getString(_sectionKey);

    return ImportTaskSnapshot(
      status: status,
      section: rawSection == null
          ? null
          : decodeExportSections(rawSection).firstOrNull,
      processed: prefs.getInt(_processedKey) ?? 0,
      total: prefs.getInt(_totalKey) ?? 0,
      imported: prefs.getInt(_importedKey) ?? 0,
      skipped: prefs.getInt(_skippedKey) ?? 0,
    );
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(_statusKey);
    await prefs.remove(_sectionKey);
    await prefs.remove(_processedKey);
    await prefs.remove(_totalKey);
    await prefs.remove(_importedKey);
    await prefs.remove(_skippedKey);
  }
}
