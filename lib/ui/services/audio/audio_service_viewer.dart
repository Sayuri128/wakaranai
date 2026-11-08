import 'package:capyscript/api_clients/audio_api_client.dart';
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
import 'package:wakaranai/ui/services/audio/audio_concrete_viewer.dart';

class AudioServiceViewData {
  final BaseExtension? remoteConfig;
  final AudioConcreteViewerData? nextViewerData;

  AudioServiceViewData({
    this.remoteConfig,
    this.nextViewerData,
  }) {
    assert(remoteConfig != null);
  }
}

class AudioServiceView extends StatelessWidget {
  const AudioServiceView({super.key, required this.data});

  final AudioServiceViewData data;

  @override
  Widget build(BuildContext context) {
    final AudioConcreteViewerData? nextViewerData = data.nextViewerData;
    return ServiceViewerShell<AudioApiClient, MangaGalleryView>(
      remoteConfig: data.remoteConfig,
      kind: const AudioGalleryKind(),
      nextViewerArguments: nextViewerData == null
          ? null
          : (AudioApiClient client, ConfigInfo configInfo) =>
              nextViewerData.copyWith(client: client, configInfo: configInfo),
    );
  }
}

class AudioGalleryKind
    extends ServiceGalleryKind<AudioApiClient, MangaGalleryView> {
  const AudioGalleryKind();

  @override
  String get concreteRoute => Routes.audioConcreteViewer;

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
    required AudioApiClient client,
    required ConfigInfo configInfo,
    required MangaGalleryView galleryView,
    required Map<String, String> coverHeaders,
  }) {
    return AudioConcreteViewerData(
      client: client,
      uid: galleryView.uid,
      coverHeaders: coverHeaders,
      galleryData: galleryView.data,
      galleryCover: galleryView.cover,
      configInfo: configInfo,
    );
  }
}
