import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/services/configs_service/prepared_client_pool.dart';
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
  final int checked;
  final int failed;

  const LibraryUpdateCheckResult({
    this.updates = const <LibraryUpdateDomain>[],
    this.notifiable = const <LibraryUpdateDomain>[],
    this.checked = 0,
    this.failed = 0,
  });
}

typedef ConcreteViewFetcher = Future<ConcreteView<dynamic>> Function(
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
  });

  final LibraryEntryRepository libraryEntryRepository;
  final LibraryUpdateRepository libraryUpdateRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ExtensionRepository extensionRepository;
  final ConcreteViewFetcher? fetcher;

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
    int checked = 0;
    int failed = 0;

    onProgress?.call(
        LibraryUpdateProgress(processed: 0, total: entries.length));

    final Map<String, List<LibraryEntryDomain>> byExtension =
        <String, List<LibraryEntryDomain>>{};
    for (final LibraryEntryDomain entry in entries) {
      byExtension
          .putIfAbsent(entry.extensionUid, () => <LibraryEntryDomain>[])
          .add(entry);
    }

    Future<void> runGroup(List<LibraryEntryDomain> group) async {
      for (final LibraryEntryDomain entry in group) {
        try {
          final List<LibraryUpdateDomain> found = await _checkEntry(entry);
          updates.addAll(found);
          if (entry.notifyUpdates) {
            notifiable.addAll(found);
          }
          checked++;
        } catch (e) {
          failed++;
          logger.w('Update check failed for ${entry.title}: $e');
        }

        onProgress?.call(LibraryUpdateProgress(
          processed: checked + failed,
          total: entries.length,
          title: entry.title,
        ));
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
      checked: checked,
      failed: failed,
    );
  }

  Future<List<LibraryUpdateDomain>> _checkEntry(LibraryEntryDomain entry) async {
    final ExtensionDomain? extension =
        await extensionRepository.getByUid(entry.extensionUid);
    if (extension == null) {
      throw Exception('Extension ${entry.extensionUid} is not cached');
    }

    final ConfigInfo config = extension.config;

    final ConcreteView<dynamic> concreteView = await (fetcher != null
            ? fetcher!(extension, entry)
            : _fetchViaClient(extension, entry))
        .timeout(_entryTimeout);

    final ConcreteDataDomain? cached =
        await concreteDataRepository.getByUid(entry.uid);

    if (cached?.concreteJson == null) {
      await _saveSnapshot(entry, concreteView, config);
      return const <LibraryUpdateDomain>[];
    }

    final Set<String>? knownUids = _elementUidsFromJson(cached!.concreteJson!);

    if (knownUids == null) {
      await _saveSnapshot(entry, concreteView, config);
      return const <LibraryUpdateDomain>[];
    }

    final Set<String> recordedUids =
        await libraryUpdateRepository.getUidsForEntry(entry.uid);

    final UpdateMediaType mediaType = config.type == ConfigInfoType.ANIME
        ? UpdateMediaType.anime
        : UpdateMediaType.manga;

    final List<LibraryUpdateDomain> found = <LibraryUpdateDomain>[];

    for (final dynamic group in concreteView.groups) {
      for (final dynamic element in group.elements as List<dynamic>) {
        final String uid = element.uid as String;
        if (knownUids.contains(uid) || recordedUids.contains(uid)) continue;

        final LibraryUpdateDomain update = LibraryUpdateDomain(
          id: 0,
          uid: uid,
          libraryEntryUid: entry.uid,
          extensionUid: entry.extensionUid,
          title: element.title as String,
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

    await _saveSnapshot(entry, concreteView, config);

    return found;
  }

  Future<void> _saveSnapshot(
    LibraryEntryDomain entry,
    ConcreteView<dynamic> concreteView,
    ConfigInfo config,
  ) async {
    await concreteDataRepository.createUpdateBy<$ConcreteDataTableTable, String>(
      concreteView.toConcreteDataDomain(
        data: entry.dataJson,
        extensionUid: config.uid,
        concreteJson: jsonEncode((concreteView as dynamic).toJson()),
      ),
      by: (ConcreteDataDomain domain) => domain.uid,
      where: ($ConcreteDataTableTable tbl) => tbl.uid,
    );
  }

  Future<ConcreteView<dynamic>> _fetchViaClient(
    ExtensionDomain extension,
    LibraryEntryDomain entry,
  ) async {
    final ApiClient client = await _clientFor(extension);

    return await (client as dynamic).getConcrete(
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
