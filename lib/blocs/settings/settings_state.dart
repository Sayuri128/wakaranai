part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsInitialized extends SettingsState {
  final ChapterViewMode defaultMode;
  final int? defaultConfigsSourceId;

  const SettingsInitialized(
      {required this.defaultMode, this.defaultConfigsSourceId});

  SettingsInitialized copyWith({
    ChapterViewMode? defaultMode,
    int? defaultConfigsSourceId,
  }) {
    return SettingsInitialized(
      defaultMode: defaultMode ?? this.defaultMode,
      defaultConfigsSourceId:
          defaultConfigsSourceId ?? this.defaultConfigsSourceId,
    );
  }
}
