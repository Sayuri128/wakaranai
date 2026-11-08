import 'dart:io';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/content_kinds/content_kinds.dart';
import 'package:capyscript/modules/waka_models/models/config_info/source_type/source_type.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/services/local_source/local_library.dart';

class LocalSource {
  LocalSource._();

  static const String uid = '4d0c7a51-6f3b-4b8e-9c2a-5e1d0f7a3b21';
  static const String revision = 'local';
  static const String folderName = 'Local';
  static const String booksFolderName = 'Books';

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
      type: ConfigInfoType.MANGA,
      searchAvailable: true,
      contentKinds: const <String>[ContentKinds.manga],
      sourceType: SourceType.local,
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
    final Directory? external =
        Platform.isAndroid ? await getExternalStorageDirectory() : null;
    final Directory base = external ?? await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, folderName));
  }

  static Future<LocalLibrary> library() async {
    final Directory root = await rootDirectory();
    final Directory cache = Directory(
      p.join((await getApplicationCacheDirectory()).path, 'local_source'),
    );
    return LocalLibrary(
      root: root,
      cache: cache,
      reservedFolders: const <String>{booksFolderName},
    );
  }
}
