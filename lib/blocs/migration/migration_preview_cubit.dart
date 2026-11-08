import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';

enum MigrationPreviewStatus { loading, ready, applying, done, loadFailed }

class MigrationPreviewState {
  const MigrationPreviewState({
    this.status = MigrationPreviewStatus.loading,
    this.preparation,
    this.options = const MigrationOptions(),
    this.result,
    this.error,
    this.applyFailed = false,
  });

  final MigrationPreviewStatus status;
  final MigrationPreparation? preparation;
  final MigrationOptions options;
  final MigrationResult? result;
  final Object? error;
  final bool applyFailed;

  bool get canApply =>
      status == MigrationPreviewStatus.ready && preparation != null;

  MigrationPreviewState copyWith({
    MigrationPreviewStatus? status,
    MigrationPreparation? preparation,
    MigrationOptions? options,
    MigrationResult? result,
    Object? error,
    bool? applyFailed,
  }) {
    return MigrationPreviewState(
      status: status ?? this.status,
      preparation: preparation ?? this.preparation,
      options: options ?? this.options,
      result: result ?? this.result,
      error: error ?? this.error,
      applyFailed: applyFailed ?? this.applyFailed,
    );
  }
}

class MigrationPreviewCubit extends Cubit<MigrationPreviewState> {
  MigrationPreviewCubit({
    required this.planner,
    required this.subject,
    required this.candidate,
  }) : super(const MigrationPreviewState());

  final MigrationPlanner planner;
  final MigrationSubject subject;
  final MigrationCandidate candidate;

  Future<void> load() async {
    emit(const MigrationPreviewState());
    try {
      final MigrationPreparation preparation =
          await planner.prepare(subject, candidate);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: MigrationPreviewStatus.ready,
        preparation: preparation,
      ));
    } catch (error) {
      logger.w('Migration preview failed for ${subject.title}: $error');
      if (isClosed) {
        return;
      }
      emit(MigrationPreviewState(
        status: MigrationPreviewStatus.loadFailed,
        options: state.options,
        error: error,
      ));
    }
  }

  void setOptions(MigrationOptions options) {
    emit(state.copyWith(options: options));
  }

  Future<void> apply() async {
    final MigrationPreparation? preparation = state.preparation;
    if (!state.canApply || preparation == null) {
      return;
    }
    emit(state.copyWith(
      status: MigrationPreviewStatus.applying,
      applyFailed: false,
    ));
    try {
      final MigrationResult result =
          await planner.apply(preparation, state.options);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: MigrationPreviewStatus.done,
        result: result,
      ));
    } catch (error) {
      logger.e('Migration of ${subject.title} failed: $error');
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: MigrationPreviewStatus.ready,
        error: error,
        applyFailed: true,
      ));
    }
  }
}
