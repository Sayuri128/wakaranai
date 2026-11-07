import 'dart:convert';
import 'dart:io';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/queue/download_job_queue.dart';
import 'package:wakaranai/services/downloads/queue/download_job_rebuilder.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

class DownloadQueueControl {
  DownloadQueueControl({
    required DownloadRepository downloadRepository,
    required DownloadJobQueue queue,
    required DownloadJobRebuilder rebuilder,
    required void Function() startQueue,
    required Future<void> Function() settleEmptiedQueue,
  })  : _downloads = downloadRepository,
        _queue = queue,
        _rebuilder = rebuilder,
        _startQueue = startQueue,
        _settleEmptiedQueue = settleEmptiedQueue;

  final DownloadRepository _downloads;
  final DownloadJobQueue _queue;
  final DownloadJobRebuilder _rebuilder;
  final void Function() _startQueue;
  final Future<void> Function() _settleEmptiedQueue;
  final Object _serialKey = Object();

  static bool isPausable(DownloadDomain row) =>
      row.status == DownloadStatus.queued ||
      row.status == DownloadStatus.downloading;

  static bool isPaused(DownloadDomain row) =>
      row.status == DownloadStatus.paused;

  Future<List<String>> pendingUidsWhere(
      bool Function(DownloadDomain row) test) async {
    final List<DownloadDomain> pending =
        await _downloads.getPendingInQueueOrder();
    return pending.where(test).map((DownloadDomain row) => row.uid).toList();
  }

  Future<bool> addChapter({
    required ApiClient client,
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    required String? concreteCover,
    required String chapterUid,
    required String title,
    required Map<String, dynamic>? data,
  }) async {
    final DownloadDomain? existing = await _downloads.getByUid(chapterUid);
    if (_isPendingOrDone(existing)) {
      return false;
    }

    final Directory dir =
        await DownloadFiles.chapterDir(extensionUid, concreteUid, chapterUid);

    _queue.deletedUids.remove(chapterUid);

    await _saveQueuedRow(DownloadDomain(
      id: 0,
      uid: chapterUid,
      extensionUid: extensionUid,
      concreteUid: concreteUid,
      concreteId: concreteId,
      concreteTitle: concreteTitle,
      concreteCover: concreteCover,
      title: title,
      status: DownloadStatus.queued,
      downloadedPages: 0,
      totalPages: 0,
      dirPath: dir.path,
      data: data != null ? jsonEncode(data) : null,
      kind: chapterDownloadKindFor(client),
      createdAt: DateTime.now(),
    ));

    _queue.replace(chapterDownloadJobFor(
      client: client,
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      chapterUid: chapterUid,
      title: title,
      data: data,
    ));
    return true;
  }

  Future<bool> addEpisode({
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    required String? concreteCover,
    required AnimeVideo episode,
  }) async {
    final DownloadDomain? existing = await _downloads.getByUid(episode.uid);
    if (_isPendingOrDone(existing)) {
      return false;
    }

    final String dirPath =
        await _episodeDirPath(existing, extensionUid, concreteUid, episode);

    _queue.deletedUids.remove(episode.uid);

    await _saveQueuedRow(DownloadDomain(
      id: 0,
      uid: episode.uid,
      extensionUid: extensionUid,
      concreteUid: concreteUid,
      concreteId: concreteId,
      concreteTitle: concreteTitle,
      concreteCover: concreteCover,
      title: episode.title,
      status: DownloadStatus.queued,
      downloadedPages: existing?.downloadedPages ?? 0,
      totalPages: existing?.totalPages ?? 0,
      downloadedBytes: existing?.downloadedBytes ?? 0,
      totalBytes: existing?.totalBytes ?? 0,
      dirPath: dirPath,
      data: encodeDownloadedEpisode(episode),
      kind: DownloadKind.episode,
      createdAt: DateTime.now(),
    ));

    _queue.replace(EpisodeDownloadJob(
      extensionUid: extensionUid,
      concreteTitle: concreteTitle,
      episode: episode,
    ));
    return true;
  }

  Future<void> pause(Iterable<String> uids) {
    final List<String> targets = uids.toList();
    return runSerializedOn<void>(_serialKey, () => _pauseAll(targets));
  }

  Future<void> resume(Iterable<String> uids) {
    final List<String> targets = uids.toList();
    return runSerializedOn<void>(_serialKey, () => _resumeAll(targets));
  }

