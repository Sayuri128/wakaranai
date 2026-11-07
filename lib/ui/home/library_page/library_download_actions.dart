import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';
import 'package:wakaranai/ui/services/widgets/title_download_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const Set<int> _firstGroup = <int>{0};

Future<MangaApiClient> Function() _clientLoader(
  BuildContext context,
  String extensionUid,
) {
  final LibraryCubit library = context.read<LibraryCubit>();
  final DownloadManagerCubit downloads = context.read<DownloadManagerCubit>();
  return () async {
    final ExtensionDomain? extension =
        await library.extensionResolver.resolve(extensionUid);
    if (extension == null) {
      throw StateError('Extension $extensionUid is unavailable');
    }
    return downloads.clientForExtension(extension);
  };
}

void showLibraryDownloadSheet(BuildContext context, LibraryEntryDomain entry) {
  showTitleDownloadSheet(
    context,
    request: TitleDownloadRequest(
      uid: entry.uid,
      extensionUid: entry.extensionUid,
      galleryData: entry.dataJson,
      loadClient: _clientLoader(context, entry.extensionUid),
    ),
  );
}

void showLibraryBulkDownloadSheet(
  BuildContext context,
  List<LibraryEntryDomain> entries, {
  VoidCallback? onStarted,
}) {
  showActionSheet(
    context,
    title: S.current.title_download_title,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              S.current.library_download_first_group_hint,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ),
          for (final ChapterDownloadAmount amount
              in ChapterDownloadAmount.values)
            ActionSheetRow(
              icon: Icons.download_rounded,
              label: chapterDownloadAmountLabel(amount),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onStarted?.call();
                _downloadMany(context, entries, amount);
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _downloadMany(
  BuildContext context,
  List<LibraryEntryDomain> entries,
  ChapterDownloadAmount amount,
) async {
  final TitleDownloader downloader = TitleDownloader(
    downloadManager: context.read<DownloadManagerCubit>(),
    concreteDataRepository: context.read<ConcreteDataRepository>(),
    chapterActivityRepository: context.read<ChapterActivityRepository>(),
    downloadRepository: context.read<DownloadRepository>(),
  );
  final Map<String, Future<MangaApiClient> Function()> loaders =
      <String, Future<MangaApiClient> Function()>{
    for (final LibraryEntryDomain entry in entries)
      entry.extensionUid: _clientLoader(context, entry.extensionUid),
  };

  SnackBars.showSnackBar(
    context: context,
    message: S.current.library_download_many_loading(entries.length),
  );

  int queued = 0;
  int failed = 0;
  for (final LibraryEntryDomain entry in entries) {
    try {
      final DownloadableTitle title = await downloader.load(
        client: await loaders[entry.extensionUid]!(),
        extensionUid: entry.extensionUid,
        uid: entry.uid,
        galleryData: entry.dataJson,
      );
      queued += await downloader.queue(
        title,
        groupIndexes: _firstGroup,
        amount: amount,
      );
    } catch (error, stack) {
      failed++;
      logger.w('Bulk download failed for ${entry.uid}: $error');
      logger.w(stack);
    }
  }

  if (!context.mounted) {
    return;
  }
  _reportBulkResult(context, queued: queued, failed: failed);
}

void _reportBulkResult(
  BuildContext context, {
  required int queued,
  required int failed,
}) {
  final String failedText = S.current.library_download_many_failed(failed);
  if (queued == 0 && failed > 0) {
    SnackBars.showErrorSnackBar(context: context, error: failedText);
    return;
  }
  final String queuedText = queued == 0
      ? S.current.title_download_nothing
      : S.current.title_download_queued(queued);
  SnackBars.showSnackBar(
    context: context,
    message: failed > 0 ? '$queuedText · $failedText' : queuedText,
  );
}
