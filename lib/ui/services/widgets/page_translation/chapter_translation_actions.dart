import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/title_translation_languages_repository.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_languages_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ChapterToTranslate {
  const ChapterToTranslate({required this.uid, required this.title, this.data});

  final String uid;
  final String title;
  final Map<String, dynamic>? data;
}

Future<TitleLanguages?> resolveTitleLanguages(
  BuildContext context, {
  required String extensionUid,
  required String concreteUid,
  required String? extensionLanguage,
}) async {
  final TitleTranslationLanguagesRepository repository =
      TitleTranslationLanguagesRepository();
  final TitleLanguages? saved = await repository.get(extensionUid, concreteUid);
  if (saved != null || !context.mounted) {
    return saved;
  }
  final TitleLanguages? chosen = await showTranslationLanguagesSheet(
    context,
    initial: TitleLanguages(
      source:
          PageLanguage.sourceForExtension(extensionLanguage) ??
          PageLanguage.japanese,
      target: context.read<PageTranslationSettingsCubit>().state.target,
    ),
    confirmLabel: S.current.page_translation_languages_start,
  );
  if (chosen != null) {
    await repository.set(extensionUid, concreteUid, chosen);
  }
  return chosen;
}

Future<void> translateChapters(
  BuildContext context, {
  required MangaApiClient client,
  required String extensionUid,
  required String? extensionLanguage,
  required String concreteUid,
  required int concreteId,
  required String concreteTitle,
  required String? concreteCover,
  required List<ChapterToTranslate> chapters,
}) async {
  if (chapters.isEmpty) {
    return;
  }
  final DownloadManagerCubit downloads = context.read<DownloadManagerCubit>();
  final ChapterTranslationCubit translations = context
      .read<ChapterTranslationCubit>();
  final TitleLanguages? languages = await resolveTitleLanguages(
    context,
    extensionUid: extensionUid,
    concreteUid: concreteUid,
    extensionLanguage: extensionLanguage,
  );
  if (languages == null) {
    return;
  }

  bool needsDownload = false;
  for (final ChapterToTranslate chapter in chapters) {
    final DownloadDomain? download = downloads.state.forChapter(chapter.uid);
    final bool downloaded =
        download != null && download.status == DownloadStatus.done;
    if (downloaded) {
      translations.enqueue(
        key: chapter.uid,
        title: chapter.title,
        pages: DownloadManagerCubit.localPagePaths(download),
        languages: languages,
      );
      continue;
    }
    needsDownload = true;
    translations.translateAfterDownload(
      key: chapter.uid,
      title: chapter.title,
      languages: languages,
    );
    await downloads.enqueueChapter(
      client: client,
      extensionUid: extensionUid,
      concreteUid: concreteUid,
      concreteId: concreteId,
      concreteTitle: concreteTitle,
      concreteCover: concreteCover,
      chapterUid: chapter.uid,
      title: chapter.title,
      data: chapter.data,
      autoStart: false,
    );
  }
  if (needsDownload) {
    downloads.startQueue();
  }

  if (context.mounted) {
    SnackBars.showSnackBar(
      context: context,
      message: S.current.chapter_translation_queued(chapters.length),
    );
  }
}

class ChapterTranslationBadge extends StatelessWidget {
  const ChapterTranslationBadge({
    super.key,
    required this.chapterUid,
    required this.chapterTitle,
  });

