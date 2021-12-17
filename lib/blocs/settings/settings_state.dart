part of 'settings_cubit.dart';

@immutable
abstract class SettingsState extends Equatable
{}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {

  final KeepCachedImageDay keepCachedImageDay;

  SettingsLoaded({
    required this.keepCachedImageDay,
  });

  @override
  List<Object?> get props => [keepCachedImageDay];

  SettingsLoaded copyWith({
    KeepCachedImageDay? keepCachedImageDay,
  }) {
    return SettingsLoaded(
      keepCachedImageDay: keepCachedImageDay ?? this.keepCachedImageDay,
    );
  }
}
