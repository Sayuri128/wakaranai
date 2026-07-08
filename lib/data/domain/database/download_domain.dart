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

  Map<String, String> get headersMap => headers != null
      ? (jsonDecode(headers!) as Map<String, dynamic>)
          .map((String k, dynamic v) => MapEntry(k, v.toString()))
      : <String, String>{};

  double get progress =>
      totalPages == 0 ? 0 : (downloadedPages / totalPages).clamp(0.0, 1.0);

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
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  DownloadDomain copyWith({
    DownloadStatus? status,
    int? downloadedPages,
    int? totalPages,
    String? headers,
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
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
