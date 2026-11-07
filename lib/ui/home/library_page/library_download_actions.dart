import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/episode_title_downloader.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';
import 'package:wakaranai/ui/services/widgets/title_download_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const Set<int> _firstGroup = <int>{0};

Future<ExtensionDomain> _resolveExtension(
  LibraryCubit library,
  String extensionUid,
) async {
  final ExtensionDomain? extension =
      await library.extensionResolver.resolve(extensionUid);
  if (extension == null) {
    throw StateError('Extension $extensionUid is unavailable');
  }
  return extension;
}

Future<MangaApiClient> Function() _clientLoader(
  BuildContext context,
  String extensionUid,
) {
  final LibraryCubit library = context.read<LibraryCubit>();
  final DownloadManagerCubit downloads = context.read<DownloadManagerCubit>();
  return () async {
    final ExtensionDomain extension =
        await _resolveExtension(library, extensionUid);
    return downloads.clientForExtension(extension);
  };
}

Future<ApiClient> Function() _pooledClientLoader(
  BuildContext context,
  PreparedClientPool pool,
  String extensionUid,
) {
  final LibraryCubit library = context.read<LibraryCubit>();
  return () async {
    final ExtensionDomain extension =
        await _resolveExtension(library, extensionUid);
    return pool.clientFor(extension);
  };
}

void showLibraryDownloadSheet(
  BuildContext context,
  LibraryEntryDomain entry, {
  ConfigInfoType type = ConfigInfoType.MANGA,
}) {
  switch (type) {
    case ConfigInfoType.MANGA:
      showTitleDownloadSheet(
        context,
        request: TitleDownloadRequest(
          uid: entry.uid,
          extensionUid: entry.extensionUid,
          galleryData: entry.dataJson,
          loadClient: _clientLoader(context, entry.extensionUid),
        ),
      );
      break;
    case ConfigInfoType.ANIME:
      final PreparedClientPool pool = PreparedClientPool();
      showTitleDownloadSheet(
        context,
        request: TitleDownloadRequest(
          uid: entry.uid,
          extensionUid: entry.extensionUid,
          galleryData: entry.dataJson,
          type: ConfigInfoType.ANIME,
          loadClient: _pooledClientLoader(context, pool, entry.extensionUid),
          releaseClient: pool.dispose,
        ),
      );
      break;
  }
}

void showLibraryBulkDownloadSheet(
  BuildContext context,
  List<LibraryEntryDomain> entries, {
  required Map<String, ConfigInfoType> extensionTypes,
  VoidCallback? onStarted,
}) {
  final TitleDownloadLabels labels = TitleDownloadLabels.forTypes(
    entries.map(
      (LibraryEntryDomain entry) =>
          extensionTypes[entry.extensionUid] ?? ConfigInfoType.MANGA,
    ),
  );
  showActionSheet(
    context,
    title: labels.sheetTitle,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              labels.firstGroupHint,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ),
          for (final ChapterDownloadAmount amount
              in ChapterDownloadAmount.values)
            ActionSheetRow(
              icon: Icons.download_rounded,
              label: labels.amount(amount),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onStarted?.call();
                _downloadMany(context, entries, extensionTypes, labels, amount);
              },
            ),
        ],
      ),
    ),
  );
}

class _BulkDownloader {
  _BulkDownloader(BuildContext context)
      : library = context.read<LibraryCubit>(),
        chapters = TitleDownloader(
          downloadManager: context.read<DownloadManagerCubit>(),
          concreteDataRepository: context.read<ConcreteDataRepository>(),
          chapterActivityRepository: context.read<ChapterActivityRepository>(),
          downloadRepository: context.read<DownloadRepository>(),
        ),
        episodes = EpisodeTitleDownloader(
          downloadManager: context.read<DownloadManagerCubit>(),
          concreteDataRepository: context.read<ConcreteDataRepository>(),
          episodeActivityRepository:
              context.read<AnimeEpisodeActivityRepository>(),
          downloadRepository: context.read<DownloadRepository>(),
        ),
        downloads = context.read<DownloadManagerCubit>();

  final LibraryCubit library;
  final TitleDownloader chapters;
  final EpisodeTitleDownloader episodes;
  final DownloadManagerCubit downloads;
  final PreparedClientPool animeClients = PreparedClientPool();

  Future<int> download(
    LibraryEntryDomain entry,
    ConfigInfoType type,
    ChapterDownloadAmount amount,
  ) async {
    final ExtensionDomain extension =
        await _resolveExtension(library, entry.extensionUid);
    switch (type) {
      case ConfigInfoType.MANGA:
        return _downloadChapters(entry, extension, amount);
      case ConfigInfoType.ANIME:
        return _downloadEpisodes(entry, extension, amount);
    }
  }

  Future<int> _downloadChapters(
    LibraryEntryDomain entry,
    ExtensionDomain extension,
    ChapterDownloadAmount amount,
  ) async {
    final DownloadableTitle title = await chapters.load(
      client: await downloads.clientForExtension(extension),
      extensionUid: entry.extensionUid,
      uid: entry.uid,
      galleryData: entry.dataJson,
    );
    return chapters.queue(title, groupIndexes: _firstGroup, amount: amount);
  }

  Future<int> _downloadEpisodes(
    LibraryEntryDomain entry,
    ExtensionDomain extension,
    ChapterDownloadAmount amount,
  ) async {
    final DownloadableAnimeTitle title = await episodes.load(
      client: expectClient<AnimeApiClient>(
        await animeClients.clientFor(extension),
      ),
      extensionUid: entry.extensionUid,
      uid: entry.uid,
      galleryData: entry.dataJson,
    );
    return episodes.queue(title, groupIndexes: _firstGroup, amount: amount);
  }

  Future<void> dispose() => animeClients.dispose();
}

Future<void> _downloadMany(
  BuildContext context,
  List<LibraryEntryDomain> entries,
  Map<String, ConfigInfoType> extensionTypes,
  TitleDownloadLabels labels,
  ChapterDownloadAmount amount,
) async {
  final _BulkDownloader downloader = _BulkDownloader(context);

  SnackBars.showSnackBar(
    context: context,
    message: labels.manyLoading(entries.length),
  );

  int queued = 0;
  int failed = 0;
  try {
    for (final LibraryEntryDomain entry in entries) {
      try {
        queued += await downloader.download(
          entry,
          extensionTypes[entry.extensionUid] ?? ConfigInfoType.MANGA,
          amount,
        );
      } catch (error, stack) {
        failed++;
        logger.w('Bulk download failed for ${entry.uid}: $error');
        logger.w(stack);
      }
    }
  } finally {
    await downloader.dispose();
  }

  if (!context.mounted) {
    return;
  }
  _reportBulkResult(context, labels, queued: queued, failed: failed);
}

void _reportBulkResult(
  BuildContext context,
  TitleDownloadLabels labels, {
  required int queued,
  required int failed,
}) {
  final String failedText = S.current.library_download_many_failed(failed);
  if (queued == 0 && failed > 0) {
    SnackBars.showErrorSnackBar(context: context, error: failedText);
    return;
  }
  final String queuedText =
      queued == 0 ? labels.nothing : labels.queued(queued);
  SnackBars.showSnackBar(
    context: context,
    message: failed > 0 ? '$queuedText · $failedText' : queuedText,
  );
}
