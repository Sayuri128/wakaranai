import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';

class MigrationSearchArguments {
  const MigrationSearchArguments({
    required this.subject,
    this.pickOnly = false,
    this.searchCubit,
  });

  final MigrationSubject subject;
  final bool pickOnly;
  final GlobalSearchCubit? searchCubit;
}

class MigrationPreviewArguments {
  const MigrationPreviewArguments({
    required this.subject,
    required this.candidate,
  });

  final MigrationSubject subject;
  final MigrationCandidate candidate;
}
