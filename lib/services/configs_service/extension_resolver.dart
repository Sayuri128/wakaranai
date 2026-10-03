import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/extension_source_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/utils/github_url_parser.dart';

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
    final ExtensionDomain? cached = await extensionRepository.getByUid(uid);
    if (cached != null) return cached;
    return _downloadAndCache(uid);
  }

  Future<int> refreshOutdated() async {
    final List<ExtensionDomain> installed = await extensionRepository.getAll();
    if (installed.isEmpty) return 0;

    final Map<String, ExtensionDomain> pending = <String, ExtensionDomain>{
      for (final ExtensionDomain extension in installed)
        extension.config.uid: extension,
    };
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
        final ExtensionDomain? local = pending.remove(remote.config.uid);
        if (local == null || !isOutdated(local, remote)) continue;
        try {
          final String script =
              (await service.getRemoteScript(remote.path)).script;
          await extensionRepository.createUpdateByUid(local.copyWith(
            config: remote.config,
            sourceCode: script,
            revision: remote.revision,
          ));
          refreshed++;
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