  final String chapterUid;
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
    final ChapterTranslationJob? job = context.select(
      (ChapterTranslationCubit cubit) => cubit.state.job(chapterUid),
    );
    if (job == null) {
      return const SizedBox.shrink();
    }
    final Color iconColor = switch (job.status) {
      ChapterTranslationStatus.done => AppColors.primary,
      ChapterTranslationStatus.failed => AppColors.red,
      _ => AppColors.mainGrey,
    };
    final bool running = job.status == ChapterTranslationStatus.running;
    return InkResponse(
      radius: 20,
      onTap: () => showChapterTranslationSheet(
        context,
        chapterUid: chapterUid,
        chapterTitle: chapterTitle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (job.active)
                CircularProgressIndicator(
                  strokeWidth: 2,
                  value: running ? job.progress : null,
                  color: AppColors.primary,
                  backgroundColor: AppColors.overlay(0.08),
                ),
              Icon(Icons.translate_rounded, size: 14, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

class TranslationQueueCard extends StatelessWidget {
  const TranslationQueueCard({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterTranslationCubit, ChapterTranslationState>(
      builder: (BuildContext context, ChapterTranslationState state) {
        if (!state.busy) {
          return const SizedBox.shrink();
        }
        return _QueueCardContent(state: state, margin: margin);
      },
    );
  }
}

class _QueueCardContent extends StatelessWidget {
  const _QueueCardContent({required this.state, required this.margin});

  final ChapterTranslationState state;
  final EdgeInsetsGeometry? margin;

  String _statusText() {
    final ChapterTranslationJob? current = state.current;
    final String status;
    if (state.paused) {
      status = S.current.chapter_translation_notification_paused;
    } else if (current == null) {
      status = S.current.chapter_translation_waiting_download;
    } else if (current.status == ChapterTranslationStatus.preparing) {
      status = S.current.chapter_translation_preparing;
    } else {
      status = S.current.chapter_translation_progress(
        current.done,
        current.total,
      );
    }

    final int remaining = state.activeJobs.length;
    if (remaining <= 1) {
      return status;
    }
    final String remainingText = S.current
        .chapter_translation_notification_remaining(remaining);
    return '$status · $remainingText';
  }

  @override
  Widget build(BuildContext context) {
    final ChapterTranslationCubit cubit = context
        .read<ChapterTranslationCubit>();
    final ChapterTranslationJob? current = state.current;
    final bool showProgress = current != null && current.total > 0;
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.translate_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      current?.title ??
                          S.current.chapter_translation_queue_title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: semibold(size: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusText(),
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                  ],
                ),
              ),
              _buildPauseButton(cubit),
              IconButton(
                tooltip: S.current.chapter_translation_cancel_all,
                icon: Icon(Icons.close_rounded, color: AppColors.mainWhite),
                onPressed: cubit.cancelAll,
              ),
            ],
          ),
          if (showProgress) ...<Widget>[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: current.progress,
                  minHeight: 4,
                  color: AppColors.primary,
                  backgroundColor: AppColors.overlay(0.08),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPauseButton(ChapterTranslationCubit cubit) {
    if (state.paused) {
      return IconButton(
        tooltip: S.current.chapter_translation_resume,
        icon: Icon(Icons.play_arrow_rounded, color: AppColors.mainWhite),
        onPressed: cubit.togglePause,
      );
    }
    return IconButton(
      tooltip: S.current.chapter_translation_pause,
      icon: Icon(Icons.pause_rounded, color: AppColors.mainWhite),
      onPressed: cubit.togglePause,
    );
  }
}

Future<void> showChapterTranslationSheet(
  BuildContext context, {
  required String chapterUid,
  required String chapterTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return BlocBuilder<ChapterTranslationCubit, ChapterTranslationState>(
        builder: (BuildContext context, ChapterTranslationState state) {
          final ChapterTranslationJob? job = state.job(chapterUid);
          final String statusText = job == null
              ? S.current.chapter_translation_done
              : chapterTranslationLabel(job);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.overlay(0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(chapterTitle, style: semibold(size: 18)),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: regular(size: 14, color: AppColors.mainGrey),
                  ),
                  const SizedBox(height: 16),
                  TranslationQueueCard(),
                  if (job != null && job.active) ...<Widget>[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.overlay(0.06),
                        foregroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<ChapterTranslationCubit>().cancel(
                          chapterUid,
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: Text(
                        S.current.chapter_translation_cancel,
                        style: semibold(size: 15, color: AppColors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String chapterTranslationLabel(ChapterTranslationJob job) {
  return switch (job.status) {
    ChapterTranslationStatus.waitingForDownload =>
      S.current.chapter_translation_waiting_download,
    ChapterTranslationStatus.queued =>
      S.current.chapter_translation_queued_status,
    ChapterTranslationStatus.preparing =>
      S.current.chapter_translation_preparing,
    ChapterTranslationStatus.running => S.current.chapter_translation_progress(
      job.done,
      job.total,
    ),
    ChapterTranslationStatus.done => _doneLabel(job),
    ChapterTranslationStatus.failed => S.current.chapter_translation_failed,
  };
}

String _doneLabel(ChapterTranslationJob job) {
  if (job.failedPages > 0) {
    return S.current.chapter_translation_done_partial(job.failedPages);
  }
  return S.current.chapter_translation_done;
}
