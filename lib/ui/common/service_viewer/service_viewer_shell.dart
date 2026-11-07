import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_body.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_scope.dart';

typedef NextViewerArguments<T extends ApiClient> = Object Function(
    T client, ConfigInfo configInfo);

class ServiceViewerShell<T extends ApiClient, G extends GalleryView>
    extends StatefulWidget {
  const ServiceViewerShell({
    super.key,
    required this.remoteConfig,
    required this.kind,
    this.nextViewerArguments,
  });

  final BaseExtension? remoteConfig;
  final ServiceGalleryKind<T, G> kind;
  final NextViewerArguments<T>? nextViewerArguments;

  @override
  State<ServiceViewerShell<T, G>> createState() =>
      _ServiceViewerShellState<T, G>();
}

class _ServiceViewerShellState<T extends ApiClient, G extends GalleryView>
    extends State<ServiceViewerShell<T, G>> {
  final GlobalKey _scaffold = GlobalKey();

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ApiControllerWrapper<T>(
      remoteConfig: widget.remoteConfig,
      builder: _buildWidget,
    );
  }

  Widget _buildWidget(T apiClient, ConfigInfo configInfo) {
    return WebBrowserWrapper<T>(
        apiClient: apiClient,
        builder:
            (BuildContext context, Completer<bool> interceptorInitCompleter) {
          return BrowserInterceptorScope(
            configInfo: configInfo,
            apiClient: apiClient,
            initCompleter: interceptorInitCompleter,
            onRecovered: _reloadGalleries,
            child: BlocProvider<ServiceGalleryCubit<T, G>>(
              create: (BuildContext context) => ServiceGalleryCubit<T, G>(
                client: apiClient,
                configInfo: configInfo,
              ),
              child: ServiceViewerBody<T, G>(
                kind: widget.kind,
                scaffold: _scaffold,
                configInfo: configInfo,
                apiClient: apiClient,
                searchController: _searchController,
              ),
            ),
          );
        },
        onInterceptorInitialized: () =>
            _onInterceptorInitialized(apiClient, configInfo),
        configInfo: configInfo);
  }

  ServiceGalleryCubit<T, G>? get _gallery =>
      _scaffold.currentContext?.read<ServiceGalleryCubit<T, G>>();

  void _onInterceptorInitialized(T apiClient, ConfigInfo configInfo) {
    final NextViewerArguments<T>? nextViewerArguments =
        widget.nextViewerArguments;
    if (nextViewerArguments != null) {
      Navigator.of(context)
          .pushNamed(
        widget.kind.concreteRoute,
        arguments: nextViewerArguments(apiClient, configInfo),
      )
          .then((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } else {
      _gallery?.start();
    }
  }

  void _reloadGalleries() {
    final ServiceGalleryCubit<T, G>? gallery = _gallery;
    if (gallery == null) {
      return;
    }
    unawaited(gallery.reloadLoadedGalleries());
  }
}
