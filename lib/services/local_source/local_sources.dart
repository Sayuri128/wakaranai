import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_source.dart';

class LocalSources {
  LocalSources._();

  static bool isBuiltIn(String extensionUid) {
    return LocalSource.isLocal(extensionUid) ||
        LocalBooksSource.isLocal(extensionUid);
  }

  static bool supportsDownloads(String extensionUid) {
    return !LocalBooksSource.isLocal(extensionUid);
  }

  static ExtensionDomain? extensionFor(String extensionUid) {
    if (LocalSource.isLocal(extensionUid)) {
      return LocalSource.extension(S.current.local_source_name);
    }
    if (LocalBooksSource.isLocal(extensionUid)) {
      return LocalBooksSource.extension(S.current.local_books_name);
    }
    return null;
  }

  static List<ExtensionDomain> all() {
    return <ExtensionDomain>[
      LocalSource.extension(S.current.local_source_name),
      LocalBooksSource.extension(S.current.local_books_name),
    ];
  }
}
