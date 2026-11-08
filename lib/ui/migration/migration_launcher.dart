import 'dart:async';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/global_search/global_search_preferences.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_store.dart';
import 'package:wakaranai/ui/global_search/global_search_page.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/migration/migration_arguments.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

const GlobalSearchPreferences migrationSearchPreferences =
    GlobalSearchPreferences(
  scopeStorageKey: GlobalSearchPreferences.migrationScopeKey,
  keepsHistory: false,
);

GlobalSearchCubit createMigrationSearchCubit(
  BuildContext context, {
  ConfigInfoType? type,
}) {
  return createGlobalSearchCubit(
    context,
    preferences: migrationSearchPreferences,
    type: type,
  );
}

MigrationPlanner createMigrationPlanner(BuildContext context) {
  return MigrationPlanner(
    store: MigrationStore(database: context.read<WakaranaiDatabase>()),
  );
}

Future<List<MigrationSubject>> migrationSubjectsForEntries(
  ExtensionRepository extensions,
  List<LibraryEntryDomain> entries,
) async {
  final List<MigrationSubject> subjects = <MigrationSubject>[];
  for (final LibraryEntryDomain entry in entries) {
    subjects.add(await migrationSubjectForEntry(extensions, entry));
  }
  return subjects;
}

Future<MigrationSubject> migrationSubjectForEntry(
  ExtensionRepository extensions,
  LibraryEntryDomain entry,
) async {
  final ExtensionDomain? extension =
      await extensions.getByUid(entry.extensionUid);
  return MigrationSubject.fromLibraryEntry(
    entry,
    type: extension?.config.type,
    sourceName: extension?.config.name.trim(),
  );
}

Future<void> startMigration(
  BuildContext context,
  MigrationSubject subject, {
  bool replaceCurrentRoute = false,
}) async {
  final Object? result = await Navigator.of(context).pushNamed(
    Routes.migration,
    arguments: MigrationSearchArguments(subject: subject),
  );
  if (result is! MigrationResult || !context.mounted) {
    return;
  }
  if (replaceCurrentRoute) {
    unawaited(Navigator.of(context).pushReplacementNamed(
      Routes.libraryConcreteViewer,
      arguments: LibraryConcreteViewerData(entry: result.entry),
    ));
    return;
  }
  final NavigatorState navigator = Navigator.of(context);
  SnackBars.showActionSnackBar(
    context: context,
    message: S.current.migration_done(result.sourceName),
    icon: Icons.swap_horiz_rounded,
    action: SnackBarActionData(
      label: S.current.migration_open,
      onPressed: () => unawaited(navigator.pushNamed(
        Routes.libraryConcreteViewer,
        arguments: LibraryConcreteViewerData(entry: result.entry),
      )),
    ),
  );
}
