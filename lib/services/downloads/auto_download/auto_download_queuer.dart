import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/services/downloads/auto_download/auto_download_policy.dart';
import 'package:wakaranai/services/downloads/queue/queued_download_rows.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

Future<AutoDownloadQueuer?> loadAutoDownloadQueuer({
  required DownloadRepository downloadRepository,
  AutoDownloadPreferences? preferences,
  bool reload = false,
  DownloadDirResolver? resolveDir,
}) async {
  final AutoDownloadSettings settings =
      await (preferences ?? AutoDownloadPreferences()).read(reload: reload);
  if (!settings.enabled) {
    return null;
  }
  return AutoDownloadQueuer(
    downloadRepository: downloadRepository,
    settings: settings,
    resolveDir: resolveDir,
  );
}

class AutoDownloadRequest {
  const AutoDownloadRequest({
    required this.entry,
    required this.config,
    required this.concreteView,
    required this.concreteId,
    required this.newUids,
  });

  final LibraryEntryDomain entry;
  final ConfigInfo config;
  final ConcreteView concreteView;
  final int concreteId;
  final Set<String> newUids;
}

class AutoDownloadQueuer {
  AutoDownloadQueuer({
    required DownloadRepository downloadRepository,
    required AutoDownloadSettings settings,
    DownloadDirResolver? resolveDir,
  })  : _downloads = downloadRepository,
        _policy = AutoDownloadPolicy(settings),
        _rows = QueuedDownloadRows(
          downloadRepository: downloadRepository,
          resolveDir: resolveDir,
        );

  final DownloadRepository _downloads;
  final AutoDownloadPolicy _policy;
  final QueuedDownloadRows _rows;

  Future<int> queueNewItems(AutoDownloadRequest request) {
    if (request.newUids.isEmpty || !_policy.appliesTo(request.entry)) {
      return Future<int>.value(0);
    }
    return runSerializedOn<int>(this, () => _queue(request));
  }

  Future<int> _queue(AutoDownloadRequest request) async {
    final List<ElementOfElementsGroupOfConcrete> candidates =
        _newItemsInReadingOrder(request);
    final List<ElementOfElementsGroupOfConcrete> picked = _policy.pick(
      candidates,
      keptUids: await _keptUidsOf(request.concreteView.uid),
    );
    final QueuedTitle title = QueuedTitle(
      extensionUid: request.config.uid,
      concreteUid: request.concreteView.uid,
      concreteId: request.concreteId,
      concreteTitle: request.concreteView.title,
      concreteCover: request.concreteView.cover,
    );
    int queued = 0;
    for (final ElementOfElementsGroupOfConcrete item in picked) {
      if (await _queueItem(title, item, request.config.type)) {
        queued++;
      }
    }
    return queued;
  }

  Future<bool> _queueItem(
    QueuedTitle title,
    ElementOfElementsGroupOfConcrete item,
    ConfigInfoType type,
  ) async {
    final DownloadDomain? existing = await _rows.existing(item.uid);
    if (QueuedDownloadRows.isPendingOrDone(existing)) {
      return false;
    }
    final DownloadDomain? row = await _rowFor(title, item, type, existing);
    if (row == null) {
      return false;
    }
    await _rows.save(row);
    return true;
  }

  Future<DownloadDomain?> _rowFor(
    QueuedTitle title,
    ElementOfElementsGroupOfConcrete item,
    ConfigInfoType type,
    DownloadDomain? existing,
  ) async {
    if (type == ConfigInfoType.ANIME) {
      if (item is! AnimeVideo) {
        return null;
      }
      return _rows.episodeRow(title: title, episode: item, existing: existing);
    }
    return _rows.chapterRow(
      title: title,
      chapterUid: item.uid,
      chapterTitle: item.title,
      data: item.data,
      kind: type == ConfigInfoType.NOVEL
          ? DownloadKind.novelChapter
          : DownloadKind.chapter,
    );
  }

  Future<Set<String>> _keptUidsOf(String concreteUid) async {
    final List<DownloadDomain> rows =
        await _downloads.getByConcreteUid(concreteUid);
    return <String>{
      for (final DownloadDomain row in rows)
        if (QueuedDownloadRows.isPendingOrDone(row)) row.uid,
    };
  }

  List<ElementOfElementsGroupOfConcrete> _newItemsInReadingOrder(
    AutoDownloadRequest request,
  ) {
    final List<ElementOfElementsGroupOfConcrete> items =
        <ElementOfElementsGroupOfConcrete>[];
    for (final ElementsGroupOfConcrete group in request.concreteView.groups) {
      for (final ElementOfElementsGroupOfConcrete element
          in _inReadingOrder(group.elements)) {
        if (request.newUids.contains(element.uid)) {
          items.add(element);
        }
      }
    }
    return items;
  }

  static List<ElementOfElementsGroupOfConcrete> _inReadingOrder(
    List<ElementOfElementsGroupOfConcrete> elements,
  ) {
    final List<AnimeVideo> episodes = elements.whereType<AnimeVideo>().toList();
    if (episodes.isEmpty || episodes.length != elements.length) {
      return elements;
    }
    return EpisodeGroupOrder(episodes).ascending;
  }
}
