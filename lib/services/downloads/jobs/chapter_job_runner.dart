import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/utils/image_headers.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/jobs/chapter_page_writer.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/jobs/download_job_runner.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';

class ChapterJobRunner extends DownloadJobRunner<ChapterDownloadJob> {
  ChapterJobRunner({
    required super.downloadRepository,
    required super.reportProgress,
    required DownloadDeletionCheck consumeDeletion,
    required ChapterPageWriter pageWriter,
    required DownloadThrottle throttle,
    required DownloadWait wait,
  })  : _consumeDeletion = consumeDeletion,
        _pageWriter = pageWriter,
        _throttle = throttle,
        _wait = wait;

  final DownloadDeletionCheck _consumeDeletion;
  final ChapterPageWriter _pageWriter;
  final DownloadThrottle _throttle;
  final DownloadWait _wait;

  @override
  Future<bool> run(ChapterDownloadJob job) async {
    if (job.isCancelled) {
      return false;
    }
    DownloadDomain? row = await downloadRepository.getByUid(job.chapterUid);
    if (row == null || job.isCancelled) {
      return false;
    }

    final CancelToken cancelToken = job.cancelToken;

    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await reportProgress(job, progress: 0, max: 0);

      final pages =
          await job.client.getPages(uid: job.chapterUid, data: job.data);
      final Map<String, String> headers = await job.client
          .imageHeadersOrEmpty(uid: pages.chapterUid, data: <String, dynamic>{});
      final String headersJson = jsonEncode(headers);

      final Directory dir = Directory(row.dirPath);
      await dir.create(recursive: true);
      final int keptPages =
          await DownloadFiles.keptChapterPages(row, dir, pages.value.length);

      row = row.copyWith(
        totalPages: pages.value.length,
        downloadedPages: keptPages,
        headers: headersJson,
        status: DownloadStatus.downloading,
      );
      await downloadRepository.update(row);

      DateTime lastPublish = DateTime.fromMillisecondsSinceEpoch(0);

      for (int i = keptPages; i < pages.value.length; i++) {
        if (_consumeDeletion(job.chapterUid)) {
          return false;
        }
        if (cancelToken.isCancelled) {
          return false;
        }

        final String url = pages.value[i];
        final File file =
            File(p.join(dir.path, DownloadFiles.pageFileName(i)));

        if (i > keptPages) {
          await waitIfPositive(_wait, _throttle.pageDelay(job.extensionUid));
        }
        await _pageWriter.write(
          url: url,
          file: file,
          headers: headers,
          extensionUid: job.extensionUid,
          cancelToken: cancelToken,
        );

        row = row!.copyWith(downloadedPages: i + 1);

        final bool last = i == pages.value.length - 1;
        final DateTime now = DateTime.now();
        final bool due = now.difference(lastPublish) >=
            DownloadJobRunner.progressPersistInterval;
        if (last || due) {
          lastPublish = now;
          await downloadRepository.update(row);
          await reportProgress(
            job,
            progress: i + 1,
            max: pages.value.length,
          );
        }
      }

      await downloadRepository.update(row!.copyWith(
        status: DownloadStatus.done,
        downloadedPages: pages.value.length,
        totalPages: pages.value.length,
      ));
      return true;
    } catch (e, s) {
      if (cancelToken.isCancelled ||
          (e is DioException && CancelToken.isCancel(e))) {
        return false;
      }
      logger.e('Download failed for ${job.chapterUid}: $e');
      logger.e(s);
      await markFailed(job.chapterUid);
      return false;
    }
  }
}
