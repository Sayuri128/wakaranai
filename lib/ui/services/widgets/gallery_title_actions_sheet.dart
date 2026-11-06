import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryTitle {
  const GalleryTitle({
    required this.uid,
    required this.extensionUid,
    required this.title,
    required this.cover,
    required this.data,
  });

  final String uid;
  final String extensionUid;
  final String title;
  final String cover;
  final Map<String, dynamic> data;

  LibraryEntryDomain toLibraryEntry() {
    return LibraryEntryDomain(
      id: 0,
      uid: uid,
      extensionUid: extensionUid,
      title: title,
      cover: cover,
      data: jsonEncode(data),
      createdAt: DateTime.now(),
    );
  }
}

Future<void> showGalleryTitleActions(
  BuildContext context, {
  required GalleryTitle title,
}) {
  final LibraryCubit library = context.read<LibraryCubit>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _GalleryTitleActionsSheet(
      title: title,
      inLibrary: library.isFavorite(title.uid),
      onToggleLibrary: () => _toggleLibrary(context, library, title),
    ),
  );
}

Future<void> _toggleLibrary(
  BuildContext context,
  LibraryCubit library,
  GalleryTitle title,
) async {
  final bool wasInLibrary = library.isFavorite(title.uid);
  await library.toggleFavorite(title.toLibraryEntry());
  if (!context.mounted) {
    return;
  }
  SnackBars.showSnackBar(
    context: context,
    message: wasInLibrary
        ? S.current.library_removed_message
        : S.current.library_added_message,
  );
}

class _GalleryTitleActionsSheet extends StatelessWidget {
  const _GalleryTitleActionsSheet({
    required this.title,
    required this.inLibrary,
    required this.onToggleLibrary,
  });

  final GalleryTitle title;
  final bool inLibrary;
  final VoidCallback onToggleLibrary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.overlay(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              title.title.trim(),
              style: semibold(size: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          _buildLibraryRow(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLibraryRow(BuildContext context) {
    final Color color = inLibrary ? AppColors.red : AppColors.primary;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onToggleLibrary();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(
              inLibrary
                  ? Icons.heart_broken_rounded
                  : Icons.favorite_border_rounded,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              inLibrary ? S.current.library_remove : S.current.library_add,
              style: medium(size: 15, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
