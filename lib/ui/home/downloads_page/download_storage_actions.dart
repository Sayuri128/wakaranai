import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/services/downloads/storage/download_sizes.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_downloads.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

class DownloadStorageActions {
  DownloadStorageActions({required this.manager, required this.finder});

  factory DownloadStorageActions.of(BuildContext context) {
    return DownloadStorageActions(
      manager: context.read<DownloadManagerCubit>(),
      finder: WatchedEpisodeFinder.fromRepository(
        context.read<AnimeEpisodeActivityRepository>(),
      ),
    );
  }

  final DownloadManagerCubit manager;
  final WatchedEpisodeFinder finder;

  Future<List<DownloadDomain>> watchedDownloadsOf(
    List<DownloadDomain> titleDownloads,
  ) {
    return finder.watchedDownloadsOf(titleDownloads);
  }

  Future<void> deleteDownloads(List<DownloadDomain> downloads) async {
    for (final DownloadDomain download in downloads) {
      await manager.deleteDownload(download);
    }
  }

  Future<void> deleteTitle(String concreteUid) {
    return manager.deleteForConcrete(concreteUid);
  }

  Future<bool> deleteWatchedWithConfirmation(
    BuildContext context, {
    required List<DownloadDomain> titleDownloads,
    required Map<String, int> itemBytes,
  }) async {
    final List<DownloadDomain> watched = await watchedDownloadsOf(
      titleDownloads,
    );
    if (!context.mounted) {
      return false;
    }
    if (watched.isEmpty) {
      SnackBars.showSnackBar(
        context: context,
        message: S.of(context).downloads_storage_no_watched,
      );
      return false;
    }
    final bool confirmed = await _confirmDestructive(
      context,
      title: S.of(context).downloads_storage_delete_watched_confirm_title,
      message: S
          .of(context)
          .downloads_storage_delete_watched_confirm_message(
            watched.length,
            titleDownloads.first.concreteTitle,
            formatDownloadSize(bytesOfDownloads(watched, itemBytes)),
          ),
    );
    if (!confirmed || !context.mounted) {
      return false;
    }
    await deleteDownloads(watched);
    if (context.mounted) {
      SnackBars.showSnackBar(
        context: context,
        message: S
            .of(context)
            .downloads_storage_deleted_watched(watched.length),
      );
    }
    return true;
  }

  Future<bool> deleteTitleWithConfirmation(
    BuildContext context, {
    required List<DownloadDomain> titleDownloads,
    required Map<String, int> itemBytes,
  }) async {
    final DownloadDomain sample = titleDownloads.first;
    final bool confirmed = await _confirmDestructive(
      context,
      title: S.of(context).downloads_storage_delete_title_confirm_title,
      message: S
          .of(context)
          .downloads_storage_delete_title_confirm_message(
            sample.concreteTitle,
            formatDownloadSize(bytesOfDownloads(titleDownloads, itemBytes)),
          ),
    );
    if (!confirmed) {
      return false;
    }
    await deleteTitle(sample.concreteUid);
    return true;
  }

  Future<bool> _confirmDestructive(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        title: title,
        message: message,
        yesText: S.of(dialogContext).downloads_confirm_delete,
        noText: S.of(dialogContext).downloads_confirm_cancel,
        destructive: true,
      ),
    );
    return confirmed == true;
  }
}

void showDownloadTitleActions(
  BuildContext context, {
  required List<DownloadDomain> titleDownloads,
  required Map<String, int> itemBytes,
}) {
  final DownloadStorageActions actions = DownloadStorageActions.of(context);
  final bool hasEpisodes = titleDownloads.any(
    (DownloadDomain download) => download.isEpisode,
  );
  unawaited(
    showActionSheet(
      context,
      title: titleDownloads.first.concreteTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasEpisodes)
            ActionSheetRow(
              icon: Icons.playlist_remove_rounded,
              label: S.of(context).downloads_storage_delete_watched_episodes,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(
                  actions.deleteWatchedWithConfirmation(
                    context,
                    titleDownloads: titleDownloads,
                    itemBytes: itemBytes,
                  ),
                );
              },
            ),
          ActionSheetRow(
            icon: Icons.delete_outline_rounded,
            label: S.of(context).downloads_storage_delete_title_downloads,
            destructive: true,
            onTap: () {
              Navigator.of(context).pop();
              unawaited(
                actions.deleteTitleWithConfirmation(
                  context,
                  titleDownloads: titleDownloads,
                  itemBytes: itemBytes,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
