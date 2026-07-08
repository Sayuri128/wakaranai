import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ChapterDownloadButton extends StatelessWidget {
  const ChapterDownloadButton({
    super.key,
    required this.download,
    required this.onDownload,
    required this.onDelete,
    required this.onRetry,
  });

  final DownloadDomain? download;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final DownloadStatus? status = download?.status;

    switch (status) {
      case DownloadStatus.done:
        return _iconButton(
          icon: Icons.download_done_rounded,
          color: AppColors.primary,
          onTap: onDelete,
        );
      case DownloadStatus.downloading:
        return _wrap(
          onTap: onDelete,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primary,
              value: download!.progress > 0 ? download!.progress : null,
            ),
          ),
        );
      case DownloadStatus.queued:
        return _iconButton(
          icon: Icons.schedule_rounded,
          color: AppColors.mainGrey,
          onTap: onDelete,
        );
      case DownloadStatus.failed:
        return _iconButton(
          icon: Icons.error_outline_rounded,
          color: AppColors.red,
          onTap: onRetry,
        );
      case null:
        return _iconButton(
          icon: Icons.download_outlined,
          color: AppColors.mainGrey,
          onTap: onDownload,
        );
    }
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _wrap(
      onTap: onTap,
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _wrap({required Widget child, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(width: 22, height: 22, child: Center(child: child)),
      ),
    );
  }
}
