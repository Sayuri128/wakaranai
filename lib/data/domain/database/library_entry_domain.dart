import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class LibraryEntryDomain extends BaseDomain<LibraryEntryTableCompanion> {
  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final int? categoryId;
  final DateTime? lastReadAt;

  Map<String, dynamic> get dataJson =>
      data != null ? jsonDecode(data!) as Map<String, dynamic> : {};

  LibraryEntryDomain({
    required super.id,
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.categoryId,
    this.lastReadAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory LibraryEntryDomain.fromDrift(LibraryEntryTableData data) =>
      LibraryEntryDomain(
        id: data.id,
        uid: data.uid,
        extensionUid: data.extensionUid,
        title: data.title,
        cover: data.cover,
        data: data.data,
        categoryId: data.categoryId,
        lastReadAt: data.lastReadAt,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  LibraryEntryTableCompanion toDrift(
      {bool update = false, bool create = false}) {
    if (create) {
      return LibraryEntryTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        extensionUid: Value(extensionUid),
        title: Value(title),
        cover: Value(cover),
        data: Value(data),
        categoryId: Value(categoryId),
        lastReadAt: Value(lastReadAt),
        createdAt: Value(createdAt),
      );
    }

    return LibraryEntryTableCompanion(
      id: Value(id),
      uid: Value(uid),
      extensionUid: Value(extensionUid),
      title: Value(title),
      cover: Value(cover),
      data: Value(data),
      categoryId: Value(categoryId),
      lastReadAt: Value(lastReadAt),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  LibraryEntryDomain copyWith({
    int? categoryId,
    bool clearCategory = false,
    DateTime? lastReadAt,
  }) =>
      LibraryEntryDomain(
        id: id,
        uid: uid,
        extensionUid: extensionUid,
        title: title,
        cover: cover,
        data: data,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        lastReadAt: lastReadAt ?? this.lastReadAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
