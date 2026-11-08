import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/local_source/local_book_library.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

Future<void> showLocalBooksActions(
  BuildContext context, {
  required bool pinned,
  required Future<void> Function() onTogglePin,
}) async {
  await showActionSheet(
    context,
    title: S.current.local_books_name,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionSheetRow(
            label: pinned ? S.current.configs_unpin : S.current.configs_pin,
            icon: pinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(onTogglePin());
            },
          ),
          ActionSheetRow(
            label: S.current.local_books_import,
            icon: Icons.file_download_outlined,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(importLocalBooks(context));
            },
          ),
          ActionSheetRow(
            label: S.current.local_books_where,
            icon: Icons.folder_open_rounded,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(_showBooksLocation(context));
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> importLocalBooks(BuildContext context) async {
  final FilePickerResult? picked = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: <String>['epub'],
  );
  final List<String> paths = picked?.paths.whereType<String>().toList() ??
      const <String>[];
  if (paths.isEmpty || !context.mounted) {
    return;
  }
  final LocalBookLibrary library = await LocalBooksSource.library();
  int imported = 0;
  for (final String path in paths) {
    try {
      await library.importBook(File(path));
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
    message: S.current.local_books_imported(imported),
  );
}

Future<void> _showBooksLocation(BuildContext context) async {
  final Directory root = await LocalBooksSource.rootDirectory();
  await root.create(recursive: true);
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => InfoDialog(
      title: S.current.local_books_where,
      message: S.current.local_books_where_message(root.path),
      okText: S.current.common_ok_button,
      icon: Icons.folder_open_rounded,
    ),
  );
}
