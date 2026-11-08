import 'package:capyscript/modules/waka_models/models/novel/novel_chapter_content.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/jobs/download_job_runner.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

class NovelChapterJobRunner extends DownloadJobRunner<NovelChapterDownloadJob> {
  NovelChapterJobRunner({
    required super.downloadRepository,
    required super.reportProgress,
    required DownloadDeletionCheck consumeDeletion,
  }) : _consumeDeletion = consumeDeletion;

  final DownloadDeletionCheck _consumeDeletion;

  @override
  Future<bool> run(NovelChapterDownloadJob job) async {
    if (job.isCancelled) {
      return false;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(job.uid);
    if (row == null || job.isCancelled) {
      return false;
    }
    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await reportProgress(job, progress: 0, max: 0);
      final NovelChapterContent content = await runSerializedOn(
        job.client,
        () => job.client.getChapterText(
          uid: job.chapterUid,
          data: job.data ?? <String, dynamic>{},
        ),
      );
      final bool deleted = _consumeDeletion(job.uid);
      if (deleted || job.isCancelled) {
        return false;
      }
      await DownloadFiles.writeNovelChapterFile(row.dirPath, content.html);
      if (job.isCancelled) {
        return false;
      }
      await downloadRepository.update(row.copyWith(
        status: DownloadStatus.done,
        downloadedPages: 1,
        totalPages: 1,
      ));
      await reportProgress(job, progress: 1, max: 1);
      return true;
    } catch (e, s) {
      if (job.isCancelled) {
        return false;
      }
      logger.e('Novel chapter download failed for ${job.uid}: $e');
      logger.e(s);
      await markFailed(job.uid);
      return false;
    }
  }
}
