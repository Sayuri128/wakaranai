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
  });

  final ExtensionRepository extensionRepository;
  final ExtensionSourceRepository extensionSourceRepository;

  Future<ExtensionDomain?> resolve(String uid) async {
    final ExtensionDomain? cached = await extensionRepository.getByUid(uid);
    if (cached != null) return cached;
    return _downloadAndCache(uid);
  }

  Future<ExtensionDomain?> _downloadAndCache(String uid) async {
    for (final ConfigsService service in await _candidateServices()) {
      try {
        final RemoteConfig? match = await _findConfig(service, uid);
        if (match == null) continue;

        final String script =
            (await service.getRemoteScript(match.path)).script;

        return extensionRepository.createUpdateByUid(
          ExtensionDomain(
            id: 0,
            config: match.config,
            sourceCode: script,
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

  Future<RemoteConfig?> _findConfig(ConfigsService service, String uid) async {
    final List<List<BaseExtension>> results =
        await Future.wait(<Future<List<BaseExtension>>>[
      service.getMangaConfigs(),
      service.getAnimeConfigs(),
    ]);

    for (final List<BaseExtension> list in results) {
      for (final BaseExtension extension in list) {
        if (extension is RemoteConfig && extension.config.uid == uid) {
          return extension;
        }
      }
    }
    return null;
  }

  Future<List<ConfigsService>> _candidateServices() async {
    final List<ConfigsService> services = <ConfigsService>[];
    final Set<String> seen = <String>{};

    void addGithub(String org, String repo, {String? branch}) {
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

    addGithub(Env.configsSourceOrg, Env.configsSourceRepo);
    return services;
  }
}
