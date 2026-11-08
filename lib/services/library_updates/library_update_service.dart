import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';
import 'package:wakaranai/services/configs_service/session_failure_classifier.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/repositories/database/library_update_repository.dart';
import 'package:wakaranai/services/downloads/auto_download/auto_download_queuer.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';

class LibraryUpdateProgress {
  final int processed;
  final int total;
  final String? title;

  const LibraryUpdateProgress({
    required this.processed,
    required this.total,
    this.title,
  });
}

class LibraryUpdateCheckResult {
  final List<LibraryUpdateDomain> updates;
  final List<LibraryUpdateDomain> notifiable;
  final List<SourceNeedsAttention> needsAttention;
  final List<LibraryEntryDomain> removedFromSource;
  final Map<String, int> autoQueuedByEntry;
  final int checked;
  final int failed;
  final int skipped;

  const LibraryUpdateCheckResult({
    this.updates = const <LibraryUpdateDomain>[],
    this.notifiable = const <LibraryUpdateDomain>[],
    this.needsAttention = const <SourceNeedsAttention>[],
    this.removedFromSource = const <LibraryEntryDomain>[],
    this.autoQueuedByEntry = const <String, int>{},
    this.checked = 0,
    this.failed = 0,
    this.skipped = 0,
  });

  int get autoQueued => autoQueuedByEntry.values.fold<int>(
        0,
        (int total, int count) => total + count,
      );
}

class _EntryCheck {
  const _EntryCheck(this.found, {this.autoQueued = 0});

  static const _EntryCheck nothing = _EntryCheck(<LibraryUpdateDomain>[]);

  final List<LibraryUpdateDomain> found;
  final int autoQueued;
}

enum UpdateFailureKind { transient, removedFromSource, unavailable, failed }

class UpdateFailureClassifier {
  const UpdateFailureClassifier._();

  static UpdateFailureKind classify(Object error) {
    final SourceError? sourceError =
        SessionFailureClassifier.sourceErrorIn(error);
    if (sourceError == null) {
      return UpdateFailureKind.failed;
    }
    switch (sourceError.kind) {
      case SourceErrorKind.sourceDown:
      case SourceErrorKind.rateLimited:
        return UpdateFailureKind.transient;
      case SourceErrorKind.notFound:
        return UpdateFailureKind.removedFromSource;
      case SourceErrorKind.loginRequired:
      case SourceErrorKind.regionBlocked:
      case SourceErrorKind.unsupported:
        return UpdateFailureKind.unavailable;
    }
  }
}

typedef ConcreteViewFetcher = Future<ConcreteView> Function(
  ExtensionDomain extension,
  LibraryEntryDomain entry,
);

class LibraryUpdateService {
  LibraryUpdateService({
    required this.libraryEntryRepository,
    required this.libraryUpdateRepository,
    required this.concreteDataRepository,
    required this.extensionRepository,
    this.fetcher,
    this.autoDownloads,
  });

  final LibraryEntryRepository libraryEntryRepository;
  final LibraryUpdateRepository libraryUpdateRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ExtensionRepository extensionRepository;
  final ConcreteViewFetcher? fetcher;
  final AutoDownloadQueuer? autoDownloads;

  static const Duration _entryTimeout = Duration(seconds: 90);
  static const int _maxConcurrentExtensions = 3;

  final PreparedClientPool _clients = PreparedClientPool();

