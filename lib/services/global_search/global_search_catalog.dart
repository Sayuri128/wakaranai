import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/configs_view_options.dart';

class GlobalSearchCatalogSnapshot {
  const GlobalSearchCatalogSnapshot({
    required this.sources,
    required this.pinned,
    required this.used,
  });

  final List<GlobalSearchSource> sources;
  final List<String> pinned;
  final Set<String> used;
}

abstract class GlobalSearchCatalog {
  Future<GlobalSearchCatalogSnapshot> loadKnown();

  Future<List<GlobalSearchSource>> loadAllRepositories();
}

class RepositoryGlobalSearchCatalog implements GlobalSearchCatalog {
  RepositoryGlobalSearchCatalog({
    required this.extensionRepository,
    required this.libraryEntryRepository,
    required this.resolver,
    this.remoteConfigsCubit,
  });

  final ExtensionRepository extensionRepository;
  final LibraryEntryRepository libraryEntryRepository;
  final ExtensionResolver resolver;
  final RemoteConfigsCubit? remoteConfigsCubit;

  @override
  Future<GlobalSearchCatalogSnapshot> loadKnown() async {
    final List<ExtensionDomain> installed = await extensionRepository.getAll();
    final Set<String> used = <String>{
      for (final ExtensionDomain extension in installed) extension.config.uid,
      ...await _libraryExtensionUids(),
    };
    return GlobalSearchCatalogSnapshot(
      sources: <GlobalSearchSource>[
        for (final ExtensionDomain extension in LocalSources.all())
          GlobalSearchSource(extension: extension),
        for (final ExtensionDomain extension in installed)
          if (!LocalSources.isBuiltIn(extension.config.uid))
            GlobalSearchSource(extension: extension),
        ..._currentListing(),
      ],
      pinned: await ConfigsViewOptionsCubit.readPinned(),
      used: used,
    );
  }

  Future<Set<String>> _libraryExtensionUids() async {
    try {
      final List<LibraryEntryDomain> entries =
          await libraryEntryRepository.getAll();
      return entries
          .map((LibraryEntryDomain entry) => entry.extensionUid)
          .toSet();
    } catch (e) {
      logger.w('Failed to read library sources for global search: $e');
      return <String>{};
    }
  }

  List<GlobalSearchSource> _currentListing() {
    final RemoteConfigsCubit? cubit = remoteConfigsCubit;
    if (cubit == null) {
      return const <GlobalSearchSource>[];
    }
    final RemoteConfigsState state = cubit.state;
    if (state is! RemoteConfigsLoaded) {
      return const <GlobalSearchSource>[];
    }
    final ConfigsService service = cubit.configService;
    return <BaseExtension>[
      ...state.mangaRemoteConfigs,
      ...state.animeRemoteConfigs,
      ...state.novelRemoteConfigs,
    ]
        .map((BaseExtension extension) => GlobalSearchSource(
              extension: extension,
              configsService: service,
            ))
        .toList(growable: false);
  }

  @override
  Future<List<GlobalSearchSource>> loadAllRepositories() async {
    final List<RemoteListingEntry> entries = await resolver.listRemote();
    return entries
        .map((RemoteListingEntry entry) => GlobalSearchSource(
              extension: entry.remote,
              configsService: entry.service,
            ))
        .toList(growable: false);
  }
}
