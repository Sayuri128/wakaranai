part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsInitialized extends SettingsState {
  final ChapterViewMode defaultMode;

  final bool showNsfw;

  final bool loading;

  const SettingsInitialized({
    required this.defaultMode,
    required this.showNsfw,
    this.loading = false,
  });

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
    bool? showNsfw,
    bool? loading,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
      showNsfw: showNsfw ?? this.showNsfw,
      loading: loading ?? this.loading,
    );
  }
}
