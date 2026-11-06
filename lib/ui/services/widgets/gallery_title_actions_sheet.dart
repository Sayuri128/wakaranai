import 'dart:convert';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/gallery_title_downloader.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

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

  LibraryEntryDomain toLibraryEntry({int? categoryId}) {
    return LibraryEntryDomain(
      id: 0,
      uid: uid,
      extensionUid: extensionUid,
      title: title,
      cover: cover,
      data: jsonEncode(data),
      categoryId: categoryId,
      createdAt: DateTime.now(),
    );
  }
}

Future<void> showGalleryTitleActions(
  BuildContext context, {
  required GalleryTitle title,
  MangaApiClient? downloadClient,
}) {
  final LibraryCubit library = context.read<LibraryCubit>();
  final LibraryEntryDomain? saved = _savedEntry(library.state, title.uid);
  final List<CategoryDomain> categories = library.state.categories;

  return showActionSheet(
    context,
    title: title.title.trim(),
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (saved == null)
            ActionSheetRow(
              icon: Icons.favorite_border_rounded,
              label: S.current.library_add,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _addToLibrary(context, library, title, null);
              },
            ),
          if (categories.isNotEmpty)
            ActionSheetRow(
              icon: Icons.drive_file_move_outline,
              label: saved == null
                  ? S.current.library_add_to_category
                  : S.current.library_move_to_category,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showCategoryPicker(context, library, title, saved);
              },
            ),
          if (downloadClient != null)
            ActionSheetRow(
              icon: Icons.download_rounded,
              label: S.current.gallery_download,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showDownloadPicker(context, title, downloadClient);
              },
            ),
          if (saved != null)
            ActionSheetRow(
              icon: Icons.delete_outline_rounded,
              label: S.current.library_remove,
              destructive: true,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _removeFromLibrary(context, library, title);
              },
            ),
        ],
      ),
    ),
  );
}

LibraryEntryDomain? _savedEntry(LibraryState state, String uid) {
  return state.entries.firstWhereOrNull(
    (LibraryEntryDomain entry) => entry.uid == uid,
  );
}

void _showCategoryPicker(
  BuildContext context,
  LibraryCubit library,
  GalleryTitle title,
  LibraryEntryDomain? saved,
) {
  void choose(BuildContext sheetContext, int? categoryId) {
    Navigator.of(sheetContext).pop();
    if (saved == null) {
      _addToLibrary(context, library, title, categoryId);
    } else {
      library.moveToCategory(saved, categoryId);
    }
  }

  showActionSheet(
    context,
    title: saved == null
        ? S.current.library_add_to_category
        : S.current.library_move_to_category,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionSheetRow(
            label: S.current.library_no_category,
            selected: saved != null && saved.categoryId == null,
            onTap: () => choose(sheetContext, null),
          ),
          for (final CategoryDomain category in library.state.categories)
            ActionSheetRow(
              label: category.name,
              selected: saved?.categoryId == category.id,
              onTap: () => choose(sheetContext, category.id),
            ),
        ],
      ),
    ),
  );
}

Future<void> _addToLibrary(
  BuildContext context,
  LibraryCubit library,
  GalleryTitle title,
  int? categoryId,
) async {
  await library.addToLibrary(title.toLibraryEntry(categoryId: categoryId));
  if (context.mounted) {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.library_added_message,
    );
  }
}

Future<void> _removeFromLibrary(
  BuildContext context,
  LibraryCubit library,
  GalleryTitle title,
) async {
  await library.removeFromLibrary(title.uid);
  if (context.mounted) {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.library_removed_message,
    );
  }
}

void _showDownloadPicker(
  BuildContext context,
  GalleryTitle title,
  MangaApiClient client,
) {
  final GalleryTitleDownloader downloader = GalleryTitleDownloader(
    downloadManager: context.read<DownloadManagerCubit>(),
    concreteDataRepository: context.read<ConcreteDataRepository>(),
    chapterActivityRepository: context.read<ChapterActivityRepository>(),
    downloadRepository: context.read<DownloadRepository>(),
  );

  void choose(BuildContext sheetContext, ChapterDownloadAmount amount) {
    Navigator.of(sheetContext).pop();
    _downloadChapters(context, downloader, client, title, amount);
  }

  showActionSheet(
    context,
    title: S.current.gallery_download_title,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final ChapterDownloadAmount amount
              in ChapterDownloadAmount.values)
            ActionSheetRow(
              label: _amountLabel(amount),
              onTap: () => choose(sheetContext, amount),
            ),
        ],
      ),
    ),
  );
}

String _amountLabel(ChapterDownloadAmount amount) {
  switch (amount) {
    case ChapterDownloadAmount.next:
      return S.current.gallery_download_next;
    case ChapterDownloadAmount.nextFive:
      return S.current.gallery_download_next_count(5);
    case ChapterDownloadAmount.nextTen:
      return S.current.gallery_download_next_count(10);
    case ChapterDownloadAmount.unread:
      return S.current.gallery_download_unread;
    case ChapterDownloadAmount.all:
      return S.current.gallery_download_all;
  }
}

Future<void> _downloadChapters(
  BuildContext context,
  GalleryTitleDownloader downloader,
  MangaApiClient client,
  GalleryTitle title,
  ChapterDownloadAmount amount,
) async {
  SnackBars.showSnackBar(
    context: context,
    message: S.current.gallery_download_loading,
  );
  try {
    final int queued = await downloader.download(
      client: client,
      extensionUid: title.extensionUid,
      uid: title.uid,
      galleryData: title.data,
      amount: amount,
    );
    if (!context.mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: queued == 0
          ? S.current.gallery_download_nothing
          : S.current.gallery_download_queued(queued),
    );
  } catch (error, stack) {
    logger.w('Gallery download failed for ${title.uid}: $error');
    logger.w(stack);
    if (context.mounted) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.gallery_download_failed,
      );
    }
  }
}
