import 'dart:async';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/ui/home/library_page/library_category_sheets.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';
import 'package:wakaranai/ui/home/library_page/library_download_actions.dart';
import 'package:wakaranai/ui/migration/migration_bulk_sheet.dart';
import 'package:wakaranai/ui/migration/migration_launcher.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/auto_download_override_sheet.dart';

Future<void> showLibraryEntryActions(
  BuildContext context,
  LibraryState state,
  List<LibraryEntryDomain> entries, {
  VoidCallback? clearSelection,
  VoidCallback? onContinue,
}) async {
  if (entries.isEmpty) {
    return;
  }
  final Map<String, ConfigInfoType> extensionTypes = await _extensionTypes(
    context,
    entries,
  );
  if (!context.mounted) {
    return;
  }
  final List<LibraryEntryDomain> downloadable = entries
      .where(
        (LibraryEntryDomain e) =>
            extensionTypes.containsKey(e.extensionUid) &&
            LocalSources.supportsDownloads(e.extensionUid),
      )
      .toList();
  final bool allTracked = entries.every(
    (LibraryEntryDomain e) => e.trackUpdates,
  );
  final bool allNotify = entries.every(
    (LibraryEntryDomain e) => e.notifyUpdates,
  );
  final LibraryCubit library = context.read<LibraryCubit>();
  final bool autoDownloadEnabled =
      context.read<AutoDownloadSettingsCubit>().state.enabled;

  void finish(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    clearSelection?.call();
  }

  await showActionSheet(
    context,
    title: entries.length == 1
        ? entries.single.title
        : S.current.library_selected_count(entries.length),
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (onContinue != null && entries.length == 1)
            ActionSheetRow(
              icon: Icons.play_arrow_rounded,
              label: S.current.library_continue,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onContinue();
              },
            ),
          ActionSheetRow(
            icon: Icons.drive_file_move_outline,
            label: S.current.library_move_to_category,
            onTap: () {
              Navigator.of(sheetContext).pop();
              showLibraryMoveToCategorySheet(
                context,
                state,
                entries,
                onMoved: clearSelection,
              );
            },
          ),
          ActionSheetRow(
            icon: Icons.swap_horiz_rounded,
            label: S.current.migration_action_move,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(_migrate(
                context,
                entries,
                clearSelection: clearSelection,
              ));
            },
          ),
          if (downloadable.isNotEmpty)
            ActionSheetRow(
              icon: Icons.download_rounded,
              label: S.current.title_download,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _download(
                  context,
                  downloadable,
                  extensionTypes,
                  clearSelection: clearSelection,
                );
              },
            ),
          if (autoDownloadEnabled)
            ActionSheetRow(
              icon: Icons.downloading_rounded,
              label: autoDownloadOverrideRowLabel(entries),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showAutoDownloadOverrideSheet(
                  context,
                  entries,
                  onChanged: clearSelection,
                );
              },
            ),
          ActionSheetRow(
            icon: Icons.autorenew_rounded,
            label: S.current.library_track_updates,
            selected: allTracked,
            onTap: () {
              library.setTrackUpdatesMany(entries, !allTracked);
              finish(sheetContext);
            },
          ),
          ActionSheetRow(
            icon: allNotify
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
            label: allNotify
                ? S.current.library_mute_notifications
                : S.current.library_unmute_notifications,
            onTap: () {
              library.setNotifyUpdatesMany(entries, !allNotify);
              finish(sheetContext);
            },
          ),
          ActionSheetRow(
            icon: Icons.delete_outline_rounded,
            label: S.current.library_remove,
            destructive: true,
            onTap: () {
              library.removeMany(
                entries.map((LibraryEntryDomain e) => e.uid).toList(),
              );
              finish(sheetContext);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _migrate(
  BuildContext context,
  List<LibraryEntryDomain> entries, {
  VoidCallback? clearSelection,
}) async {
  final List<MigrationSubject> subjects = await migrationSubjectsForEntries(
    context.read<ExtensionRepository>(),
    entries,
  );
  if (!context.mounted) {
    return;
  }
  clearSelection?.call();
  if (subjects.length == 1) {
    await startMigration(context, subjects.single);
    return;
  }
  await showMigrationBulkSheet(context, subjects);
}

Future<Map<String, ConfigInfoType>> _extensionTypes(
  BuildContext context,
  List<LibraryEntryDomain> entries,
) async {
  final ExtensionRepository extensions = context.read<ExtensionRepository>();
  final Map<String, ConfigInfoType> types = <String, ConfigInfoType>{};
  final Set<String> extensionUids = entries
      .map((LibraryEntryDomain e) => e.extensionUid)
      .toSet();
  for (final String uid in extensionUids) {
    final ExtensionDomain? extension = await extensions.getByUid(uid);
    if (extension != null) {
      types[uid] = extension.config.type;
    }
  }
  return types;
}

void _download(
  BuildContext context,
  List<LibraryEntryDomain> entries,
  Map<String, ConfigInfoType> extensionTypes, {
  VoidCallback? clearSelection,
}) {
  if (entries.length == 1) {
    final LibraryEntryDomain entry = entries.single;
    showLibraryDownloadSheet(
      context,
      entry,
      type: extensionTypes[entry.extensionUid] ?? ConfigInfoType.MANGA,
    );
    clearSelection?.call();
    return;
  }
  showLibraryBulkDownloadSheet(
    context,
    entries,
    extensionTypes: extensionTypes,
    onStarted: clearSelection,
  );
}
