part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsInitialized extends SettingsState {
  final ChapterViewMode defaultMode;

  final bool showNsfw;

  final bool collectStatistics;

  final bool loading;

  final ImportExportProgress? progress;

  final ImportOutcome? outcome;

  const SettingsInitialized({
    required this.defaultMode,
    required this.showNsfw,
    required this.collectStatistics,
    this.loading = false,
    this.progress,
    this.outcome,
  });

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
    bool? showNsfw,
    bool? collectStatistics,
    bool? loading,
    ImportExportProgress? progress,
    bool clearProgress = false,
    ImportOutcome? outcome,
    bool clearOutcome = false,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
      showNsfw: showNsfw ?? this.showNsfw,
      collectStatistics: collectStatistics ?? this.collectStatistics,
      loading: loading ?? this.loading,
      progress: clearProgress ? null : (progress ?? this.progress),
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
    );
  }
}
