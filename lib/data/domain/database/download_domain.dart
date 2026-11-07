import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class DownloadDomain extends BaseDomain<DownloadTableCompanion> {
  final String uid;
  final String extensionUid;
  final String concreteUid;
  final int concreteId;
  final String concreteTitle;
  final String? concreteCover;
  final String title;
  final DownloadStatus status;
  final int downloadedPages;
  final int totalPages;
  final String dirPath;
  final String? headers;
  final String? data;
  final DownloadKind kind;
  final int downloadedBytes;
  final int totalBytes;
  final String? playback;
  final int queuePosition;

  bool get isEpisode => kind == DownloadKind.episode;

  bool get isNovelChapter => kind == DownloadKind.novelChapter;

  bool get hasPageImages => kind == DownloadKind.chapter;

  bool get isPaused => status == DownloadStatus.paused;

  bool get isPending =>
      status == DownloadStatus.queued ||
      status == DownloadStatus.downloading ||
      status == DownloadStatus.paused;

  Map<String, String> get headersMap => headers != null
      ? (jsonDecode(headers!) as Map<String, dynamic>)
          .map((String k, dynamic v) => MapEntry(k, v.toString()))
      : <String, String>{};

  double get progress {
    if (totalPages > 0) {
      return (downloadedPages / totalPages).clamp(0.0, 1.0);
    }
    if (totalBytes > 0) {
      return (downloadedBytes / totalBytes).clamp(0.0, 1.0);
    }
    return 0;
  }

  Map<String, dynamic> get dataJson =>
      data != null ? jsonDecode(data!) as Map<String, dynamic> : {};

  DownloadDomain({
    required super.id,
    required this.uid,
    required this.extensionUid,
    required this.concreteUid,
    required this.concreteId,
    required this.concreteTitle,
    this.concreteCover,
    required this.title,
    required this.status,
    required this.downloadedPages,
    required this.totalPages,
    required this.dirPath,
    this.headers,
    this.data,
    this.kind = DownloadKind.chapter,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.playback,
    this.queuePosition = 0,
    required super.createdAt,
    super.updatedAt,
  });

  factory DownloadDomain.fromDrift(DownloadTableData data) => DownloadDomain(
        id: data.id,
        uid: data.uid,
        extensionUid: data.extensionUid,
        concreteUid: data.concreteUid,
        concreteId: data.concreteId,
        concreteTitle: data.concreteTitle,
        concreteCover: data.concreteCover,
        title: data.title,
        status: data.status,
        downloadedPages: data.downloadedPages,
        totalPages: data.totalPages,
        dirPath: data.dirPath,
        headers: data.headers,
        data: data.data,
        kind: data.kind,
        downloadedBytes: data.downloadedBytes,
        totalBytes: data.totalBytes,
        playback: data.playback,
        queuePosition: data.queuePosition,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  DownloadTableCompanion toDrift({bool update = false, bool create = false}) {
    if (create) {
      return DownloadTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        extensionUid: Value(extensionUid),
        concreteUid: Value(concreteUid),
        concreteId: Value(concreteId),
        concreteTitle: Value(concreteTitle),
        concreteCover: Value(concreteCover),
        title: Value(title),
        status: Value(status),
        downloadedPages: Value(downloadedPages),
        totalPages: Value(totalPages),
        dirPath: Value(dirPath),
        headers: Value(headers),
        data: Value(data),
        kind: Value(kind),
        downloadedBytes: Value(downloadedBytes),
        totalBytes: Value(totalBytes),
        playback: Value(playback),
        queuePosition: Value(queuePosition),
        createdAt: Value(createdAt),
      );
    }

    return DownloadTableCompanion(
      id: Value(id),
      uid: Value(uid),
      extensionUid: Value(extensionUid),
      concreteUid: Value(concreteUid),
      concreteId: Value(concreteId),
      title: Value(title),
      status: Value(status),
      downloadedPages: Value(downloadedPages),
      totalPages: Value(totalPages),
      dirPath: Value(dirPath),
      headers: Value(headers),
      data: Value(data),
      kind: Value(kind),
      downloadedBytes: Value(downloadedBytes),
      totalBytes: Value(totalBytes),
      playback: Value(playback),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  DownloadDomain copyWith({
    DownloadStatus? status,
    int? downloadedPages,
    int? totalPages,
    String? headers,
    int? downloadedBytes,
    int? totalBytes,
    String? playback,
  }) =>
      DownloadDomain(
        id: id,
        uid: uid,
        extensionUid: extensionUid,
        concreteUid: concreteUid,
        concreteId: concreteId,
        concreteTitle: concreteTitle,
        concreteCover: concreteCover,
        title: title,
        status: status ?? this.status,
        downloadedPages: downloadedPages ?? this.downloadedPages,
        totalPages: totalPages ?? this.totalPages,
        dirPath: dirPath,
        headers: headers ?? this.headers,
        data: data,
        kind: kind,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        playback: playback ?? this.playback,
        queuePosition: queuePosition,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