  Future<void> reorder(List<String> orderedUids) {
    return runSerializedOn<void>(
      _serialKey,
      () => _applyQueueOrder((List<String> pending) => orderedUids),
    );
  }

  Future<void> downloadNext(String uid) {
    return runSerializedOn<void>(_serialKey, () async {
      await _applyQueueOrder((List<String> pending) => <String>[uid]);
      await _resumeAll(<String>[uid]);
    });
  }

  Future<void> moveTitleToTop(String concreteUid) {
    return runSerializedOn<void>(_serialKey, () async {
      final Set<String> titleUids = (await _downloads
              .getByConcreteUid(concreteUid))
          .map((DownloadDomain row) => row.uid)
          .toSet();
      await _applyQueueOrder((List<String> pending) =>
          pending.where(titleUids.contains).toList());
    });
  }

  Future<void> recoverInterrupted() async {
    final List<DownloadDomain> rows = await _downloads.getPendingInQueueOrder();

    bool resumedAny = false;
    for (final DownloadDomain row in rows) {
      if (row.status == DownloadStatus.downloading) {
        await _downloads.update(row.copyWith(status: DownloadStatus.failed));
        continue;
      }
      if (row.status != DownloadStatus.queued) {
        continue;
      }
      if (await _resumeQueuedRow(row)) {
        resumedAny = true;
      }
    }
    if (resumedAny) {
      await _sortByStoredOrder();
      _startQueue();
    }
  }

  Future<void> settleStoppedJob(DownloadJob job) async {
    final bool heldForWifi = identical(_queue.heldForWifi, job);
    final bool stoppedByUser = _queue.stoppedByUser.remove(job);
    if (heldForWifi) {
      _queue.heldForWifi = null;
    }
    if (!heldForWifi && !stoppedByUser) {
      return;
    }
    final DownloadDomain? row = await _unfinishedRowOf(job.uid);
    if (row == null) {
      _queue.pauseRequested.remove(job.uid);
      return;
    }
    if (_queue.pauseRequested.remove(job.uid)) {
      await _parkPausedJob(row, job);
      return;
    }
    await _requeueStoppedJob(row, job);
  }

  static bool _isPendingOrDone(DownloadDomain? existing) {
    if (existing == null) {
      return false;
    }
    return existing.status == DownloadStatus.done || existing.isPending;
  }

  Future<String> _episodeDirPath(
    DownloadDomain? existing,
    String extensionUid,
    String concreteUid,
    AnimeVideo episode,
  ) async {
    final String? previousDir = existing?.dirPath;
    if (previousDir != null && previousDir.isNotEmpty) {
      return previousDir;
    }
    final Directory dir =
        await DownloadFiles.chapterDir(extensionUid, concreteUid, episode.uid);
    return dir.path;
  }

  Future<void> _saveQueuedRow(DownloadDomain row) async {
    await _downloads.createUpdateBy<$DownloadTableTable, String>(
      row,
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );
    await _downloads.moveToQueueEnd(row.uid);
  }

  Future<bool> _resumeQueuedRow(DownloadDomain row) async {
    if (_queue.hasJob(row.uid)) {
      return false;
    }
    final DownloadJob? job = await _rebuilder.rebuild(row);
    final DownloadDomain? current = await _downloads.getByUid(row.uid);
    if (current == null ||
        current.status != DownloadStatus.queued ||
        _queue.deletedUids.contains(row.uid) ||
        _queue.hasJob(row.uid)) {
      return false;
    }
    if (job == null) {
      logger.w('Cannot resume ${row.uid} after a restart, marking it failed');
      await _downloads.update(current.copyWith(status: DownloadStatus.failed));
      return false;
    }
    _queue.waiting.add(job);
    return true;
  }

  Future<DownloadDomain?> _unfinishedRowOf(String uid) async {
    if (_queue.deletedUids.contains(uid)) {
      return null;
    }
    final DownloadDomain? row = await _downloads.getByUid(uid);
    if (row == null ||
        row.status == DownloadStatus.done ||
        _queue.deletedUids.contains(uid)) {
      return null;
    }
    return row;
  }

  Future<void> _parkPausedJob(DownloadDomain row, DownloadJob job) async {
    await _downloads.update(row.copyWith(status: DownloadStatus.paused));
    _queue.parkedJobs[job.uid] = job.restarted();
    _queue.stepBackInBatch();
  }

