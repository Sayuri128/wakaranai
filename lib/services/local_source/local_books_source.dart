import 'dart:io';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/content_kinds/content_kinds.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/services/local_source/local_book_library.dart';
import 'package:wakaranai/services/local_source/local_source.dart';

class LocalBooksSource {
  LocalBooksSource._();

  static const String uid = '9b3e6f12-58a4-4c7d-b1e9-2f6a0d4c8e73';
  static const String revision = 'local';

  static bool isLocal(String extensionUid) => extensionUid == uid;

  static ConfigInfo config(String name) {
    return ConfigInfo(
      name: name,
      uid: uid,
      logoUrl: '',
      nsfw: false,
      language: '',
      version: 1,
      filters: const [],
      type: ConfigInfoType.NOVEL,
      searchAvailable: true,
      contentKinds: const <String>[ContentKinds.novel],
    );
  }

  static ExtensionDomain extension(String name) {
    return ExtensionDomain(
      id: 0,
      config: config(name),
      sourceCode: '',
      revision: revision,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static Future<Directory> rootDirectory() async {
    final Directory local = await LocalSource.rootDirectory();
    return Directory(p.join(local.path, LocalSource.booksFolderName));
  }

  static Future<LocalBookLibrary> library() async {
    final Directory root = await rootDirectory();
    final Directory cache = Directory(
      p.join((await getApplicationCacheDirectory()).path, 'local_books'),
    );
    return LocalBookLibrary(root: root, cache: cache);
  }
}
