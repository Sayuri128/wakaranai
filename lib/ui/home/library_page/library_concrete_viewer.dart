import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';

class LibraryConcreteViewerData {
  final LibraryEntryDomain entry;

  const LibraryConcreteViewerData({required this.entry});
}

class LibraryConcreteViewer extends StatefulWidget {
  const LibraryConcreteViewer({super.key, required this.data});

  final LibraryConcreteViewerData data;

  @override
  State<LibraryConcreteViewer> createState() => _LibraryConcreteViewerState();
}

class _LibraryConcreteViewerState extends State<LibraryConcreteViewer> {
  late final Future<ExtensionDomain?> _extension;

  @override
  void initState() {
    super.initState();
    _extension = ExtensionResolver(
      extensionRepository: context.read<ExtensionRepository>(),
      extensionSourceRepository: context.read<ExtensionSourceRepository>(),
    ).resolve(widget.data.entry.extensionUid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExtensionDomain?>(
      future: _extension,
      builder: (BuildContext context, AsyncSnapshot<ExtensionDomain?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final ExtensionDomain? extension = snapshot.data;
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

        if (extension.config.type == ConfigInfoType.MANGA) {
          return ApiControllerWrapper<MangaApiClient>(
            remoteConfig: extension,
            builder: (MangaApiClient client, ConfigInfo configInfo) =>
                MangaConcreteViewer(
              data: MangaConcreteViewerData(
                uid: widget.data.entry.uid,
                coverHeaders: const <String, String>{},
                galleryCover: widget.data.entry.cover,
                galleryData: widget.data.entry.dataJson,
                client: client,
                configInfo: configInfo,
                fromLibrary: true,
              ),
            ),
          );
        }

        return ApiControllerWrapper<AnimeApiClient>(
          remoteConfig: extension,
          builder: (AnimeApiClient client, ConfigInfo configInfo) =>
              AnimeConcreteViewer(
            data: AnimeConcreteViewerData(
              uid: widget.data.entry.uid,
              galleryData: widget.data.entry.dataJson,
              galleryCover: widget.data.entry.cover,
              client: client,
              configInfo: configInfo,
              fromLibrary: true,
            ),
          ),
        );
      },
    );
  }
}