  Future<LibraryUpdateCheckResult> check({
    void Function(LibraryUpdateProgress progress)? onProgress,
  }) async {
    final List<LibraryEntryDomain> entries =
        (await libraryEntryRepository.getAll())
            .where((LibraryEntryDomain e) => e.trackUpdates)
            .toList();

    final List<LibraryUpdateDomain> updates = <LibraryUpdateDomain>[];
    final List<LibraryUpdateDomain> notifiable = <LibraryUpdateDomain>[];
    final Map<String, SourceNeedsAttention> attentionBySession =
        <String, SourceNeedsAttention>{};
    final List<LibraryEntryDomain> removedFromSource = <LibraryEntryDomain>[];
    final Map<String, int> autoQueuedByEntry = <String, int>{};
    int checked = 0;
    int failed = 0;
    int skipped = 0;

    onProgress?.call(
        LibraryUpdateProgress(processed: 0, total: entries.length));

    final Map<String, List<LibraryEntryDomain>> byExtension =
        <String, List<LibraryEntryDomain>>{};
    for (final LibraryEntryDomain entry in entries) {
      byExtension
          .putIfAbsent(entry.extensionUid, () => <LibraryEntryDomain>[])
          .add(entry);
    }

    void reportProgress(LibraryEntryDomain entry) {
      onProgress?.call(LibraryUpdateProgress(
        processed: checked + failed + skipped + removedFromSource.length,
        total: entries.length,
        title: entry.title,
      ));
    }

    Future<void> runGroup(List<LibraryEntryDomain> group) async {
      final ExtensionDomain? extension =
          await extensionRepository.getByUid(group.first.extensionUid);
      final String? sessionKey = _sessionKeyOf(extension);
      bool sourceUnreachable = false;

      for (final LibraryEntryDomain entry in group) {
        if (sessionKey != null && attentionBySession.containsKey(sessionKey)) {
          skipped++;
          reportProgress(entry);
          continue;
        }
        if (sourceUnreachable) {
          skipped++;
          reportProgress(entry);
          continue;
        }

        try {
          final _EntryCheck result = await _checkEntry(entry, extension);
          updates.addAll(result.found);
          if (entry.notifyUpdates) {
            notifiable.addAll(result.found);
          }
          if (result.autoQueued > 0) {
            autoQueuedByEntry[entry.uid] = result.autoQueued;
          }
          checked++;
        } on SourceNeedsAttention catch (attention) {
          failed++;
          attentionBySession.putIfAbsent(attention.sessionKey, () => attention);
          logger.w('Update check needs the user for ${entry.title}: '
              '$attention');
        } catch (e) {
          switch (UpdateFailureClassifier.classify(e)) {
            case UpdateFailureKind.transient:
              failed++;
              sourceUnreachable = true;
              logger.w('Update check for ${entry.extensionUid} paused this '
                  'run, the source is temporarily unavailable: $e');
            case UpdateFailureKind.removedFromSource:
              removedFromSource.add(entry);
              logger.w('${entry.title} was removed from its source: $e');
            case UpdateFailureKind.unavailable:
              skipped++;
              logger.i('Skipped the update check for ${entry.title}: $e');
            case UpdateFailureKind.failed:
              failed++;
              logger.w('Update check failed for ${entry.title}: $e');
          }
        }

        reportProgress(entry);
      }
    }

    try {
      final List<List<LibraryEntryDomain>> groups =
          byExtension.values.toList();

      for (int i = 0; i < groups.length; i += _maxConcurrentExtensions) {
        final int end =
            (i + _maxConcurrentExtensions).clamp(0, groups.length);
        await Future.wait(groups.sublist(i, end).map(runGroup));
      }
    } finally {
      await dispose();
    }

    return LibraryUpdateCheckResult(
      updates: updates,
      notifiable: notifiable,
      needsAttention: attentionBySession.values.toList(),
      removedFromSource: removedFromSource,
      autoQueuedByEntry: autoQueuedByEntry,
      checked: checked,
      failed: failed,
      skipped: skipped,
    );
  }

  String? _sessionKeyOf(ExtensionDomain? extension) {
    if (extension == null || extension.config.protectorConfig == null) {
      return null;
    }
    return ProtectorStorageService.sessionKey(extension.config);
  }

  Future<_EntryCheck> _checkEntry(
    LibraryEntryDomain entry,
    ExtensionDomain? extension,
  ) async {
    if (extension == null) {
      throw Exception('Extension ${entry.extensionUid} is not cached');
    }

    final ConfigInfo config = extension.config;

    final ConcreteView concreteView =
        await _fetchClassified(extension, entry);

    final ConcreteDataDomain? cached =
        await concreteDataRepository.getByUid(entry.uid);

    if (cached?.concreteJson == null) {
      await _saveSnapshot(entry, concreteView, config);
      return _EntryCheck.nothing;
    }

    final Set<String>? knownUids = _elementUidsFromJson(cached!.concreteJson!);

    if (knownUids == null) {
      await _saveSnapshot(entry, concreteView, config);
      return _EntryCheck.nothing;
    }

    final Set<String> recordedUids =
        await libraryUpdateRepository.getUidsForEntry(entry.uid);

    final UpdateMediaType mediaType = config.type == ConfigInfoType.ANIME
        ? UpdateMediaType.anime
        : UpdateMediaType.manga;

    final List<LibraryUpdateDomain> found = <LibraryUpdateDomain>[];

    for (final ElementsGroupOfConcrete group in concreteView.groups) {
      for (final ElementOfElementsGroupOfConcrete element in group.elements) {
        final String uid = element.uid;
        if (knownUids.contains(uid) || recordedUids.contains(uid)) continue;

        final LibraryUpdateDomain update = LibraryUpdateDomain(
          id: 0,
          uid: uid,
          libraryEntryUid: entry.uid,
          extensionUid: entry.extensionUid,
          title: element.title,
          concreteTitle: entry.title,
          concreteCover: entry.cover,
          mediaType: mediaType,
          data: jsonEncode(element.data),
          createdAt: DateTime.now(),
        );

        final LibraryUpdateDomain? created =
            await libraryUpdateRepository.create(update);
        if (created != null) {
          found.add(created);
          recordedUids.add(uid);
        }
      }
    }

    final ConcreteDataDomain? saved =
        await _saveSnapshot(entry, concreteView, config);

    final int autoQueued = await _queueAutoDownloads(
      entry: entry,
      config: config,
      concreteView: concreteView,
      saved: saved,
      found: found,
    );

    return _EntryCheck(found, autoQueued: autoQueued);
  }

