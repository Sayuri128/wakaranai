import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';
import 'package:wakaranai/services/trackers/tracker_progress.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

class _EpisodeKey {
  const _EpisodeKey({required this.number, required this.season});

  final double? number;
  final int? season;
}

class MigrationStore {
  MigrationStore({required this.database});

  final WakaranaiDatabase database;

  Future<ConcreteDataTableData?> _concreteByUid(String uid) {
    return (database.select(database.concreteDataTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<LibraryEntryTableData?> _entryByUid(String uid) {
    return (database.select(database.libraryEntryTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<ConcreteDataTableData?> savedConcrete(String uid) {
    return _concreteByUid(uid);
  }

  Future<List<String>> loadAlternativeTitles(String uid) async {
    final ConcreteDataTableData? concrete = await _concreteByUid(uid);
    final Map<String, dynamic>? json = _decodeConcrete(concrete);
    final Object? titles = json?['alternativeTitles'];
    if (titles is! List) {
      return const <String>[];
    }
    return titles.whereType<String>().toList(growable: false);
  }

  Future<MigrationMediaKind?> detectKind(String uid) async {
    final ConcreteDataTableData? concrete = await _concreteByUid(uid);
    if (concrete == null) {
      return null;
    }
    final List<AnimeEpisodeActivityTableData> episodes =
        await _episodeRows(concrete.id);
    if (episodes.isNotEmpty) {
      return MigrationMediaKind.episodes;
    }
    final List<ChapterActivityTableData> chapters =
        await _chapterRows(concrete.id);
    if (chapters.isNotEmpty) {
      return MigrationMediaKind.chapters;
    }
    return null;
  }

  Future<List<MigrationOldProgress>> loadOldProgress(
    String uid,
    MigrationMediaKind kind,
  ) async {
    final ConcreteDataTableData? concrete = await _concreteByUid(uid);
    if (concrete == null) {
      return const <MigrationOldProgress>[];
    }
    final Map<String, dynamic>? json = _decodeConcrete(concrete);
    if (kind == MigrationMediaKind.chapters) {
      final Map<String, double?> numbers = _chapterNumbers(json);
      final List<ChapterActivityTableData> rows =
          await _chapterRows(concrete.id);
      return rows
          .map((ChapterActivityTableData row) => MigrationOldProgress.fromChapter(
                ChapterActivityDomain.fromDrift(row),
                number: numbers[row.uid],
              ))
          .toList(growable: false);
    }
    final Map<String, _EpisodeKey> keys = _episodeKeys(json);
    final List<AnimeEpisodeActivityTableData> rows =
        await _episodeRows(concrete.id);
    return rows.map((AnimeEpisodeActivityTableData row) {
      final _EpisodeKey? key = keys[row.uid];
      return MigrationOldProgress.fromEpisode(
        AnimeEpisodeActivityDomain.fromDrift(row),
        number: key?.number,
        season: key?.season,
      );
    }).toList(growable: false);
  }

  Future<int> countTrackerLinks(String uid) async {
    final List<TrackerLinkTableData> rows =
        await (database.select(database.trackerLinkTable)
              ..where((tbl) => tbl.concreteUid.equals(uid)))
            .get();
    return rows.length;
  }

  Future<int> countDownloads(String uid) async {
    final List<DownloadTableData> rows =
        await (database.select(database.downloadTable)
              ..where((tbl) =>
                  tbl.concreteUid.equals(uid) &
                  tbl.status.equals(DownloadStatus.done.index)))
            .get();
    return rows.length;
  }

  Future<int?> categoryOf(String uid) async {
    final LibraryEntryTableData? entry = await _entryByUid(uid);
    return entry?.categoryId;
  }

  Future<List<ChapterActivityTableData>> _chapterRows(int concreteId) {
    return (database.select(database.chapterActivityTable)
          ..where((tbl) => tbl.concreteId.equals(concreteId)))
        .get();
  }

  Future<List<AnimeEpisodeActivityTableData>> _episodeRows(int concreteId) {
    return (database.select(database.animeEpisodeActivityTable)
          ..where((tbl) => tbl.concreteId.equals(concreteId)))
        .get();
  }

  Map<String, dynamic>? _decodeConcrete(ConcreteDataTableData? concrete) {
    final String? encoded = concrete?.concreteJson;
    if (encoded == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException catch (e) {
      logger.w('Saved details of ${concrete?.uid} are unreadable: $e');
    }
    return null;
  }

  Map<String, double?> _chapterNumbers(Map<String, dynamic>? json) {
    if (json == null) {
      return const <String, double?>{};
    }
    try {
      final MangaConcreteView view = MangaConcreteView.fromJson(json);
      return <String, double?>{
        for (final ChaptersGroup group in view.groups)
          for (final Chapter chapter in group.elements)
            chapter.uid: chapter.number ?? parseChapterNumber(chapter.title),
      };
    } catch (e) {
      logger.w('Saved chapters could not be read for migration: $e');
      return const <String, double?>{};
    }
  }

  Map<String, _EpisodeKey> _episodeKeys(Map<String, dynamic>? json) {
    if (json == null) {
      return const <String, _EpisodeKey>{};
    }
    try {
      final AnimeConcreteView view = AnimeConcreteView.fromJson(json);
      return <String, _EpisodeKey>{
        for (final AnimeVideoGroup group in view.groups)
          for (final AnimeVideo episode in group.elements)
            episode.uid: _EpisodeKey(
              number: episodeNumberOf(episode),
              season: episode.season,
            ),
      };
    } catch (e) {
      logger.w('Saved episodes could not be read for migration: $e');
      return const <String, _EpisodeKey>{};
    }
  }

  Future<MigrationResult> apply(MigrationRequest request) {
    return database.transaction<MigrationResult>(() async {
      final LibraryEntryTableData? oldEntry =
          await _entryByUid(request.subject.uid);
      final int concreteId = await _upsertConcrete(request.target);
      int progressWritten = 0;
      if (request.options.moveProgress) {
        progressWritten = await _writeProgress(request.progress, concreteId);
      }
      final LibraryEntryDomain entry = await _upsertEntry(request, oldEntry);
      bool removedOld = false;
      if (!request.options.keepOld && !request.sameTitle) {
        removedOld = await _removeOldEntry(request.subject.uid);
      }
      int trackersMoved = 0;
      if (request.options.moveTrackers) {
        trackersMoved = await _repointTrackers(request);
      }
      return MigrationResult(
        entry: entry,
        progressWritten: progressWritten,
        trackersMoved: trackersMoved,
        removedOld: removedOld,
        sourceName: request.target.config.name.trim(),
      );
    });
  }

  Future<int> _upsertConcrete(MigrationTarget target) async {
    final ConcreteDataTableData? existing = await _concreteByUid(target.uid);
    final String concreteJson = jsonEncode(target.concrete.toJson());
    if (existing != null) {
      await (database.update(database.concreteDataTable)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(ConcreteDataTableCompanion(
        extensionUid: Value<String>(target.extensionUid),
        title: Value<String>(target.concrete.title),
        cover: Value<String?>(target.concrete.cover),
        data: Value<String?>(target.encodedGalleryData),
        concreteJson: Value<String?>(concreteJson),
        updatedAt: Value<DateTime?>(DateTime.now()),
      ));
      return existing.id;
    }
    return database.into(database.concreteDataTable).insert(
          ConcreteDataTableCompanion.insert(
            uid: target.uid,
            extensionUid: target.extensionUid,
            title: target.concrete.title,
            cover: Value<String?>(target.concrete.cover),
            data: Value<String?>(target.encodedGalleryData),
            concreteJson: Value<String?>(concreteJson),
          ),
        );
  }

  Future<int> _writeProgress(MigrationProgressPlan plan, int concreteId) async {
    int written = 0;
    for (final MigrationProgressWrite write in plan.writes) {
      final bool changed;
      if (plan.kind == MigrationMediaKind.chapters) {
        changed = await _writeChapter(write, concreteId);
      } else {
        changed = await _writeEpisode(write, concreteId);
      }
      if (changed) {
        written++;
      }
    }
    return written;
  }

  Future<bool> _writeChapter(
    MigrationProgressWrite write,
    int concreteId,
  ) async {
    final ChapterActivityTableData? existing =
        await (database.select(database.chapterActivityTable)
              ..where((tbl) => tbl.uid.equals(write.target.uid)))
            .getSingleOrNull();
    if (existing != null) {
      final MigrationOldProgress current = MigrationOldProgress.fromChapter(
        ChapterActivityDomain.fromDrift(existing),
      );
      if (!write.progress.isAheadOf(current)) {
        return false;
      }
    }
    final ChapterActivityTableCompanion values = ChapterActivityTableCompanion(
      uid: Value<String>(write.target.uid),
      title: Value<String>(write.target.title),
      timestamp: Value<String?>(write.target.timestamp),
      data: Value<String?>(jsonEncode(write.target.data)),
      concreteId: Value<int>(concreteId),
      readPages: Value<int>(write.progress.readPages),
      totalPages: Value<int>(write.progress.totalPages),
    );
    if (existing == null) {
      await database.into(database.chapterActivityTable).insert(values);
      return true;
    }
    await (database.update(database.chapterActivityTable)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(values.copyWith(updatedAt: Value<DateTime?>(DateTime.now())));
    return true;
  }

  Future<bool> _writeEpisode(
    MigrationProgressWrite write,
    int concreteId,
  ) async {
    final AnimeEpisodeActivityTableData? existing =
        await (database.select(database.animeEpisodeActivityTable)
              ..where((tbl) => tbl.uid.equals(write.target.uid)))
            .getSingleOrNull();
    if (existing != null) {
      final MigrationOldProgress current = MigrationOldProgress.fromEpisode(
        AnimeEpisodeActivityDomain.fromDrift(existing),
      );
      if (!write.progress.isAheadOf(current)) {
        return false;
      }
    }
    final MigrationOldProgress progress = write.progress;
    final AnimeEpisodeActivityTableCompanion values =
        AnimeEpisodeActivityTableCompanion(
      uid: Value<String>(write.target.uid),
      title: Value<String>(write.target.title),
      timestamp: Value<String?>(write.target.timestamp),
      data: Value<String?>(jsonEncode(write.target.data)),
      concreteId: Value<int>(concreteId),
      watchedTime: Value<int?>(progress.watchedTime),
      totalTime: Value<int?>(progress.totalTime),
      markedWatched: Value<bool>(progress.markedWatched || progress.finished),
    );
    if (existing == null) {
      await database.into(database.animeEpisodeActivityTable).insert(values);
      return true;
    }
    await (database.update(database.animeEpisodeActivityTable)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(values.copyWith(updatedAt: Value<DateTime?>(DateTime.now())));
    return true;
  }

  Future<LibraryEntryDomain> _upsertEntry(
    MigrationRequest request,
    LibraryEntryTableData? oldEntry,
  ) async {
    final MigrationTarget target = request.target;
    final LibraryEntryTableData? existing = await _entryByUid(target.uid);
    final int? movedCategory =
        request.options.moveCategory ? oldEntry?.categoryId : null;
    if (existing != null) {
      final bool takeOldCategory = movedCategory != null;
      final int? category =
          takeOldCategory ? movedCategory : existing.categoryId;
      await (database.update(database.libraryEntryTable)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(LibraryEntryTableCompanion(
        extensionUid: Value<String>(target.extensionUid),
        title: Value<String>(target.concrete.title),
        cover: Value<String?>(target.concrete.cover),
        data: Value<String?>(target.encodedGalleryData),
        categoryId: Value<int?>(category),
        updatedAt: Value<DateTime?>(DateTime.now()),
      ));
      return _requireEntry(target.uid);
    }
    await database.into(database.libraryEntryTable).insert(
          LibraryEntryTableCompanion.insert(
            uid: target.uid,
            extensionUid: target.extensionUid,
            title: target.concrete.title,
            cover: Value<String?>(target.concrete.cover),
            data: Value<String?>(target.encodedGalleryData),
            categoryId: Value<int?>(movedCategory),
            lastReadAt: Value<DateTime?>(oldEntry?.lastReadAt),
            trackUpdates: Value<bool>(oldEntry?.trackUpdates ?? true),
            notifyUpdates: Value<bool>(oldEntry?.notifyUpdates ?? true),
            createdAt: Value<DateTime>(oldEntry?.createdAt ?? DateTime.now()),
          ),
        );
    return _requireEntry(target.uid);
  }

  Future<LibraryEntryDomain> _requireEntry(String uid) async {
    final LibraryEntryTableData? row = await _entryByUid(uid);
    if (row == null) {
      throw StateError('The library entry for $uid was not written');
    }
    return LibraryEntryDomain.fromDrift(row);
  }

  Future<bool> _removeOldEntry(String uid) async {
    final int removed = await (database.delete(database.libraryEntryTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .go();
    await (database.delete(database.libraryUpdateTable)
          ..where((tbl) => tbl.libraryEntryUid.equals(uid)))
        .go();
    return removed > 0;
  }

  Future<int> _repointTrackers(MigrationRequest request) async {
    final String oldUid = request.subject.uid;
    final MigrationTarget target = request.target;
    final List<TrackerLinkTableData> links =
        await (database.select(database.trackerLinkTable)
              ..where((tbl) => tbl.concreteUid.equals(oldUid)))
            .get();
    int moved = 0;
    for (final TrackerLinkTableData link in links) {
      final bool targetHasLink = !request.sameTitle &&
          await _hasLink(target.uid, link.trackerId);
      if (targetHasLink) {
        if (!request.options.keepOld) {
          await _deleteLink(oldUid, link.trackerId);
        }
        continue;
      }
      await (database.update(database.trackerLinkTable)
            ..where((tbl) =>
                tbl.concreteUid.equals(oldUid) &
                tbl.trackerId.equals(link.trackerId)))
          .write(TrackerLinkTableCompanion(
        concreteUid: Value<String>(target.uid),
        extensionUid: Value<String>(target.extensionUid),
      ));
      moved++;
    }
    return moved;
  }

  Future<bool> _hasLink(String concreteUid, String trackerId) async {
    final TrackerLinkTableData? row =
        await (database.select(database.trackerLinkTable)
              ..where((tbl) =>
                  tbl.concreteUid.equals(concreteUid) &
                  tbl.trackerId.equals(trackerId)))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> _deleteLink(String concreteUid, String trackerId) {
    return (database.delete(database.trackerLinkTable)
          ..where((tbl) =>
              tbl.concreteUid.equals(concreteUid) &
              tbl.trackerId.equals(trackerId)))
        .go();
  }
}
