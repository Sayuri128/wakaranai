import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/chapter_translation_actions.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> translateDownloads(
  BuildContext context,
  List<DownloadDomain> downloads,
) async {
  final List<DownloadDomain> finished = downloads
      .where(
        (DownloadDomain download) => download.status == DownloadStatus.done,
      )
      .toList();
  if (finished.isEmpty) {
    return;
  }
  final DownloadDomain firstDownload = finished.first;
  final ChapterTranslationCubit queue = context.read<ChapterTranslationCubit>();
  final ExtensionDomain? extension = await context
      .read<ExtensionRepository>()
      .getByUid(firstDownload.extensionUid);
  if (!context.mounted) {
    return;
  }
  final TitleLanguages? languages = await resolveTitleLanguages(
    context,
    extensionUid: firstDownload.extensionUid,
    concreteUid: firstDownload.concreteUid,
    extensionLanguage: extension?.config.language,
  );
  if (languages == null) {
    return;
  }

  for (final DownloadDomain download in finished) {
    queue.enqueue(
      key: download.uid,
      title: download.title,
      pages: DownloadFiles.localPagePaths(download),
      languages: languages,
    );
  }
  if (context.mounted) {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.chapter_translation_queued(finished.length),
    );
  }
}

class DownloadTranslationButton extends StatelessWidget {
  const DownloadTranslationButton({super.key, required this.download});

  final DownloadDomain download;

  @override
  Widget build(BuildContext context) {
    final bool enabled = context.select(
      (PageTranslationSettingsCubit cubit) => cubit.state.enabled,
    );
    if (!enabled || download.status != DownloadStatus.done) {
      return const SizedBox.shrink();
    }
    final ChapterTranslationJob? job = context.select(
      (ChapterTranslationCubit cubit) => cubit.state.job(download.uid),
    );
    final bool translated = job?.status == ChapterTranslationStatus.done;
    if (job != null && job.active) {
      return IconButton(
        tooltip: S.current.chapter_translation_cancel,
        icon: Icon(Icons.close_rounded, color: AppColors.mainGrey),
        onPressed: () =>
            context.read<ChapterTranslationCubit>().cancel(download.uid),
      );
    }
    return IconButton(
      tooltip: S.current.chapter_translation_translate,
      icon: Icon(
        Icons.translate_rounded,
        color: translated ? AppColors.primary : AppColors.mainGrey,
      ),
      onPressed: () => translateDownloads(context, <DownloadDomain>[download]),
    );
  }
}

class DownloadTranslationStatus extends StatelessWidget {
  const DownloadTranslationStatus({super.key, required this.download});

  final DownloadDomain download;

  @override
  Widget build(BuildContext context) {
    final ChapterTranslationJob? job = context.select(
      (ChapterTranslationCubit cubit) => cubit.state.job(download.uid),
    );
    if (job == null) {
      return const SizedBox.shrink();
    }
    final Color color = switch (job.status) {
      ChapterTranslationStatus.failed => AppColors.red,
      ChapterTranslationStatus.done => AppColors.primary,
      _ => AppColors.mainGrey,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.translate_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                chapterTranslationLabel(job),
                style: regular(size: 12, color: color),
              ),
            ],
          ),
          if (job.active) ...<Widget>[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.status == ChapterTranslationStatus.running
                    ? job.progress
                    : null,
                minHeight: 4,
                backgroundColor: AppColors.overlay(0.08),
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TranslateAllButton extends StatelessWidget {
  const TranslateAllButton({super.key, required this.downloads});

  final List<DownloadDomain> downloads;

  @override
  Widget build(BuildContext context) {
    final bool enabled = context.select(
      (PageTranslationSettingsCubit cubit) => cubit.state.enabled,
    );
    final bool hasFinishedDownloads = downloads.any(
      (DownloadDomain download) => download.status == DownloadStatus.done,
    );
    if (!enabled || !hasFinishedDownloads) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: S.current.chapter_translation_translate_all,
      icon: Icon(Icons.translate_rounded, color: AppColors.mainGrey),
      onPressed: () => translateDownloads(context, downloads),
    );
  }
}
