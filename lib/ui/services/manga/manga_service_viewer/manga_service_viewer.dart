import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
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
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer_body.dart';

class MangaServiceViewData {
  final BaseExtension? remoteConfig;
  final MangaConcreteViewerData? nextViewerData;

  MangaServiceViewData({
    this.remoteConfig,
    this.nextViewerData,
  }) {
    assert(remoteConfig != null);
  }
}

class MangaServiceView extends StatefulWidget {
  const MangaServiceView({super.key, required this.data});

  final MangaServiceViewData data;

  @override
  State<MangaServiceView> createState() => _MangaServiceViewState();
}

class _MangaServiceViewState extends State<MangaServiceView> {
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
    return ApiControllerWrapper<MangaApiClient>(
      remoteConfig: widget.data.remoteConfig,
      builder: _buildWidget,
    );
  }

  Widget _buildWidget(MangaApiClient apiClient, ConfigInfo configInfo) {
    return WebBrowserWrapper<MangaApiClient>(
        apiClient: apiClient,
        builder:
            (BuildContext context, Completer<bool> interceptorInitCompleter) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (Route route) => false);
              return false;
            },
            child: ServiceViewCubitWrapper<MangaApiClient, MangaGalleryView>(
              client: apiClient,
              builder: (BuildContext context,
                      ServiceViewState<MangaApiClient, MangaGalleryView>
                          state) =>
                  _wrapBrowserInterceptor(
                child: BlocListener<
                    ServiceViewCubit<MangaApiClient, MangaGalleryView>,
                    ServiceViewState<MangaApiClient, MangaGalleryView>>(
                  listener: (BuildContext context,
                      ServiceViewState<MangaApiClient, MangaGalleryView>
                          state) {
                    if (state is ServiceViewInitialized<MangaApiClient,
                        MangaGalleryView>) {
                      _refreshController.loadComplete();
                    }
                  },
                  child: MangaServiceViewBody(
                    scaffold: _scaffold,
                    configInfo: configInfo,
                    state: state,
                    apiClient: apiClient,
                    refreshController: _refreshController,
                    searchController: _searchController,
                  ),
                ),
                apiClient: apiClient,
                interceptorInitCompleter: interceptorInitCompleter,
                configInfo: configInfo,
              ),
            ),
          );
        },
        onInterceptorInitialized: () {
          if (widget.data.nextViewerData != null) {
            Navigator.of(context)
                .pushNamed(
              Routes.mangaConcreteViewer,
              arguments: widget.data.nextViewerData,
            )
                .then((_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          } else {
            _scaffold.currentContext
                ?.read<ServiceViewCubit<MangaApiClient, MangaGalleryView>>()
                .init(configInfo);
          }
        },
        configInfo: configInfo);
  }

  Widget _wrapBrowserInterceptor(
      {required Widget child,
      required MangaApiClient apiClient,
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
