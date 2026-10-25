import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/auto_backup_preferences.dart';
import 'package:wakaranai/services/import_export/backup_files.dart';

class AutoBackupState extends Equatable {
  const AutoBackupState({
    this.loaded = false,
    this.enabled = true,
    this.running = false,
    this.failed = false,
    this.lastBackupAt,
  });

  final bool loaded;
  final bool enabled;
  final bool running;
  final bool failed;
  final DateTime? lastBackupAt;

  AutoBackupState copyWith({
    bool? loaded,
    bool? enabled,
    bool? running,
    bool? failed,
    DateTime? lastBackupAt,
  }) {
    return AutoBackupState(
      loaded: loaded ?? this.loaded,
      enabled: enabled ?? this.enabled,
      running: running ?? this.running,
      failed: failed ?? this.failed,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loaded,
    enabled,
    running,
    failed,
    lastBackupAt,
  ];
}

class AutoBackupCubit extends Cubit<AutoBackupState> {
  AutoBackupCubit({
    required Future<ExportBundle> Function(Set<ExportSection> sections)
    buildExport,
    required BackupFiles files,
    AutoBackupPreferences? preferences,
    DateTime Function()? clock,
  }) : _buildExport = buildExport,
       _files = files,
       _preferences = preferences ?? AutoBackupPreferences(),
       _clock = clock ?? DateTime.now,
       super(const AutoBackupState());

  static const Duration interval = Duration(days: 1);
  static const int backupsToKeep = 5;
  static const String filePrefix = 'wakaranai_auto_backup_';

  static final Set<ExportSection> backedUpSections = ExportSection.values
      .where((ExportSection section) => section != ExportSection.translations)
      .toSet();

  final Future<ExportBundle> Function(Set<ExportSection> sections) _buildExport;
  final BackupFiles _files;
  final AutoBackupPreferences _preferences;
  final DateTime Function() _clock;
  Future<void>? _loading;

  Future<void> init() => _loading ??= _load();

  Future<void> _load() async {
    final bool enabled = await _preferences.isEnabled();
    final DateTime? lastBackupAt = await _preferences.lastBackupAt();
    _emit(
      AutoBackupState(
        loaded: true,
        enabled: enabled,
        lastBackupAt: lastBackupAt,
      ),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await init();
    await _preferences.setEnabled(enabled);
    _emit(state.copyWith(enabled: enabled));
    if (enabled) {
      await backUpIfDue();
    }
  }

  Future<bool> backUpIfDue() async {
    await init();
    if (!state.enabled || state.running) {
      return false;
    }
    final DateTime? last = state.lastBackupAt;
    if (last != null && _clock().difference(last) < interval) {
      return false;
    }
    return backUpNow();
  }

  Future<bool> backUpNow() async {
    await init();
    if (state.running) {
      return false;
    }
    _emit(state.copyWith(running: true, failed: false));
    try {
      final ExportBundle bundle = await _buildExport(backedUpSections);
      final DateTime now = _clock();
      final Uint8List bytes = Uint8List.fromList(
        utf8.encode(jsonEncode(bundle.toJson())),
      );
      await _files.save('$filePrefix${_fileStamp(now)}.json', bytes);
      await _files.prune(filePrefix, backupsToKeep);
      await _preferences.setLastBackupAt(now);
      _emit(state.copyWith(running: false, lastBackupAt: now));
      return true;
    } catch (e) {
      logger.w('Automatic backup failed: $e');
      _emit(state.copyWith(running: false, failed: true));
      return false;
    }
  }

  static String _fileStamp(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${time.year}-${twoDigits(time.month)}-${twoDigits(time.day)}_'
        '${twoDigits(time.hour)}-${twoDigits(time.minute)}';
  }

  void _emit(AutoBackupState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
