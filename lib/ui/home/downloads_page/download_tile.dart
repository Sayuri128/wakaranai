import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/downloads_page/download_reader_launcher.dart';
import 'package:wakaranai/ui/home/downloads_page/download_translation.dart';
import 'package:wakaranai/ui/home/downloads_page/downloaded_episode_launcher.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef DownloadOpener = Future<void> Function(
  BuildContext context,
  DownloadDomain download,
);

enum DownloadTapAction { none, readChapter, playEpisode, retry }

const int _bytesPerMegabyte = 1024 * 1024;
const int _megabytesPerGigabyte = 1024;

DownloadTapAction downloadTapActionFor(DownloadDomain download) {
  switch (download.status) {
    case DownloadStatus.done:
      if (download.isEpisode) {
        return DownloadTapAction.playEpisode;
      }
      return DownloadTapAction.readChapter;
    case DownloadStatus.failed:
      return DownloadTapAction.retry;
    case DownloadStatus.queued:
    case DownloadStatus.downloading:
      return DownloadTapAction.none;
  }
}

String formatDownloadSize(int bytes) {
  final double megabytes = bytes / _bytesPerMegabyte;
  if (megabytes >= _megabytesPerGigabyte) {
    final double gigabytes = megabytes / _megabytesPerGigabyte;
    return S.current.downloads_episode_size_gb(gigabytes.toStringAsFixed(2));
  }
  return S.current.downloads_episode_size_mb(megabytes.toStringAsFixed(1));
}

String downloadStatusLabel(DownloadDomain download, {int? sizeBytes}) {
  switch (download.status) {
    case DownloadStatus.done:
      if (download.isEpisode) {
        return _episodeDoneLabel(download, sizeBytes);
      }
      return _withSize(
        S.current
            .downloads_pages_progress(download.totalPages, download.totalPages),
        sizeBytes,
      );
    case DownloadStatus.downloading:
      if (download.isEpisode) {
        return _episodeProgressLabel(download);
      }
      return S.current.downloads_pages_progress(
          download.downloadedPages, download.totalPages);
    case DownloadStatus.queued:
      return S.current.downloads_status_queued;
    case DownloadStatus.failed:
      return _withSize(S.current.downloads_status_failed, sizeBytes);
  }
}

String _withSize(String label, int? sizeBytes) {
  if (sizeBytes == null || sizeBytes <= 0) {
    return label;
  }
  return S.current.downloads_storage_summary_with_size(
    label,
    formatDownloadSize(sizeBytes),
  );
}

String _episodeDoneLabel(DownloadDomain download, int? sizeBytes) {
  final int size = sizeBytes ?? _reportedEpisodeSize(download);
  if (size <= 0) {
    return S.current.downloads_episode_done;
  }
  return S.current.downloads_episode_done_size(formatDownloadSize(size));
}

int _reportedEpisodeSize(DownloadDomain download) {
  if (download.totalBytes > 0) {
    return download.totalBytes;
  }
  return download.downloadedBytes;
}

String _episodeProgressLabel(DownloadDomain download) {
  if (download.totalPages > 0) {
    return S.current.downloads_episode_segments_progress(
        download.downloadedPages, download.totalPages);
  }
  if (download.totalBytes > 0) {
    final int percent = (download.progress * 100).floor();
    return S.current.downloads_episode_bytes_progress(
      percent,
      formatDownloadSize(download.downloadedBytes),
      formatDownloadSize(download.totalBytes),
    );
  }
  if (download.downloadedBytes > 0) {
    return S.current.downloads_episode_bytes_downloaded(
        formatDownloadSize(download.downloadedBytes));
  }
  return S.current.downloads_episode_preparing;
}

Future<void> openDownloadedChapter(
  BuildContext context,
  DownloadDomain download,
) async {
  await Navigator.of(context).pushNamed(
    Routes.downloadReader,
    arguments: DownloadReaderData(download: download),
  );
}

class DownloadTile extends StatelessWidget {
  const DownloadTile({
    super.key,
    required this.download,
    this.sizeBytes,
    this.readChapter = openDownloadedChapter,
    this.playEpisode = playDownloadedEpisode,
  });

  final DownloadDomain download;
  final int? sizeBytes;
  final DownloadOpener readChapter;
  final DownloadOpener playEpisode;

  @override
  Widget build(BuildContext context) {
    final DownloadTapAction tapAction = downloadTapActionFor(download);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: tapAction == DownloadTapAction.none
              ? null
              : () => _onTap(context, tapAction),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Expanded(child: _buildDetails()),
                const SizedBox(width: 10),
                ..._buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(download.title.trim(), style: medium(size: 15)),
        const SizedBox(height: 6),
        _buildSubtitle(),
        if (!download.isEpisode) DownloadTranslationStatus(download: download),
        if (download.status == DownloadStatus.downloading) ...<Widget>[
          const SizedBox(height: 10),
          _buildProgressBar(),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: download.progress > 0 ? download.progress : null,
        minHeight: 4,
        backgroundColor: AppColors.overlay(0.08),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      if (download.status == DownloadStatus.failed)
        IconButton(
          tooltip: S.current.downloads_episode_retry,
          icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
          onPressed: () => _retry(context),
        ),
      if (!download.isEpisode) DownloadTranslationButton(download: download),
      IconButton(
        icon: Icon(Icons.delete_outline_rounded, color: AppColors.mainGrey),
        onPressed: () => _confirmDelete(context),
      ),
    ];
  }

  void _onTap(BuildContext context, DownloadTapAction action) {
    switch (action) {
      case DownloadTapAction.readChapter:
        unawaited(readChapter(context, download));
        break;
      case DownloadTapAction.playEpisode:
        unawaited(playEpisode(context, download));
        break;
      case DownloadTapAction.retry:
        _retry(context);
        break;
      case DownloadTapAction.none:
        break;
    }
  }

  void _retry(BuildContext context) {
    unawaited(context.read<DownloadManagerCubit>().retryDownload(download));
  }

  Widget _buildSubtitle() {
    return Text(
      downloadStatusLabel(download, sizeBytes: sizeBytes),
      style: regular(size: 12, color: _statusColor()),
    );
  }

  Color _statusColor() {
    switch (download.status) {
      case DownloadStatus.downloading:
        return AppColors.primary;
      case DownloadStatus.failed:
        return AppColors.red;
      case DownloadStatus.done:
      case DownloadStatus.queued:
        return AppColors.mainGrey;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final DownloadManagerCubit cubit = context.read<DownloadManagerCubit>();
    final bool confirmed = await confirmDownloadDeletion(context, download);
    if (confirmed) {
      await cubit.deleteDownload(download);
    }
  }
}
