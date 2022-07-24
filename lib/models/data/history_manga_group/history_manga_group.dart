import 'package:wakaranai/models/data/history_manga_item/history_manga_item.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class HistoryMangaGroup {
  final ApiClient client;
  final ConfigInfo configInfo;
  final ConcreteView concreteView;

  final List<HistoryMangaItem> mangaItems;

  HistoryMangaGroup copyWith({
    ApiClient? client,
    ConfigInfo? configInfo,
    ConcreteView? concreteView,
    List<HistoryMangaItem>? mangaItems,
  }) {
    return HistoryMangaGroup(
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      concreteView: concreteView ?? this.concreteView,
      mangaItems: mangaItems ?? this.mangaItems,
    );
  }

  const HistoryMangaGroup({
    required this.client,
    required this.configInfo,
    required this.concreteView,
    required this.mangaItems,
  });
}
