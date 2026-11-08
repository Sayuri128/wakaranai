import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/blocs/auto_backup/auto_backup_cubit.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/services/import_export/backup_files.dart';

class _FakeFiles implements BackupFiles {
  final List<String> saved = <String>[];
  final List<int> pruneLimits = <int>[];
  bool fail = false;

  @override
  Future<String> save(String name, Uint8List bytes) async {
    if (fail) {
      throw StateError('storage full');
    }
    saved.add(name);
    return 'Download/Wakaranai/$name';
  }

  @override
  Future<int> prune(String prefix, int keep) async {
    pruneLimits.add(keep);
    return 0;
  }
}

void main() {
  late _FakeFiles files;
  late List<Set<ExportSection>> exportedSections;
  late DateTime now;

  AutoBackupCubit buildCubit() {
    return AutoBackupCubit(
      buildExport: (Set<ExportSection> sections) async {
        exportedSections.add(sections);
        return ExportBundle(version: 2, exportedAt: now);
      },
      files: files,
      clock: () => now,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    files = _FakeFiles();
    exportedSections = <Set<ExportSection>>[];
    now = DateTime(2026, 10, 26, 9, 30);
  });

  test('backs up once a day and keeps the newest five', () async {
    final AutoBackupCubit cubit = buildCubit();
    addTearDown(cubit.close);

    expect(await cubit.backUpIfDue(), isTrue);
    expect(files.saved.single, 'wakaranai_auto_backup_2026-10-26_09-30.json');
    expect(files.pruneLimits, <int>[AutoBackupCubit.backupsToKeep]);
    expect(
      exportedSections.single,
      isNot(contains(ExportSection.translations)),
    );

    now = now.add(const Duration(hours: 5));
    expect(await cubit.backUpIfDue(), isFalse);

    now = now.add(const Duration(days: 1));
    expect(await cubit.backUpIfDue(), isTrue);
    expect(files.saved, hasLength(2));
  });

  test('turning backups off stops them', () async {
    final AutoBackupCubit cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.setEnabled(false);

    expect(await cubit.backUpIfDue(), isFalse);
    expect(files.saved, isEmpty);
  });

  test('a failed backup is reported and retried next time', () async {
    final AutoBackupCubit cubit = buildCubit();
    addTearDown(cubit.close);
    files.fail = true;

    expect(await cubit.backUpIfDue(), isFalse);
    expect(cubit.state.failed, isTrue);

    files.fail = false;
    expect(await cubit.backUpIfDue(), isTrue);
    expect(cubit.state.failed, isFalse);
  });
}
