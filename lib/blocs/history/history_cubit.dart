import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/data/history_manga_group/history_manga_group.dart';
import 'package:wakaranai/models/data/history_manga_item/history_manga_item.dart';
import 'package:wakaranai/services/history_service/manga_history_service.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial()) {
    historyService = HistoryService();
  }

  late final HistoryService historyService;

  void init() async {
    final manga = await historyService.getAll();

    List<HistoryMangaGroup> groups = await _processGroups(manga);

    emit(HistoryInitialized(
        mangaHistory: manga,
        groups: groups,
        expanded: {for (var i in groups) groups.indexOf(i): false}));
  }

  Future<List<HistoryMangaGroup>> _processGroups(
      List<HistoryMangaItem> manga) async {
    final concreteGroups = <String, List<HistoryMangaItem>>{};

    for (var element in manga) {
      if (concreteGroups.containsKey(element.concreteView.uid)) {
        concreteGroups[element.concreteView.uid]!.add(element);
      } else {
        concreteGroups[element.concreteView.uid] = [element];
      }
    }

    final groups = await Future.wait(concreteGroups.entries.map((e) async {
      var client = ApiClient(code: e.value.first.serviceSourceCode);
      return HistoryMangaGroup(
          client: client,
          configInfo: await client.getConfigInfo(),
          concreteView: e.value.first.concreteView,
          galleryView: e.value.first.galleryView,
          mangaItems: e.value
            ..sort(
              (a, b) => b.timestamp.compareTo(a.timestamp),
            ));
    }));
    return groups;
  }

  void addMangaToHistory(
      {required String serviceSourceCode,
      required ConcreteView concreteView,
      required GalleryView galleryView,
      required String chapterUid}) async {
    final item = HistoryMangaItem(
        serviceSourceCode: serviceSourceCode,
        concreteView: concreteView,
        galleryView: galleryView,
        chapterUid: chapterUid,
        timestamp: DateTime.now());

    await historyService.insert(item);

    if (state is HistoryInitialized) {
      var history = [...(state as HistoryInitialized).mangaHistory, item];
      final groups = await _processGroups(history);

      emit((state as HistoryInitialized).copyWith(
          mangaHistory: history,
          groups: groups,
          expanded: {for (var i in groups) groups.indexOf(i): false}));
    }
  }

  void deleteItemFromGroup(
      {required HistoryMangaGroup group,
      required HistoryMangaItem item}) async {
    if (this.state is! HistoryInitialized) {
      return;
    }

    final state = this.state as HistoryInitialized;

    final groups = List.of(state.groups);

    final group =
        groups.firstWhere((element) => element.mangaItems.contains(item));
    group.mangaItems.remove(item);

    if (group.mangaItems.isEmpty) {
      groups.remove(group);
    }

    await historyService.delete(item.id!);
    final history = List.of((state).mangaHistory)
      ..removeWhere((element) => element.id == item.id);

    emit((state).copyWith(mangaHistory: history, groups: groups));
  }

  Future<void> clear() async {
    await historyService.clear();
    init();
  }

  void expand({required int index}) async {
    if (this.state is! HistoryInitialized) {
      return;
    }

    final state = this.state as HistoryInitialized;

    final newExpanded = Map.of(state.expanded);

    newExpanded[index] = !newExpanded[index]!;

    emit(state.copyWith(expanded: newExpanded));
  }
}
