import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/local_source/local_library.dart';
import 'package:wakaranai/services/local_source/local_source.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

Future<void> showLocalSourceActions(BuildContext context) async {
  await showActionSheet(
    context,
    title: S.current.local_source_name,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionSheetRow(
            label: S.current.local_source_import,
            icon: Icons.file_download_outlined,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(importLocalArchives(context));
            },
          ),
          ActionSheetRow(
            label: S.current.local_source_where,
            icon: Icons.folder_open_rounded,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(_showLocation(context));
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> importLocalArchives(BuildContext context) async {
  final FilePickerResult? picked = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: <String>['cbz', 'zip'],
  );
  final List<String> paths = picked?.paths.whereType<String>().toList() ??
      const <String>[];
  if (paths.isEmpty || !context.mounted) {
    return;
  }
  final LocalLibrary library = await LocalSource.library();
  final String? title = paths.length > 1 ? importTitleFor(paths) : null;
  int imported = 0;
  for (final String path in paths) {
    try {
      await library.importArchive(File(path), titleName: title);
      imported++;
    } catch (error) {
      logger.w('Failed to import $path: $error');
    }
  }
  if (!context.mounted) {
    return;
  }
  SnackBars.showSnackBar(
    context: context,
    message: S.current.local_source_imported(imported),
  );
}

String importTitleFor(List<String> paths) {
  final List<String> names = paths
      .map((String path) => p.basenameWithoutExtension(path))
      .toList(growable: false);
  String prefix = names.first;
  for (final String name in names.skip(1)) {
    int length = 0;
    while (length < prefix.length &&
        length < name.length &&
        prefix[length] == name[length]) {
      length++;
    }
    prefix = prefix.substring(0, length);
  }
  final String trimmed = prefix
      .replaceAll(RegExp(r'[\s_\-.#]*(?:ch|chapter|vol|v|глава|том)?[\s_\-.#\d]*$',
          caseSensitive: false), '')
      .trim();
  if (trimmed.isEmpty) {
    return S.current.local_source_imported_title;
  }
  return trimmed;
}

Future<void> _showLocation(BuildContext context) async {
  final Directory root = await LocalSource.rootDirectory();
  await root.create(recursive: true);
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => InfoDialog(
      title: S.current.local_source_where,
      message: S.current.local_source_where_message(root.path),
      okText: S.current.common_ok_button,
      icon: Icons.folder_open_rounded,
    ),
  );
}
