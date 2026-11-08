import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/extension_source_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/services/configs_service/extension_instances.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';
import 'package:wakaranai/utils/github_url_parser.dart';

typedef RemoteListingEntry = ({RemoteConfig remote, ConfigsService service});

class ExtensionResolver {
  ExtensionResolver({
    required this.extensionRepository,
    required this.extensionSourceRepository,
    this.officialOrg,
    this.officialRepo,
    Future<List<ConfigsService>> Function()? candidateServices,
  }) : _candidateServicesOverride = candidateServices;

  final ExtensionRepository extensionRepository;
  final ExtensionSourceRepository extensionSourceRepository;
  final String? officialOrg;
  final String? officialRepo;
  final Future<List<ConfigsService>> Function()? _candidateServicesOverride;

  Future<ExtensionDomain?> resolve(String uid) async {
    final ExtensionDomain? builtIn = LocalSources.extensionFor(uid);
    if (builtIn != null) {
      return builtIn;
    }
    final ExtensionDomain? cached = await extensionRepository.getByUid(uid);
    if (cached != null) return cached;
    return _downloadAndCache(uid);
  }

  Future<List<RemoteListingEntry>> listRemote() async {
    final List<List<RemoteListingEntry>> perService =
        await Future.wait((await _candidateServices()).map(_listingOf));
    return perService
        .expand((List<RemoteListingEntry> entries) => entries)
        .toList(growable: false);
  }

  Future<List<RemoteListingEntry>> _listingOf(ConfigsService service) async {
    try {
      return (await _remoteConfigs(service))
          .map((RemoteConfig remote) => (remote: remote, service: service))
          .toList(growable: false);
    } catch (e) {
      logger.w('Skipping an extension source while listing: $e');
      return const <RemoteListingEntry>[];
    }
  }

  Future<int> refreshOutdated() async {
    final List<ExtensionDomain> installed = await extensionRepository.getAll();
    if (installed.isEmpty) return 0;

    final Map<String, List<ExtensionDomain>> pending =
        <String, List<ExtensionDomain>>{};
    for (final ExtensionDomain extension in installed) {
      if (LocalSources.isBuiltIn(extension.config.uid)) {
        continue;
      }
      final String key = extension.baseUid ?? extension.config.uid;
      pending.putIfAbsent(key, () => <ExtensionDomain>[]).add(extension);
    }
    int refreshed = 0;

    for (final ConfigsService service in await _candidateServices()) {
      if (pending.isEmpty) break;
      final List<RemoteConfig> remotes;
      try {
        remotes = await _remoteConfigs(service);
      } catch (e) {
        logger.w('Skipping an extension source during update check: $e');
        continue;
      }

      for (final RemoteConfig remote in remotes) {
        final List<ExtensionDomain>? locals = pending.remove(remote.config.uid);
        if (locals == null) continue;
        final List<ExtensionDomain> outdated = locals
            .where((ExtensionDomain local) => isOutdated(local, remote))
            .toList(growable: false);
        if (outdated.isEmpty) continue;
        if (remote.compatibility.requiresNewerApp) {
          logger.i('Keeping ${remote.config.uid}: its update needs a newer app');
          continue;
        }
        try {
          final String script =
              (await service.getRemoteScript(remote.path)).script;
          for (final ExtensionDomain local in outdated) {
            await extensionRepository.createUpdateByUid(local.copyWith(
              config: _updatedConfig(local, remote.config),
              sourceCode: script,
              revision: remote.revision,
            ));
            refreshed++;
          }
        } catch (e) {
          logger.w('Failed to update extension ${remote.config.uid}: $e');
        }
      }
    }

    if (refreshed > 0) {
      logger.i('Updated $refreshed extension(s)');
    }
    return refreshed;
  }

  static ConfigInfo _updatedConfig(ExtensionDomain local, ConfigInfo remote) {
    if (!local.isInstance) {
      return remote;
    }
    return ExtensionInstances.instanceConfig(
      remote,
      uid: local.config.uid,
      name: local.config.name,
    );
  }

  static bool isOutdated(ExtensionDomain local, RemoteConfig remote) {
    final String? revision = remote.revision;
    if (revision != null) {
      return revision != local.revision;
    }
    return remote.config.version > local.config.version;
  }

  Future<ExtensionDomain?> _downloadAndCache(String uid) async {
    for (final ConfigsService service in await _candidateServices()) {
      try {
        final RemoteConfig? match = (await _remoteConfigs(service))
            .where((RemoteConfig e) => e.config.uid == uid)
            .firstOrNull;
        if (match == null) continue;
        if (match.compatibility.requiresNewerApp) {
          logger.w('Not installing $uid: it needs a newer app version');
          continue;
        }

        final String script =
            (await service.getRemoteScript(match.path)).script;

        return extensionRepository.createUpdateByUid(
          ExtensionDomain(
            id: 0,
            config: match.config,
            sourceCode: script,
            revision: match.revision,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, s) {
        logger.w('Failed to resolve extension $uid from a source: $e');
        logger.w(s);
      }
    }
    return null;
  }

  Future<List<RemoteConfig>> _remoteConfigs(ConfigsService service) async {
    final List<List<BaseExtension>> results =
        await Future.wait(<Future<List<BaseExtension>>>[
      service.getMangaConfigs(),
      service.getAnimeConfigs(),
      service.getNovelConfigs(),
      service.getAudioConfigs(),
    ]);
    return results
        .expand((List<BaseExtension> e) => e)
        .whereType<RemoteConfig>()
        .toList();
  }

  Future<List<ConfigsService>> _candidateServices() async {
    final Future<List<ConfigsService>> Function()? override =
        _candidateServicesOverride;
    if (override != null) return override();

    final List<ConfigsService> services = <ConfigsService>[];
    final Set<String> seen = <String>{};

    void addGithub(String org, String repo, {String? branch}) {
      if (org.isEmpty || repo.isEmpty) return;
      if (seen.add('$org/$repo'.toLowerCase())) {
        services.add(GitHubConfigsService(org, repo, branch: branch));
      }
    }

    for (final ExtensionSourceDomain source
        in await extensionSourceRepository.getAll()) {
      final parsed = GithubUrlParser(url: source.url).parse();
      if (parsed != null) {
        addGithub(parsed.org, parsed.repo, branch: source.ref);
      }
    }

    final String? org = officialOrg ?? _envOrNull(() => Env.configsSourceOrg);
    final String? repo =
        officialRepo ?? _envOrNull(() => Env.configsSourceRepo);
    if (org != null && repo != null) {
      addGithub(org, repo);
    }
    return services;
  }

  static String? _envOrNull(String Function() read) {
    try {
      return read();
    } catch (_) {
      return null;
    }
  }
}
