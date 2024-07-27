part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsInitialized extends SettingsState {
  final ChapterViewMode defaultMode;

  final bool loading;

  const SettingsInitialized({
    required this.defaultMode,
    this.loading = false,
  });

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
    bool? loading,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
      loading: loading ?? this.loading,
    );
  }
}
