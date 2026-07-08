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

  const SettingsInitialized({
    required this.defaultMode,
    required this.showNsfw,
    required this.collectStatistics,
    this.loading = false,
  });

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
    bool? showNsfw,
    bool? collectStatistics,
    bool? loading,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
      showNsfw: showNsfw ?? this.showNsfw,
      collectStatistics: collectStatistics ?? this.collectStatistics,
      loading: loading ?? this.loading,
    );
  }
}
