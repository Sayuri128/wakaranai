import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/service_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer_body.dart';

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
          return ServiceViewCubitWrapper<AnimeApiClient, AnimeGalleryView>(
            client: apiClient,
            builder: (BuildContext context,
                    ServiceViewState<AnimeApiClient, AnimeGalleryView>
                        state) =>
                _wrapBrowserInterceptor(
                    child: BlocListener<
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
                    apiClient: apiClient,
                    interceptorInitCompleter: interceptorInitCompleter,
                    configInfo: configInfo),
          );
        },
        onInterceptorInitialized: () {
          if (widget.data.nextViewerData != null) {
            Navigator.of(context)
                .pushNamed(
              Routes.animeConcreteViewer,
              arguments: widget.data.nextViewerData,
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

  Widget _wrapBrowserInterceptor(
      {required Widget child,
      required AnimeApiClient apiClient,
      required ConfigInfo configInfo,
      required Completer<bool> interceptorInitCompleter}) {
    if (configInfo.protectorConfig?.inAppBrowserInterceptor ?? false) {
      return BlocProvider<BrowserInterceptorCubit>(
        lazy: false,
        create: (BuildContext context) {
          final BrowserInterceptorCubit cubit = BrowserInterceptorCubit();
          cubit
              .init(
                  url: configInfo.protectorConfig!.pingUrl,
                  initCompleter: interceptorInitCompleter)
              .then((value) {
            apiClient.passWebBrowserInterceptorController(controller: cubit);
          });
          return cubit;
        },
        child: child,
      );
    } else {
      return child;
    }
  }
}
