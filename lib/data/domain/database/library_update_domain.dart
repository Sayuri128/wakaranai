import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class LibraryUpdateDomain extends BaseDomain<LibraryUpdateTableCompanion> {
  final String uid;
  final String libraryEntryUid;
  final String extensionUid;
  final String title;
  final String concreteTitle;
  final String? concreteCover;
  final UpdateMediaType mediaType;
  final String? data;
  final bool seen;

  Map<String, dynamic> get dataJson =>
      data != null ? jsonDecode(data!) as Map<String, dynamic> : {};

  DateTime get foundAt => createdAt;

  LibraryUpdateDomain({
    required super.id,
    required this.uid,
    required this.libraryEntryUid,
    required this.extensionUid,
    required this.title,
    required this.concreteTitle,
    this.concreteCover,
    required this.mediaType,
    this.data,
    this.seen = false,
    required super.createdAt,
    super.updatedAt,
  });

  factory LibraryUpdateDomain.fromDrift(LibraryUpdateTableData data) =>
      LibraryUpdateDomain(
        id: data.id,
        uid: data.uid,
        libraryEntryUid: data.libraryEntryUid,
        extensionUid: data.extensionUid,
        title: data.title,
        concreteTitle: data.concreteTitle,
        concreteCover: data.concreteCover,
        mediaType: data.mediaType,
        data: data.data,
        seen: data.seen,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  LibraryUpdateTableCompanion toDrift(
      {bool update = false, bool create = false}) {
    if (create) {
      return LibraryUpdateTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        libraryEntryUid: Value(libraryEntryUid),
        extensionUid: Value(extensionUid),
        title: Value(title),
        concreteTitle: Value(concreteTitle),
        concreteCover: Value(concreteCover),
        mediaType: Value(mediaType),
        data: Value(data),
        seen: Value(seen),
        createdAt: Value(createdAt),
      );
    }

    return LibraryUpdateTableCompanion(
      id: Value(id),
      uid: Value(uid),
      libraryEntryUid: Value(libraryEntryUid),
      extensionUid: Value(extensionUid),
      title: Value(title),
      concreteTitle: Value(concreteTitle),
      concreteCover: Value(concreteCover),
      mediaType: Value(mediaType),
      data: Value(data),
      seen: Value(seen),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  LibraryUpdateDomain copyWith({bool? seen}) => LibraryUpdateDomain(
        id: id,
        uid: uid,
        libraryEntryUid: libraryEntryUid,
        extensionUid: extensionUid,
        title: title,
        concreteTitle: concreteTitle,
        concreteCover: concreteCover,
        mediaType: mediaType,
        data: data,
        seen: seen ?? this.seen,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
