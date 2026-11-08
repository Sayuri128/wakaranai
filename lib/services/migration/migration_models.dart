import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';
import 'package:wakaranai/utils/config_info_type_kinds.dart';

class MigrationSubject {
  const MigrationSubject({
    required this.uid,
    required this.extensionUid,
    required this.title,
    this.cover,
    this.data,
    this.type,
    this.sourceName,
    this.alternativeTitles = const <String>[],
  });

  factory MigrationSubject.fromLibraryEntry(
    LibraryEntryDomain entry, {
    ConfigInfoType? type,
    String? sourceName,
  }) {
    return MigrationSubject(
      uid: entry.uid,
      extensionUid: entry.extensionUid,
      title: entry.title,
      cover: entry.cover,
      data: entry.data,
      type: type,
      sourceName: sourceName,
    );
  }

  final String uid;
  final String extensionUid;
  final String title;
  final String? cover;
  final String? data;
  final ConfigInfoType? type;
  final String? sourceName;
  final List<String> alternativeTitles;

  List<String> get searchTitles {
    final List<String> titles = <String>[];
    for (final String candidate in <String>[title, ...alternativeTitles]) {
      final String trimmed = candidate.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final bool known = titles.any(
        (String title) => title.toLowerCase() == trimmed.toLowerCase(),
      );
      if (!known) {
        titles.add(trimmed);
      }
    }
    return titles;
  }

  MigrationSubject copyWith({
    String? title,
    String? cover,
    ConfigInfoType? type,
    String? sourceName,
    List<String>? alternativeTitles,
  }) {
    return MigrationSubject(
      uid: uid,
      extensionUid: extensionUid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      data: data,
      type: type ?? this.type,
      sourceName: sourceName ?? this.sourceName,
      alternativeTitles: alternativeTitles ?? this.alternativeTitles,
    );
  }
}

class MigrationOptions {
  const MigrationOptions({
    this.keepOld = false,
    this.moveCategory = true,
    this.moveProgress = true,
    this.moveTrackers = true,
  });

  final bool keepOld;
  final bool moveCategory;
  final bool moveProgress;
  final bool moveTrackers;

  MigrationOptions copyWith({
    bool? keepOld,
    bool? moveCategory,
    bool? moveProgress,
    bool? moveTrackers,
  }) {
    return MigrationOptions(
      keepOld: keepOld ?? this.keepOld,
      moveCategory: moveCategory ?? this.moveCategory,
      moveProgress: moveProgress ?? this.moveProgress,
      moveTrackers: moveTrackers ?? this.moveTrackers,
    );
  }
}

class MigrationTarget {
  const MigrationTarget({
    required this.concrete,
    required this.config,
    required this.galleryData,
  });

  final ConcreteView concrete;
  final ConfigInfo config;
  final Map<String, dynamic> galleryData;

  String get uid => concrete.uid;

  String get extensionUid => config.uid;

  String get encodedGalleryData => jsonEncode(galleryData);
}

class MigrationRequest {
  const MigrationRequest({
    required this.subject,
    required this.target,
    required this.progress,
    required this.options,
  });

  final MigrationSubject subject;
  final MigrationTarget target;
  final MigrationProgressPlan progress;
  final MigrationOptions options;

  bool get sameTitle => subject.uid == target.uid;
}

class MigrationResult {
  const MigrationResult({
    required this.entry,
    required this.progressWritten,
    required this.trackersMoved,
    required this.removedOld,
    required this.sourceName,
  });

  final LibraryEntryDomain entry;
  final String sourceName;
  final int progressWritten;
  final int trackersMoved;
  final bool removedOld;
}

MigrationMediaKind migrationKindOf(ConfigInfoType type) {
  if (type.readsChapters) {
    return MigrationMediaKind.chapters;
  }
  return MigrationMediaKind.episodes;
}
