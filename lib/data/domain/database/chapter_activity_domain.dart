import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class ChapterActivityDomain extends BaseDomain<ChapterActivityTableCompanion> {
  final String uid;
  final String title;
  final String? timestamp;
  final String? data;
  final int concreteId;
  final int readPages;
  final int totalPages;

  bool get isCompleted => readPages >= totalPages;
  Map<String, dynamic> get dataJson => data != null ? jsonDecode(data!) : {};

  factory ChapterActivityDomain.fromDrift(ChapterActivityTableData data) =>
      ChapterActivityDomain(
        id: data.id,
        uid: data.uid,
        title: data.title,
        timestamp: data.timestamp,
        data: data.data,
        concreteId: data.concreteId,
        readPages: data.readPages,
        totalPages: data.totalPages,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  ChapterActivityTableCompanion toDrift(
      {bool update = false, bool create = false}) {
    if (create) {
      return ChapterActivityTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        title: Value(title),
        timestamp: Value(timestamp),
        data: Value(data),
        concreteId: Value(concreteId),
        readPages: Value(readPages),
        totalPages: Value(totalPages),
        createdAt: Value(createdAt),
      );
    }

    return ChapterActivityTableCompanion(
      id: Value(id),
      uid: Value(uid),
      title: Value(title),
      timestamp: Value(timestamp),
      data: Value(data),
      concreteId: Value(concreteId),
      readPages: Value(readPages),
      totalPages: Value(totalPages),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  ChapterActivityDomain({
    required this.uid,
    required this.title,
    required this.timestamp,
    required this.data,
    required this.concreteId,
    required this.readPages,
    required this.totalPages,
    required super.id,
    required super.createdAt,
    super.updatedAt,
  });

  ChapterActivityDomain copyWith({
    int? id,
    String? title,
    String? uid,
    String? timestamp,
    String? data,
    int? concreteId,
    int? readPages,
    int? totalPages,
  }) {
    return ChapterActivityDomain(
      id: id ?? this.id,
      title: title ?? this.title,
      uid: uid ?? this.uid,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      concreteId: concreteId ?? this.concreteId,
      readPages: readPages ?? this.readPages,
      totalPages: totalPages ?? this.totalPages,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
