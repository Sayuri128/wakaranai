import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/library_page/library_category_sheets.dart';
import 'package:wakaranai/ui/home/library_page/library_download_actions.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';

Future<void> showLibraryEntryActions(
  BuildContext context,
  LibraryState state,
  List<LibraryEntryDomain> entries, {
  VoidCallback? clearSelection,
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
        (LibraryEntryDomain e) => extensionTypes.containsKey(e.extensionUid),
      )
      .toList();
  final bool allTracked = entries.every(
    (LibraryEntryDomain e) => e.trackUpdates,
  );
  final bool allNotify = entries.every(
    (LibraryEntryDomain e) => e.notifyUpdates,
  );
  final LibraryCubit library = context.read<LibraryCubit>();

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
