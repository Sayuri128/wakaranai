import 'package:wakaranai/models/data/history_manga_item/history_manga_item.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class HistoryMangaGroup {
  final MangaApiClient client;
  final ConfigInfo configInfo;
  final MangaConcreteView concreteView;
  final MangaGalleryView galleryView;

  final List<HistoryMangaItem> mangaItems;

  const HistoryMangaGroup({
    required this.client,
    required this.configInfo,
    required this.concreteView,
    required this.galleryView,
    required this.mangaItems,
  });

  HistoryMangaGroup copyWith({
    MangaApiClient? client,
    ConfigInfo? configInfo,
    MangaConcreteView? concreteView,
    MangaGalleryView? galleryView,
    List<HistoryMangaItem>? mangaItems,
  }) {
    return HistoryMangaGroup(
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      mangaItems: mangaItems ?? this.mangaItems,
    );
  }
}
