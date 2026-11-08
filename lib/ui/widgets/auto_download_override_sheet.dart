import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/library_entry_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';

String autoDownloadOverrideLabel(AutoDownloadOverride value) {
  switch (value) {
    case AutoDownloadOverride.followSettings:
      return S.current.auto_download_override_default;
    case AutoDownloadOverride.always:
      return S.current.auto_download_override_always;
    case AutoDownloadOverride.never:
      return S.current.auto_download_override_never;
  }
}

AutoDownloadOverride? sharedAutoDownloadOverride(
  List<LibraryEntryDomain> entries,
) {
  if (entries.isEmpty) {
    return null;
  }
  final AutoDownloadOverride first = entries.first.autoDownload;
  final bool allSame = entries.every(
    (LibraryEntryDomain entry) => entry.autoDownload == first,
  );
  if (!allSame) {
    return null;
  }
  return first;
}

String autoDownloadOverrideRowLabel(List<LibraryEntryDomain> entries) {
  final AutoDownloadOverride? shared = sharedAutoDownloadOverride(entries);
  final String mode = shared == null
      ? S.current.auto_download_override_mixed
      : autoDownloadOverrideLabel(shared);
  return S.current.auto_download_override_row(mode);
}

Future<void> showAutoDownloadOverrideSheet(
  BuildContext context,
  List<LibraryEntryDomain> entries, {
  VoidCallback? onChanged,
}) {
  final LibraryCubit library = context.read<LibraryCubit>();
  final AutoDownloadOverride? shared = sharedAutoDownloadOverride(entries);
  return showActionSheet(
    context,
    title: S.current.auto_download_override_title,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final AutoDownloadOverride value in AutoDownloadOverride.values)
            ActionSheetRow(
              icon: _iconOf(value),
              label: autoDownloadOverrideLabel(value),
              selected: value == shared,
              onTap: () {
                Navigator.of(sheetContext).pop();
                library.setAutoDownloadMany(entries, value);
                onChanged?.call();
              },
            ),
        ],
      ),
    ),
  );
}

IconData _iconOf(AutoDownloadOverride value) {
  switch (value) {
    case AutoDownloadOverride.followSettings:
      return Icons.tune_rounded;
    case AutoDownloadOverride.always:
      return Icons.download_rounded;
    case AutoDownloadOverride.never:
      return Icons.file_download_off_outlined;
  }
}
