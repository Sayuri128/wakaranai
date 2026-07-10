import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:dio/dio.dart';
import 'package:wakaranai/data/models/github/payload/tree/item/github_tree_item_model.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/services/configs_service/capyscript_import_bundler.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';

class GitHubConfigsService implements ConfigsService {
  static const String _branch = 'feature/sessionGroup';
  static const String _mangaDirectory = 'manga';
  static const String _animeDirectory = 'anime';
  static const String _indexPath = 'index.json';

  final String org;
  final String repository;

  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (_) => true,
      headers: <String, String>{
        'accept': 'application/vnd.github+json',
      },
    ),
  );

  Future<List<RemoteConfig>>? _configsFuture;

  GitHubConfigsService(this.org, this.repository);

  @override
  Future<List<RemoteConfig>> getMangaConfigs() async {
    final List<RemoteConfig> configs = await _loadConfigs();
    return configs
        .where((RemoteConfig e) => e.config.type == ConfigInfoType.MANGA)
        .toList();
  }

  @override
  Future<List<RemoteConfig>> getAnimeConfigs() async {
    final List<RemoteConfig> configs = await _loadConfigs();
    return configs
        .where((RemoteConfig e) => e.config.type == ConfigInfoType.ANIME)
        .toList();
  }

  Future<List<RemoteConfig>> _loadConfigs() {
    final Future<List<RemoteConfig>>? existing = _configsFuture;
    if (existing != null) {
      return existing;
    }

    final Future<List<RemoteConfig>> future = _fetchConfigs();
    _configsFuture = future;
    future.catchError((Object _) {
      _configsFuture = null;
      return <RemoteConfig>[];
    });
    return future;
  }

  Future<List<RemoteConfig>> _fetchConfigs() async {
    final Response<String> response = await _dio.get<String>(
      'https://raw.githubusercontent.com/$org/$repository/$_branch/$_indexPath',
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode == 404) {
      return _fetchConfigsFromDirectories();
    }

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Failed to load $_indexPath from $org/$repository',
      );
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.data!) as Map<String, dynamic>;

    return (decoded['configs'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(RemoteConfig.fromJson)
        .toList();
  }

  Future<List<RemoteConfig>> _fetchConfigsFromDirectories() async {
    final List<List<RemoteConfig>> categories = await Future.wait(
      <Future<List<RemoteConfig>>>[
        _getDirectoryConfigs(_mangaDirectory, 'manga'),
        _getDirectoryConfigs(_animeDirectory, 'anime'),
      ],
    );
    return categories.expand((List<RemoteConfig> e) => e).toList();
  }

  Future<List<RemoteConfig>> _getDirectoryConfigs(
    String directory,
    String category,
  ) async {
    final List<GithubTreeItemModel> directories =
        await _getDirectories(directory);

    return Future.wait(
      directories.map((GithubTreeItemModel e) async {
        return await _getConfig(
          treeItem: e,
          directory: directory,
          category: category,
        );
      }),
    );
  }

  Future<RemoteConfig> _getConfig({
    required GithubTreeItemModel treeItem,
    required String directory,
    required String category,
  }) async {
    final String config = await _getRawContent(
      '$directory/${treeItem.name}/config.json',
    );

    return RemoteConfig.fromJson(
      <String, dynamic>{
        "category": category,
        "path": '$directory/${treeItem.name}',
        "config": jsonDecode(config),
      },
    );
  }

  Future<List<GithubTreeItemModel>> _getDirectories(
    String directory,
  ) async {
    final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
      'https://api.github.com/repos/$org/$repository/contents/$directory',
      queryParameters: <String, dynamic>{'ref': _branch},
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Failed to load GitHub directory $directory from $org/$repository',
      );
    }

    return response.data!
        .whereType<Map<String, dynamic>>()
        .where((Map<String, dynamic> item) => item['type'] == 'dir')
        .map((Map<String, dynamic> item) => GithubTreeItemModel(
              name: item['name'] as String,
              path: item['path'] as String,
              contentType: 'directory',
            ))
        .toList();
  }

  @override
  Future<RemoteScript> getRemoteScript(String path) async {
    final String scriptPath = "$path/main.capyscript";
    return CapyscriptImportBundler.bundle(
      entryPath: scriptPath,
      fetchScript: (String concretePath) async => RemoteScript(
        path: concretePath,
        script: await _getRawContent(concretePath),
      ),
    );
  }

  Future<String> _getRawContent(String path) async {
    final Response<String> response = await _dio.get<String>(
      'https://raw.githubusercontent.com/$org/$repository/$_branch/$path',
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Failed to load GitHub file $path from $org/$repository',
      );
    }

    return response.data!;
  }
}
