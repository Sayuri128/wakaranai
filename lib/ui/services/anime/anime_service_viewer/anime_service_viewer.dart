import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_shell.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';

class AnimeServiceViewerData {
  final BaseExtension? remoteConfig;
  final AnimeConcreteViewerData? nextViewerData;

  AnimeServiceViewerData({
    this.remoteConfig,
    this.nextViewerData,
  }) {
    assert(remoteConfig != null);
  }
}

class AnimeServiceViewer extends StatelessWidget {
  const AnimeServiceViewer({super.key, required this.data});

  final AnimeServiceViewerData data;

  @override
  Widget build(BuildContext context) {
    final AnimeConcreteViewerData? nextViewerData = data.nextViewerData;
    return ServiceViewerShell<AnimeApiClient, AnimeGalleryView>(
      remoteConfig: data.remoteConfig,
      kind: const AnimeGalleryKind(),
      nextViewerArguments: nextViewerData == null
          ? null
          : (AnimeApiClient client, ConfigInfo configInfo) =>
              nextViewerData.copyWith(client: client, configInfo: configInfo),
    );
  }
}

class AnimeGalleryKind
    extends ServiceGalleryKind<AnimeApiClient, AnimeGalleryView> {
  const AnimeGalleryKind();

  @override
  String get concreteRoute => Routes.animeConcreteViewer;

  @override
  String titleOf(AnimeGalleryView galleryView) => galleryView.title;

  @override
  String coverOf(AnimeGalleryView galleryView) => galleryView.cover;

  @override
  String? statusOf(AnimeGalleryView galleryView) => galleryView.status.name;

  @override
  Future<List<BaseActivityDomain>?> loadActivities(
    BuildContext context,
    String concreteUid,
  ) {
    return context
        .read<AnimeEpisodeActivityRepository>()
        .getAllActivitiesByConcreteId(concreteUid);
  }

  @override
  Object concreteArguments({
    required AnimeApiClient client,
    required ConfigInfo configInfo,
    required AnimeGalleryView galleryView,
    required Map<String, String> coverHeaders,
  }) {
    return AnimeConcreteViewerData(
      client: client,
      uid: galleryView.uid,
      galleryData: galleryView.data,
      galleryCover: galleryView.cover,
      configInfo: configInfo,
    );
  }
}
