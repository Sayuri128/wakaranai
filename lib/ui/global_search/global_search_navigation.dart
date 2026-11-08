import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/novel_service_viewer.dart';

String globalSearchTitleOf(GalleryView item) {
  if (item is MangaGalleryView) {
    return item.title;
  }
  if (item is AnimeGalleryView) {
    return item.title;
  }
  return '';
}

String globalSearchCoverOf(GalleryView item) {
  if (item is MangaGalleryView) {
    return item.cover;
  }
  if (item is AnimeGalleryView) {
    return item.cover;
  }
  return '';
}

Future<void> openGlobalSearchResult(
  BuildContext context,
  GlobalSearchRail rail,
  GalleryView item,
) async {
  final ApiClient? client = rail.client;
  final ConfigInfo? config = rail.config;
  if (client == null || config == null) {
    return;
  }
  final Object? arguments = _concreteArguments(
    client: client,
    config: config,
    item: item,
    coverHeaders: rail.coverHeaders[item.uid] ?? const <String, String>{},
  );
  final String? route = _concreteRoute(client);
  if (arguments == null || route == null) {
    return;
  }
  await Navigator.of(context).pushNamed(route, arguments: arguments);
  if (context.mounted) {
    _refreshHistory(context, config.type);
  }
}

String? _concreteRoute(ApiClient client) {
  if (client is MangaApiClient) {
    return const MangaGalleryKind().concreteRoute;
  }
  if (client is AnimeApiClient) {
    return const AnimeGalleryKind().concreteRoute;
  }
  if (client is NovelApiClient) {
    return const NovelGalleryKind().concreteRoute;
  }
  return null;
}

Object? _concreteArguments({
  required ApiClient client,
  required ConfigInfo config,
  required GalleryView item,
  required Map<String, String> coverHeaders,
}) {
  if (client is MangaApiClient && item is MangaGalleryView) {
    return const MangaGalleryKind().concreteArguments(
      client: client,
      configInfo: config,
      galleryView: item,
      coverHeaders: coverHeaders,
    );
  }
  if (client is AnimeApiClient && item is AnimeGalleryView) {
    return const AnimeGalleryKind().concreteArguments(
      client: client,
      configInfo: config,
      galleryView: item,
      coverHeaders: coverHeaders,
    );
  }
  if (client is NovelApiClient && item is MangaGalleryView) {
    return const NovelGalleryKind().concreteArguments(
      client: client,
      configInfo: config,
      galleryView: item,
      coverHeaders: coverHeaders,
    );
  }
  return null;
}

Future<void> openGlobalSearchSource(
  BuildContext context,
  BaseExtension extension,
) async {
  final ConfigInfoType type = extension.config.type;
  switch (type) {
    case ConfigInfoType.MANGA:
      await Navigator.of(context).pushNamed(
        Routes.mangaServiceViewer,
        arguments: MangaServiceViewData(remoteConfig: extension),
      );
    case ConfigInfoType.ANIME:
      await Navigator.of(context).pushNamed(
        Routes.animeServiceViewer,
        arguments: AnimeServiceViewerData(remoteConfig: extension),
      );
    case ConfigInfoType.NOVEL:
      await Navigator.of(context).pushNamed(
        Routes.novelServiceViewer,
        arguments: NovelServiceViewData(remoteConfig: extension),
      );
  }
  if (context.mounted) {
    _refreshHistory(context, type);
  }
}

void _refreshHistory(BuildContext context, ConfigInfoType type) {
  if (type == ConfigInfoType.ANIME) {
    context.read<AnimeActivityHistoryCubit>().init(silent: true);
    return;
  }
  context.read<MangaActivityHistoryCubit>().init(silent: true);
}
