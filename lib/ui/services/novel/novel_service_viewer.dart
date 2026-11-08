import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_shell.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/novel/novel_concrete_viewer.dart';

class NovelServiceViewData {
  final BaseExtension? remoteConfig;
  final NovelConcreteViewerData? nextViewerData;

  NovelServiceViewData({
    this.remoteConfig,
    this.nextViewerData,
  }) {
    assert(remoteConfig != null);
  }
}

class NovelServiceView extends StatelessWidget {
  const NovelServiceView({super.key, required this.data});

  final NovelServiceViewData data;

  @override
  Widget build(BuildContext context) {
    final NovelConcreteViewerData? nextViewerData = data.nextViewerData;
    return ServiceViewerShell<NovelApiClient, MangaGalleryView>(
      remoteConfig: data.remoteConfig,
      kind: const NovelGalleryKind(),
      nextViewerArguments: nextViewerData == null
          ? null
          : (NovelApiClient client, ConfigInfo configInfo) =>
              nextViewerData.copyWith(client: client, configInfo: configInfo),
    );
  }
}

class NovelGalleryKind
    extends ServiceGalleryKind<NovelApiClient, MangaGalleryView> {
  const NovelGalleryKind();

  @override
  String get concreteRoute => Routes.novelConcreteViewer;

  @override
  String titleOf(MangaGalleryView galleryView) => galleryView.title;

  @override
  String coverOf(MangaGalleryView galleryView) => galleryView.cover;

  @override
  String? statusOf(MangaGalleryView galleryView) => galleryView.status?.name;

  @override
  Future<List<BaseActivityDomain>?> loadActivities(
    BuildContext context,
    String concreteUid,
  ) {
    return context
        .read<ChapterActivityRepository>()
        .getAllActivitiesByConcreteId(concreteUid);
  }

  @override
  Object concreteArguments({
    required NovelApiClient client,
    required ConfigInfo configInfo,
    required MangaGalleryView galleryView,
    required Map<String, String> coverHeaders,
  }) {
    return NovelConcreteViewerData(
      client: client,
      uid: galleryView.uid,
      coverHeaders: coverHeaders,
      galleryData: galleryView.data,
      galleryCover: galleryView.cover,
      configInfo: configInfo,
    );
  }
}
