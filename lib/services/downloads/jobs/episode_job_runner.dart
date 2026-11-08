import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_progress_recorder.dart';
import 'package:wakaranai/services/downloads/episode/episode_source_resolver.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/jobs/download_job_runner.dart';
import 'package:wakaranai/services/downloads/storage/download_quality_reader.dart';

class EpisodeJobRunner extends DownloadJobRunner<EpisodeDownloadJob> {
  EpisodeJobRunner({
    required super.downloadRepository,
    required super.reportProgress,
    required QualityPreferenceReader readQualityPreference,
    required EpisodeSourceResolver sources,
    required EpisodeDownloader downloader,
  })  : _readQualityPreference = readQualityPreference,
        _sources = sources,
        _downloader = downloader;

  static const int _sourceRefreshes = 2;

  final QualityPreferenceReader _readQualityPreference;
  final EpisodeSourceResolver _sources;
  final EpisodeDownloader _downloader;

  @override
  Future<bool> run(EpisodeDownloadJob job) async {
    if (job.isCancelled) {
      return false;
    }
    final DownloadDomain? row = await downloadRepository.getByUid(job.uid);
    if (row == null || job.isCancelled) {
      return false;
    }

    final CancelToken cancelToken = job.cancelToken;
    final EpisodeProgressRecorder recorder = EpisodeProgressRecorder(
      interval: DownloadJobRunner.progressPersistInterval,
      publish: (EpisodeDownloadProgress progress) =>
          _publishProgress(job, cancelToken, progress),
    );

    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await reportProgress(job, progress: 0, max: 0);

      final EpisodeDownloadManifest manifest = await _download(
        job: job,
        dir: Directory(row.dirPath),
        cancelToken: cancelToken,
        recorder: recorder,
      );
      await recorder.flush();
      return await _complete(job, manifest);
    } catch (e, s) {
      await recorder.flush();
      if (cancelToken.isCancelled ||
          (e is DioException && CancelToken.isCancel(e))) {
        return false;
      }
      logger.e('Episode download failed for ${job.uid}: $e');
      logger.e(s);
      await markFailed(job.uid);
      return false;
    }
  }

  Future<EpisodeDownloadManifest> _download({
    required EpisodeDownloadJob job,
    required Directory dir,
    required CancelToken cancelToken,
    required EpisodeProgressRecorder recorder,
  }) async {
    final QualityPreference quality = await _readQualityPreference();
    int refreshes = 0;
    while (true) {
      final PlayableVideo video = await _sources.resolve(
        extensionUid: job.extensionUid,
        episode: job.episode,
      );
      _throwIfCancelled(cancelToken);
      try {
        return await _downloader.download(
          video: video,
          quality: quality,
          dir: dir,
          throttleKey: job.extensionUid,
          cancelToken: cancelToken,
          onProgress: recorder.record,
        );
      } on EpisodeSourceExpired catch (e) {
        if (refreshes >= _sourceRefreshes) {
          rethrow;
        }
        refreshes++;
        logger.w('Sources of ${job.uid} expired ($e), resolving them again');
      }
    }
  }

  void _throwIfCancelled(CancelToken cancelToken) {
    final DioException? cancelError = cancelToken.cancelError;
    if (cancelError != null) {
      throw cancelError;
    }
  }

  Future<bool> _complete(
    EpisodeDownloadJob job,
    EpisodeDownloadManifest manifest,
  ) async {
    if (job.isCancelled) {
      return false;
    }
    final DownloadDomain? current = await downloadRepository.getByUid(job.uid);
    if (current == null || job.isCancelled) {
      return false;
    }
    await downloadRepository.update(current.copyWith(
      status: DownloadStatus.done,
      playback: manifest.encode(),
    ));
    return true;
  }

  Future<void> _publishProgress(
    EpisodeDownloadJob job,
    CancelToken cancelToken,
    EpisodeDownloadProgress progress,
  ) async {
    if (cancelToken.isCancelled) {
      return;
    }
    try {
      final DownloadDomain? current =
          await downloadRepository.getByUid(job.uid);
      if (current == null || cancelToken.isCancelled) {
        return;
      }
      await downloadRepository.update(current.copyWith(
        downloadedPages: progress.completedSegments,
        totalPages: progress.totalSegments,
        downloadedBytes: progress.downloadedBytes,
        totalBytes: progress.totalBytes,
      ));
      final (int done, int max) = episodeNotificationProgress(progress);
      await reportProgress(job, progress: done, max: max);
    } catch (e) {
      logger.w('Could not record progress of ${job.uid}: $e');
    }
  }
}
