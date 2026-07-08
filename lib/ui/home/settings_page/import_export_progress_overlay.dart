import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/import_export/export_section_labels.dart';
import 'package:wakaranai/services/import_export/import_export_service.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ImportExportProgressOverlay extends StatelessWidget {
  const ImportExportProgressOverlay({super.key, required this.progress});

  final ImportExportProgress? progress;

  @override
  Widget build(BuildContext context) {
    final ImportExportProgress? progress = this.progress;

    if (progress == null) {
      return ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String title = progress.exporting
        ? S.current.settings_export_progress_title
        : S.current.settings_import_progress_title;

    final String subtitle = progress.section != null
        ? exportSectionTitle(progress.section!)
        : S.current.settings_progress_preparing;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.dialogSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: semibold(size: 18)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: regular(size: 13, color: AppColors.mainGrey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.value,
                  minHeight: 6,
                  backgroundColor: AppColors.overlay(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              if (progress.total > 0) ...<Widget>[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${progress.processed}/${progress.total}',
                    style: regular(size: 12, color: AppColors.mainGrey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
