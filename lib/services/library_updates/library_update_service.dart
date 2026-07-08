import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
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

  static const Duration _interceptorTimeout = Duration(seconds: 30);

  final Map<String, Future<ApiClient>> _clients = <String, Future<ApiClient>>{};
  final Map<String, BrowserInterceptorCubit> _interceptors =
      <String, BrowserInterceptorCubit>{};

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

    try {
      for (final LibraryEntryDomain entry in entries) {
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

    final ConcreteView<dynamic> concreteView = fetcher != null
        ? await fetcher!(extension, entry)
        : await _fetchViaClient(extension, entry);

    final ConcreteDataDomain? cached =
        await concreteDataRepository.getByUid(entry.uid);

    if (cached?.concreteJson == null) {
      await _saveSnapshot(entry, concreteView, config);
      return const <LibraryUpdateDomain>[];
    }

    final Set<String> knownUids = _elementUidsFromJson(cached!.concreteJson!);
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
    return _clients.putIfAbsent(
      extension.config.uid,
      () => _buildAndPrepareClient(extension),
    );
  }

  Future<ApiClient> _buildAndPrepareClient(ExtensionDomain extension) async {
    late final ApiClient client;
    switch (extension.config.type) {
      case ConfigInfoType.ANIME:
        client = AnimeApiClient(code: extension.sourceCode);
        break;
      case ConfigInfoType.MANGA:
        client = MangaApiClient(code: extension.sourceCode);
        break;
    }

    await _prepareClient(client, extension.config);
    return client;
  }

  Future<void> _prepareClient(ApiClient client, ConfigInfo config) async {
    final ProtectorConfig? protector = config.protectorConfig;
    if (protector == null) return;

    if (protector.inAppBrowserInterceptor) {
      final Completer<bool> ready = Completer<bool>();
      final BrowserInterceptorCubit interceptor = BrowserInterceptorCubit()
        ..init(url: protector.pingUrl, initCompleter: ready);
      _interceptors[config.uid] = interceptor;

      await client.passWebBrowserInterceptorController(controller: interceptor);
      await ready.future.timeout(_interceptorTimeout);
    }

    final ProtectorStorageItem? stored =
        await ProtectorStorageService().getItemForConfig(config);

    if (stored == null) {
      throw Exception('Protector for ${config.name} has not been passed yet');
    }

    await client.passProtector(
      cookies: stored.data.cookies,
      headers: stored.data.headers,
      body: stored.data.body,
    );
  }

  Future<void> dispose() async {
    for (final BrowserInterceptorCubit interceptor in _interceptors.values) {
      try {
        await interceptor.close();
      } catch (e) {
        logger.w('Failed to close browser interceptor: $e');
      }
    }
    _interceptors.clear();
    _clients.clear();
  }

  Set<String> _elementUidsFromJson(String rawJson) {
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
    }
    return uids;
  }
}
