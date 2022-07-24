part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsInitialized extends SettingsState {

  final ChapterViewMode defaultMode;

  const SettingsInitialized({
    required this.defaultMode,
  });

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
    );
  }
}
