import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/service_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer_body.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_scope.dart';

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

class AnimeServiceViewer extends StatefulWidget {
  const AnimeServiceViewer({super.key, required this.data});

  final AnimeServiceViewerData data;

  @override
  State<AnimeServiceViewer> createState() => _AnimeServiceViewerState();
}

class _AnimeServiceViewerState extends State<AnimeServiceViewer> {
  final GlobalKey _scaffold = GlobalKey();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ApiControllerWrapper<AnimeApiClient>(
      remoteConfig: widget.data.remoteConfig,
      builder: _buildWidget,
    );
  }

  Widget _buildWidget(AnimeApiClient apiClient, ConfigInfo configInfo) {
    return WebBrowserWrapper<AnimeApiClient>(
        builder:
            (BuildContext context, Completer<bool> interceptorInitCompleter) {
          return BrowserInterceptorScope(
            configInfo: configInfo,
            apiClient: apiClient,
            initCompleter: interceptorInitCompleter,
            onRecovered: () => _reloadGallery(configInfo),
            child: ServiceViewCubitWrapper<AnimeApiClient, AnimeGalleryView>(
              client: apiClient,
              builder: (BuildContext context,
                      ServiceViewState<AnimeApiClient, AnimeGalleryView>
                          state) =>
                  BlocListener<
                      ServiceViewCubit<AnimeApiClient, AnimeGalleryView>,
                      ServiceViewState<AnimeApiClient, AnimeGalleryView>>(
                listener: (BuildContext context,
                    ServiceViewState<AnimeApiClient, AnimeGalleryView>
                        state) {
                  if (state is ServiceViewInitialized<AnimeApiClient,
                      AnimeGalleryView>) {
                    _refreshController.loadComplete();
                  }
                },
                child: AnimeServiceViewerBody(
                  configInfo: configInfo,
                  apiClient: apiClient,
                  scaffold: _scaffold,
                  refreshController: _refreshController,
                  searchController: _searchController,
                  state: state,
                ),
              ),
            ),
          );
        },
        onInterceptorInitialized: () {
          final AnimeConcreteViewerData? nextViewerData =
              widget.data.nextViewerData;
          if (nextViewerData != null) {
            Navigator.of(context)
                .pushNamed(
              Routes.animeConcreteViewer,
              arguments: nextViewerData.copyWith(
                  client: apiClient, configInfo: configInfo),
            )
                .then((_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          } else {
            _scaffold.currentContext
                ?.read<ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>()
                .init(configInfo);
          }
        },
        configInfo: configInfo,
        apiClient: apiClient);
  }

  void _reloadGallery(ConfigInfo configInfo) {
    final ServiceViewCubit<AnimeApiClient, AnimeGalleryView>? cubit =
        _scaffold.currentContext
            ?.read<ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>();
    if (cubit == null) {
      return;
    }
    if (cubit.state
        is ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>) {
      unawaited(cubit.refresh());
      return;
    }
    cubit.init(configInfo);
  }
}