  Future<int> _queueAutoDownloads({
    required LibraryEntryDomain entry,
    required ConfigInfo config,
    required ConcreteView concreteView,
    required ConcreteDataDomain? saved,
    required List<LibraryUpdateDomain> found,
  }) async {
    final AutoDownloadQueuer? queuer = autoDownloads;
    if (queuer == null || saved == null || found.isEmpty) {
      return 0;
    }
    try {
      return await queuer.queueNewItems(AutoDownloadRequest(
        entry: entry,
        config: config,
        concreteView: concreteView,
        concreteId: saved.id,
        newUids: found.map((LibraryUpdateDomain update) => update.uid).toSet(),
      ));
    } catch (e, s) {
      logger.w('Could not queue automatic downloads for ${entry.title}: $e');
      logger.w(s);
      return 0;
    }
  }

  Future<ConcreteDataDomain?> _saveSnapshot(
    LibraryEntryDomain entry,
    ConcreteView concreteView,
    ConfigInfo config,
  ) {
    return concreteDataRepository
        .createUpdateBy<$ConcreteDataTableTable, String>(
      concreteView.toConcreteDataDomain(
        data: entry.dataJson,
        extensionUid: config.uid,
        concreteJson: jsonEncode(concreteView.toJson()),
      ),
      by: (ConcreteDataDomain domain) => domain.uid,
      where: ($ConcreteDataTableTable tbl) => tbl.uid,
    );
  }

  Future<ConcreteView> _fetchClassified(
    ExtensionDomain extension,
    LibraryEntryDomain entry,
  ) async {
    final String extensionUid = extension.config.uid;
    final int challengesBefore = _clients.challengeCount(extensionUid);
    try {
      return await _fetch(extension, entry).timeout(_entryTimeout);
    } catch (error) {
      final SourceNeedsAttention? attention = SessionFailureClassifier.classify(
        error,
        extension.config,
        challengeObserved:
            _clients.challengeCount(extensionUid) > challengesBefore,
      );
      if (attention != null) {
        throw attention;
      }
      rethrow;
    }
  }

  Future<ConcreteView> _fetch(
    ExtensionDomain extension,
    LibraryEntryDomain entry,
  ) {
    final ConcreteViewFetcher? injected = fetcher;
    if (injected != null) {
      return injected(extension, entry);
    }
    return _fetchViaClient(extension, entry);
  }

  Future<ConcreteView> _fetchViaClient(
    ExtensionDomain extension,
    LibraryEntryDomain entry,
  ) async {
    final ApiClient client = await _clientFor(extension);

    return await client.getConcrete(
      uid: entry.uid,
      data: entry.dataJson,
    );
  }

  Future<ApiClient> _clientFor(ExtensionDomain extension) {
    return _clients.clientFor(extension);
  }

  Future<void> dispose() {
    return _clients.dispose();
  }

  Set<String>? _elementUidsFromJson(String rawJson) {
    final Set<String> uids = <String>{};
    try {
      final Map<String, dynamic> json =
          jsonDecode(rawJson) as Map<String, dynamic>;
      final List<dynamic> groups = json['groups'] as List<dynamic>? ?? const [];
      for (final dynamic group in groups) {
        final List<dynamic> elements =
            (group as Map<String, dynamic>)['elements'] as List<dynamic>? ??
                const [];
        for (final dynamic element in elements) {
          final Object? uid = (element as Map<String, dynamic>)['uid'];
          if (uid is String) uids.add(uid);
        }
      }
    } catch (e) {
      logger.w('Failed to parse cached concrete snapshot: $e');
      return null;
    }
    return uids;
  }
}
