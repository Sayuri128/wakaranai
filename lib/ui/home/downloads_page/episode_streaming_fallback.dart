import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/storage/local_playback_fallback.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

bool streamInsteadOfFailedDownload(
  BuildContext context, {
  required PlayableVideo video,
  required String episodeUid,
}) {
  final bool claimed = claimStreamingFallback(
    video: video,
    episodeUid: episodeUid,
  );
  if (!claimed) {
    return false;
  }
  _offerRedownload(context, episodeUid);
  return true;
}

void _offerRedownload(BuildContext context, String episodeUid) {
  final DownloadRepository repository = context.read<DownloadRepository>();
  final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
  SnackBars.showActionSnackBar(
    context: context,
    message: S.of(context).downloads_storage_playback_fallback,
    icon: Icons.cloud_download_outlined,
    action: SnackBarActionData(
      label: S.of(context).downloads_storage_redownload,
      onPressed: () => unawaited(
        redownloadEpisode(
          episodeUid: episodeUid,
          findDownload: repository.getByUid,
          deleteDownload: manager.deleteDownload,
          downloadAgain: manager.retryDownload,
        ),
      ),
    ),
  );
}