  Future<void> _requeueStoppedJob(DownloadDomain row, DownloadJob job) async {
    await _downloads.update(row.copyWith(status: DownloadStatus.queued));
    if (_queue.deletedUids.contains(job.uid) || _queue.isWaiting(job.uid)) {
      return;
    }
    if (_queue.pauseRequested.remove(job.uid)) {
      await _parkPausedJob(row, job);
      return;
    }
    _queue.waiting.addFirst(job.restarted());
    _queue.stepBackInBatch();
  }

  Future<void> _pauseAll(List<String> uids) async {
    _detachWaitingJobs(uids);
    final String? activeUid = _queue.active?.uid;
    for (final String uid in uids) {
      if (uid != activeUid) {
        await _pauseWaiting(uid);
      }
    }
    if (activeUid != null && uids.contains(activeUid)) {
      _pauseActive(activeUid);
    }
    await _settleEmptiedQueue();
  }

  void _detachWaitingJobs(List<String> uids) {
    final Set<String> targets = uids.toSet();
    for (final DownloadJob job in _queue.waiting.toList()) {
      if (targets.contains(job.uid)) {
        _queue.waiting.remove(job);
        _queue.parkedJobs[job.uid] = job;
      }
    }
  }

  void _pauseActive(String uid) {
    final DownloadJob? job = _queue.active;
    if (job == null || job.uid != uid) {
      return;
    }
    _queue.pauseRequested.add(uid);
    _queue.stoppedByUser.add(job);
    job.cancel('paused');
  }

  Future<void> _pauseWaiting(String uid) async {
    if (_queue.active?.uid == uid) {
      _pauseActive(uid);
      return;
    }
    final DownloadDomain? row = await _downloads.getByUid(uid);
    if (row == null ||
        !isPausable(row) ||
        _queue.deletedUids.contains(uid)) {
      return;
    }
    await _downloads.update(row.copyWith(status: DownloadStatus.paused));
  }

  Future<void> _resumeAll(List<String> uids) async {
    bool resumedAny = false;
    for (final String uid in uids) {
      if (await _resumeOne(uid)) {
        resumedAny = true;
      }
    }
    if (!resumedAny) {
      return;
    }
    await _sortByStoredOrder();
    _startQueue();
  }

  Future<bool> _resumeOne(String uid) async {
    if (_queue.pauseRequested.remove(uid)) {
      return false;
    }
    final DownloadDomain? row = await _downloads.getByUid(uid);
    if (row == null || !isPaused(row) || _queue.hasJob(uid)) {
      return false;
    }
    final DownloadJob? job = await _resumableJob(row);
    final DownloadDomain? current = await _downloads.getByUid(uid);
    if (current == null ||
        !isPaused(current) ||
        _queue.deletedUids.contains(uid) ||
        _queue.hasJob(uid)) {
      return false;
    }
    if (job == null) {
      logger.w('Cannot resume $uid, marking it failed');
      _queue.parkedJobs.remove(uid);
      await _downloads.update(current.copyWith(status: DownloadStatus.failed));
      return false;
    }
    await _downloads.update(current.copyWith(status: DownloadStatus.queued));
    if (_queue.deletedUids.contains(uid) || _queue.hasJob(uid)) {
      return false;
    }
    _queue.parkedJobs.remove(uid);
    _queue.waiting.add(job);
    return true;
  }

  Future<DownloadJob?> _resumableJob(DownloadDomain row) async {
    final DownloadJob? rebuilt = await _rebuilder.rebuild(row);
    if (rebuilt != null) {
      return rebuilt;
    }
    return _queue.parkedJobs[row.uid]?.restarted();
  }

  Future<void> _applyQueueOrder(
    List<String> Function(List<String> pending) pickFirst,
  ) async {
    final List<String> pending = (await _downloads.getPendingInQueueOrder())
        .map((DownloadDomain row) => row.uid)
        .toList();
    final List<String> order =
        _queue.orderWithActiveFirst(pending, pickFirst(pending));
    await _downloads.writeQueueOrder(order);
    _queue.sortBy(order);
  }

  Future<void> _sortByStoredOrder() async {
    final List<DownloadDomain> pending =
        await _downloads.getPendingInQueueOrder();
    _queue.sortBy(pending.map((DownloadDomain row) => row.uid).toList());
  }
}
