import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/blocs/downloads/download_notification_service.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';

part 'download_manager_state.dart';

class _DownloadJob {
  final MangaApiClient client;
  final String extensionUid;
  final String concreteUid;
  final int concreteId;
  final String concreteTitle;
  final String? concreteCover;
  final String chapterUid;
  final String title;
  final Map<String, dynamic>? data;

  const _DownloadJob({
    required this.client,
    required this.extensionUid,
    required this.concreteUid,
    required this.concreteId,
    required this.concreteTitle,
    required this.concreteCover,
    required this.chapterUid,
    required this.title,
    required this.data,
  });
}

class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit({
    required this.downloadRepository,
    DownloadNotificationService? notificationService,
  })  : notificationService =
            notificationService ?? DownloadNotificationService(),
        super(const DownloadManagerState());

  final DownloadRepository downloadRepository;
  final DownloadNotificationService notificationService;

  final Dio _dio = Dio();
  final Queue<_DownloadJob> _jobs = Queue<_DownloadJob>();
  final Set<String> _cancelled = <String>{};
  bool _processing = false;
  int _completedInBatch = 0;
  int _batchIndex = 0;
  bool _permissionRequested = false;

  int get _batchTotal => _batchIndex + _jobs.length;

  StreamSubscription<List<DownloadDomain>>? _sub;

  void init() {
    _sub?.cancel();
    _sub = downloadRepository.watchAll().listen((List<DownloadDomain> rows) {
      emit(state.copyWith(downloads: rows));
    });
  }

  bool isDownloaded(String chapterUid) {
    return state.downloads.any((DownloadDomain d) =>
        d.uid == chapterUid && d.status == DownloadStatus.done);
  }

  Future<void> enqueueChapter({
    required MangaApiClient client,
    required String extensionUid,
    required String concreteUid,
    required int concreteId,
    required String concreteTitle,
    required String? concreteCover,
    required String chapterUid,
    required String title,
    required Map<String, dynamic>? data,
    bool autoStart = true,
  }) async {
    final DownloadDomain? existing =
        await downloadRepository.getByUid(chapterUid);
    if (existing != null &&
        (existing.status == DownloadStatus.done ||
            existing.status == DownloadStatus.downloading ||
            existing.status == DownloadStatus.queued)) {
      return;
    }

    final Directory dir =
        await _chapterDir(extensionUid, concreteUid, chapterUid);

    _cancelled.remove(chapterUid);

    await downloadRepository.createUpdateBy<$DownloadTableTable, String>(
      DownloadDomain(
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
        createdAt: DateTime.now(),
      ),
      by: (DownloadDomain d) => d.uid,
      where: (tbl) => tbl.uid,
    );

    _jobs.add(_DownloadJob(
      client: client,
      extensionUid: extensionUid,
      concreteUid: concreteUid,
      concreteId: concreteId,
      concreteTitle: concreteTitle,
      concreteCover: concreteCover,
      chapterUid: chapterUid,
      title: title,
      data: data,
    ));

    if (autoStart) {
      startQueue();
    }
  }

  void startQueue() {
    unawaited(_process());
  }

  Future<void> _ensurePermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      await notificationService.requestPermission();
    } catch (e, s) {
      logger.w('Failed to request download notification permission: $e');
      logger.w(s);
    }
  }

  Future<void> _process() async {
    if (_processing) return;
    _processing = true;
    _completedInBatch = 0;
    _batchIndex = 0;
    try {
      await _ensurePermission();
      while (_jobs.isNotEmpty) {
        final _DownloadJob job = _jobs.removeFirst();
        if (_cancelled.contains(job.chapterUid)) {
          _cancelled.remove(job.chapterUid);
          continue;
        }
        _batchIndex++;
        final bool completed = await _runJob(job);
        if (completed) _completedInBatch++;
      }
    } finally {
      _processing = false;
      _batchIndex = 0;
      await notificationService.showComplete(_completedInBatch);
      _completedInBatch = 0;
    }
  }


  Future<bool> _runJob(_DownloadJob job) async {
    DownloadDomain? row = await downloadRepository.getByUid(job.chapterUid);
    if (row == null) return false;

    try {
      await downloadRepository
          .update(row.copyWith(status: DownloadStatus.downloading));
      await notificationService.showProgress(
        title: job.concreteTitle,
        chapterTitle: job.title,
        progress: 0,
        max: 0,
        queueIndex: _batchIndex,
        queueTotal: _batchTotal,
      );

      final pages =
          await job.client.getPages(uid: job.chapterUid, data: job.data);
      final Map<String, String> headers = await job.client
          .getImageHeaders(uid: pages.chapterUid, data: <String, dynamic>{});
      final String headersJson = jsonEncode(headers);

      final Directory dir = Directory(row.dirPath);
      await dir.create(recursive: true);

      row = row.copyWith(
        totalPages: pages.value.length,
        downloadedPages: 0,
        headers: headersJson,
        status: DownloadStatus.downloading,
      );
      await downloadRepository.update(row);

      for (int i = 0; i < pages.value.length; i++) {
        if (_cancelled.contains(job.chapterUid)) {
          _cancelled.remove(job.chapterUid);
          return false;
        }

        final String url = pages.value[i];
        final File file = File(p.join(dir.path, _pageFileName(i)));

        if (url.startsWith('data:')) {
          await file.writeAsBytes(base64Decode(url.split(',').last));
        } else {
          final Response<List<int>> response = await _dio.get<List<int>>(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              headers: headers,
            ),
          );
          await file.writeAsBytes(response.data ?? <int>[]);
        }

        row = row!.copyWith(downloadedPages: i + 1);
        await downloadRepository.update(row);
        await notificationService.showProgress(
          title: job.concreteTitle,
          chapterTitle: job.title,
          progress: i + 1,
          max: pages.value.length,
          queueIndex: _batchIndex,
          queueTotal: _batchTotal,
        );
      }

      await downloadRepository.update(row!.copyWith(
        status: DownloadStatus.done,
        downloadedPages: pages.value.length,
        totalPages: pages.value.length,
      ));
      return true;
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      final DownloadDomain? current =
          await downloadRepository.getByUid(job.chapterUid);
      if (current != null) {
        await downloadRepository
            .update(current.copyWith(status: DownloadStatus.failed));
      }
      return false;
    }
  }

  Future<void> retry({
    required MangaApiClient client,
    required DownloadDomain download,
    Map<String, dynamic>? data,
  }) {
    return enqueueChapter(
      client: client,
      extensionUid: download.extensionUid,
      concreteUid: download.concreteUid,
      concreteId: download.concreteId,
      concreteTitle: download.concreteTitle,
      concreteCover: download.concreteCover,
      chapterUid: download.uid,
      title: download.title,
      data: data ??
          (download.data != null
              ? jsonDecode(download.data!) as Map<String, dynamic>
              : null),
    );
  }

  Future<void> deleteDownload(DownloadDomain download) async {
    _cancelled.add(download.uid);
    _jobs.removeWhere((_DownloadJob j) => j.chapterUid == download.uid);
    await downloadRepository.deleteByUid(download.uid);
    await _deleteDir(download.dirPath);
  }

  Future<void> deleteForConcrete(String concreteUid) async {
    final List<DownloadDomain> rows =
        await downloadRepository.getByConcreteUid(concreteUid);
    for (final DownloadDomain row in rows) {
      await deleteDownload(row);
    }
  }

  Future<void> deleteAll() async {
    final List<DownloadDomain> rows =
        List<DownloadDomain>.from(state.downloads);
    for (final DownloadDomain row in rows) {
      await deleteDownload(row);
    }
  }

  Future<void> _deleteDir(String dirPath) async {
    try {
      final Directory dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      logger.w('Failed to delete download dir $dirPath: $e');
    }
  }

  Future<Directory> _chapterDir(
      String extensionUid, String concreteUid, String chapterUid) async {
    final Directory docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(
      docs.path,
      'downloads',
      _sanitize(extensionUid),
      _sanitize(concreteUid),
      _sanitize(chapterUid),
    ));
  }

  static String _sanitize(String value) {
    final String cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.length <= 80) return cleaned;
    return '${cleaned.substring(0, 80)}_${value.hashCode.toUnsigned(32)}';
  }

  static String _pageFileName(int index) =>
      '${index.toString().padLeft(4, '0')}.img';

  static List<String> localPagePaths(DownloadDomain download) =>
      List<String>.generate(download.totalPages,
          (int i) => p.join(download.dirPath, _pageFileName(i)));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
