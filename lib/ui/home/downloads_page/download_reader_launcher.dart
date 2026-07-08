import 'dart:convert';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';

class DownloadReaderData {
  final DownloadDomain download;

  const DownloadReaderData({required this.download});
}

class _LaunchContext {
  final ExtensionDomain? extension;
  final ConcreteDataDomain? concrete;
  final ChapterActivityDomain? activity;

  const _LaunchContext({
    required this.extension,
    required this.concrete,
    required this.activity,
  });
}

class DownloadReaderLauncher extends StatelessWidget {
  const DownloadReaderLauncher({super.key, required this.data});

  final DownloadReaderData data;

  DownloadDomain get download => data.download;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LaunchContext>(
      future: _loadContext(context),
      builder: (BuildContext context, AsyncSnapshot<_LaunchContext> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loading();
        }

        final ExtensionDomain? extension = snapshot.data?.extension;
        if (extension == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: ServiceViewerMessage(
              icon: Icons.extension_off_rounded,
              title: S.current.library_source_unavailable_title,
              message: S.current.library_source_unavailable_message,
            ),
          );
        }

        return ApiControllerWrapper<MangaApiClient>(
          remoteConfig: extension,
          builder: (MangaApiClient client, ConfigInfo configInfo) {
            final ChapterViewerData viewerData = _buildViewerData(
              client: client,
              configInfo: configInfo,
              concrete: snapshot.data?.concrete,
              activity: snapshot.data?.activity,
            );
            return ChapterViewer(data: viewerData);
          },
        );
      },
    );
  }

  Future<_LaunchContext> _loadContext(BuildContext context) async {
    final ExtensionDomain? extension = await context
        .read<ExtensionRepository>()
        .getByUid(download.extensionUid);
    final ConcreteDataDomain? concrete = await context
        .read<ConcreteDataRepository>()
        .getByUid(download.concreteUid);
    final ChapterActivityDomain? activity = await context
        .read<ChapterActivityRepository>()
        .getBy<$ChapterActivityTableTable>(download.uid,
            where: (tbl) => tbl.uid);

    return _LaunchContext(
      extension: extension,
      concrete: concrete,
      activity: activity,
    );
  }

  ChapterViewerData _buildViewerData({
    required MangaApiClient client,
    required ConfigInfo configInfo,
    required ConcreteDataDomain? concrete,
    required ChapterActivityDomain? activity,
  }) {
    MangaConcreteView? view;
    if (concrete?.concreteJson != null) {
      try {
        view = MangaConcreteView.fromJson(
            jsonDecode(concrete!.concreteJson!) as Map<String, dynamic>);
      } catch (e, s) {
        logger.w('Failed to rebuild cached concrete view: $e');
        logger.w(s);
      }
    }

    Chapter? chapter;
    ChaptersGroup? group;
    if (view != null) {
      for (final ChaptersGroup g in view.groups) {
        final Chapter? found =
            g.elements.firstWhereOrNull((Chapter c) => c.uid == download.uid);
        if (found != null) {
          group = g;
          chapter = found;
          break;
        }
      }
    }

    chapter ??= Chapter(
      uid: download.uid,
      title: download.title,
      data: download.dataJson,
    );
    group ??= ChaptersGroup(title: '', elements: <Chapter>[chapter]);
    view ??= MangaConcreteView(
      uid: download.concreteUid,
      cover: '',
      title: download.concreteTitle,
      alternativeTitles: const <String>[],
      description: '',
      tags: const <String>[],
      status: MangaStatus.UNDEFINED,
      groups: <ChaptersGroup>[group],
    );

    return ChapterViewerData(
      apiClient: client,
      configInfo: configInfo,
      concreteView: view,
      group: group,
      chapter: chapter,
      initialPage: activity?.readPages ?? 1,
    );
  }

  Widget _loading() {
    return Scaffold(
      backgroundColor: AppColors.mainBlack,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
