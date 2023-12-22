import 'dart:async';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/service_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/manga_service_viewer/manga_service_viewer_body.dart';

import '../routes.dart';

class MangaServiceViewData {
  final RemoteConfig? remoteConfig;

  MangaServiceViewData({this.remoteConfig}) {
    assert(remoteConfig != null);
  }
}

class MangaServiceView extends StatefulWidget {
  const MangaServiceView({Key? key, required this.data}) : super(key: key);

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
        builder: (context, interceptorInitCompleter) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (route) => false);
              return false;
            },
            child: ServiceViewCubitWrapper<MangaApiClient, MangaGalleryView>(
              client: apiClient,
              builder: (context, state) => _wrapBrowserInterceptor(
                  child: BlocListener<
                      ServiceViewCubit<MangaApiClient, MangaGalleryView>,
                      ServiceViewState<MangaApiClient, MangaGalleryView>>(
                    listener: (context, state) {
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
                  configInfo: configInfo),
            ),
          );
        },
        onInterceptorInitialized: () {
          _scaffold.currentContext
              ?.read<ServiceViewCubit<MangaApiClient, MangaGalleryView>>()
              .init(configInfo);
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
        create: (context) {
          final cubit = BrowserInterceptorCubit()
            ..init(
                url: configInfo.protectorConfig!.pingUrl,
                initCompleter: interceptorInitCompleter);
          apiClient.passWebBrowserInterceptorController(controller: cubit);
          return cubit;
        },
        child: child,
      );
    } else {
      return child;
    }
  }
}
