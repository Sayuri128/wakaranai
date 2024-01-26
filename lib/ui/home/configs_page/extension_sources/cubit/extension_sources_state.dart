part of 'extension_sources_cubit.dart';

@immutable
abstract class ExtensionSourcesState {
  const ExtensionSourcesState();
}

class ExtensionSourcesInitial extends ExtensionSourcesState {}

class ExtensionSourcesLoading extends ExtensionSourcesState {}

class ExtensionSourcesLoaded extends ExtensionSourcesState {
  final List<ExtensionSourceDomain> repositories;

  const ExtensionSourcesLoaded({
    required this.repositories,
  });
}

class ExtensionSourcesError extends ExtensionSourcesState {
  final String message;

  const ExtensionSourcesError({
    required this.message,
  });
}
