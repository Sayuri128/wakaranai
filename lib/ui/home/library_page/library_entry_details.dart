import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_items_view.dart';

class LibraryEntryDetails {
  const LibraryEntryDetails({
    this.sourceName,
    this.status,
    this.lastOpened,
  });

  final String? sourceName;
  final String? status;
  final String? lastOpened;
}

class LibraryEntryDetailsLoader {
  LibraryEntryDetailsLoader({
    required this.extensionRepository,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
    required this.animeEpisodeActivityRepository,
  });

  final ExtensionRepository extensionRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;

  final Map<String, Future<ExtensionDomain?>> _extensions =
      <String, Future<ExtensionDomain?>>{};

  Future<ExtensionDomain?> _extensionFor(String extensionUid) async {
    return LocalSources.extensionFor(extensionUid) ??
        await extensionRepository.getByUid(extensionUid);
  }

  Future<LibraryEntryDetails> load(LibraryEntryDomain entry) async {
    final ExtensionDomain? extension = await _extensions.putIfAbsent(
      entry.extensionUid,
      () => _extensionFor(entry.extensionUid),
    );
    final ConcreteDataDomain? concrete = await concreteDataRepository.getByUid(
      entry.uid,
    );
    return LibraryEntryDetails(
      sourceName: extension?.config.name,
      status: _cachedStatus(concrete?.concreteJson),
      lastOpened: latestActivityTitle(
        await _activities(entry.uid, extension?.config.type),
      ),
    );
  }

  Future<List<BaseActivityDomain>?> _activities(
    String uid,
    ConfigInfoType? type,
  ) {
    if (type == ConfigInfoType.ANIME) {
      return animeEpisodeActivityRepository.getAllActivitiesByConcreteId(uid);
    }
    return chapterActivityRepository.getAllActivitiesByConcreteId(uid);
  }

  String? _cachedStatus(String? concreteJson) {
    if (concreteJson == null || concreteJson.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(concreteJson);
      if (decoded is Map<String, dynamic>) {
        final Object? status = decoded['status'];
        return status is String ? status : null;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
