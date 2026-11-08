import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_grid_skeleton.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_items_view.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout_transition.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_loader.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_scope.dart';
import 'package:wakaranai/ui/services/widgets/gallery_title_actions_sheet.dart';
import 'package:wakaranai/ui/widgets/scroll_to_top_area.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/source_error_description.dart';

class ServiceGalleryPage<T extends ApiClient, G extends GalleryView>
    extends StatefulWidget {
  const ServiceGalleryPage({
    super.key,
    required this.kind,
    required this.cubit,
    required this.apiClient,
    required this.configInfo,
    required this.active,
  });

  final ServiceGalleryKind<T, G> kind;
  final ServiceViewCubit<T, G> cubit;
  final T apiClient;
  final ConfigInfo configInfo;
  final bool active;

  @override
  State<ServiceGalleryPage<T, G>> createState() =>
      _ServiceGalleryPageState<T, G>();
}

class _ServiceGalleryPageState<T extends ApiClient, G extends GalleryView>
    extends State<ServiceGalleryPage<T, G>> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceViewCubit<T, G>>.value(
      value: widget.cubit,
      child: BlocConsumer<ServiceViewCubit<T, G>, ServiceViewState<T, G>>(
        bloc: widget.cubit,
        listener: _onStateChanged,
        builder: (BuildContext context, ServiceViewState<T, G> state) =>
            _ServiceGalleryContent<T, G>(
          kind: widget.kind,
          cubit: widget.cubit,
          state: state,
          apiClient: widget.apiClient,
          configInfo: widget.configInfo,
          refreshController: _refreshController,
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ServiceViewState<T, G> state) {
    if (state is! ServiceViewInitialized<T, G>) {
      return;
    }
    _refreshController.loadComplete();
    if (widget.active) {
      _showFailure(state.failure);
    }
  }

  void _showFailure(ServiceViewFailure? failure) {
    if (failure == null || !mounted) {
      return;
    }
    final SourceErrorDescription? description = describeSourceErrorFor(
      failure.error,
      widget.configInfo,
    );
    if (description == null) {
      return;
    }
    showSourceErrorSnackBar(
      context,
      description: description,
      onRetry: failure.retry,
      onSignIn: () => unawaited(
        signInToSource(
          context,
          apiClient: widget.apiClient,
          configInfo: widget.configInfo,
          onSignedIn: failure.retry,
        ),
      ),
    );
  }
}

class _ServiceGalleryContent<T extends ApiClient, G extends GalleryView>
    extends StatelessWidget {
  const _ServiceGalleryContent({
    required this.kind,
    required this.cubit,
    required this.state,
    required this.apiClient,
    required this.configInfo,
    required this.refreshController,
  });

  final ServiceGalleryKind<T, G> kind;
  final ServiceViewCubit<T, G> cubit;
  final ServiceViewState<T, G> state;
  final T apiClient;
  final ConfigInfo configInfo;
  final RefreshController refreshController;

  ServiceViewInitialized<T, G> get stateInitialized =>
      state as ServiceViewInitialized<T, G>;

  ServiceViewError<T, G> get stateError => state as ServiceViewError<T, G>;

  @override
  Widget build(BuildContext context) {
    final bool initialized = state is ServiceViewInitialized<T, G>;
    return ScrollToTopArea(
      refreshController: refreshController,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GalleryLayoutTransition(
            layout: context.watch<GalleryLayoutCubit>().state,
            geometry: const ServiceGalleryGeometry(),
            position: () => refreshController.position,
            builder:
                (
                  BuildContext context,
                  GalleryLayout layout,
                  GalleryMorph? morph,
                ) => _buildRefresher(context, layout, morph),
          ),
          if (initialized && stateInitialized.loading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primary,
                backgroundColor: Colors.transparent,
              ),
            ),
          if (!initialized && state is! ServiceViewError<T, G>)
            GalleryGridSkeleton(
              layout: context.watch<GalleryLayoutCubit>().state,
            )
          else if (state is ServiceViewError<T, G>)
            _buildError(context)
          else if (stateInitialized.galleryViews.isEmpty &&
              !stateInitialized.loading)
            _buildEmpty(context),
        ],
      ),
    );
  }

  Widget _buildRefresher(
    BuildContext context,
    GalleryLayout layout,
    GalleryMorph? morph,
  ) {
    final bool initialized = state is ServiceViewInitialized<T, G>;
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: true,
      onRefresh: () async {
        await cubit.refresh();
        refreshController.refreshCompleted();
      },
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          return ServiceViewerLoader(cubit: cubit);
        },
      ),
      controller: refreshController,
      onLoading: () async {
        if (state is ServiceViewLoading<T, G>) {
          return;
        }
        if (initialized && !stateInitialized.loading) {
          unawaited(cubit.getGallery());
        }
      },
      child: _buildGrid(context, layout, morph),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    GalleryLayout layout,
    GalleryMorph? morph,
  ) {
    if (state is! ServiceViewInitialized<T, G>) {
      return const SizedBox();
    }
    return GalleryItemsView(
      layout: layout,
      morph: morph,
      itemCount: stateInitialized.galleryViews.length,
      itemAt: (int index) =>
          _galleryItem(context, stateInitialized.galleryViews[index]),
      activityLoader: (String uid) async =>
          latestActivityTitle(await kind.loadActivities(context, uid)),
    ).build(context);
  }

  GalleryItem _galleryItem(BuildContext context, G galleryView) {
    final String title = kind.titleOf(galleryView);
    final String cover = kind.coverOf(galleryView);
    return GalleryItem(
      uid: galleryView.uid,
      title: title,
      cover: cover,
      headers:
          stateInitialized.galleryViewImagesHeaders[galleryView.uid] ??
          <String, String>{},
      onLongPress: () => showGalleryTitleActions(
        context,
        title: GalleryTitle(
          uid: galleryView.uid,
          extensionUid: configInfo.uid,
          title: title,
          cover: cover,
          data: galleryView.data,
        ),
        downloadClient: apiClient,
      ),
      onTap: () => _onGalleryViewClick(context, galleryView),
      subtitle: galleryView.subtitle,
      status: kind.statusOf(galleryView),
      tags: galleryView.tags,
      year: galleryView.year,
      rating: galleryView.rating,
      latestChapter: galleryView.latestChapter,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final bool searching = stateInitialized.searchQuery.isNotEmpty;
    return ServiceViewerMessage(
      icon: searching ? Icons.search_off_rounded : Icons.inbox_rounded,
      title: searching
          ? S.of(context).service_view_no_results_title
          : S.of(context).service_view_empty_title,
      message: searching
          ? S
                .of(context)
                .service_view_no_results_message(stateInitialized.searchQuery)
          : S.of(context).service_view_empty_message,
    );
  }

  Widget _buildError(BuildContext context) {
    final SourceErrorDescription? description = describeSourceErrorFor(
      stateError.error,
      configInfo,
    );
    if (description != null) {
      return _buildSourceError(context, description);
    }
    return ServiceViewerMessage(
      icon: Icons.error_outline_rounded,
      title: S.of(context).service_view_error_title,
      actions: <Widget>[
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => unawaited(
            BrowserInterceptorScope.retry(context, stateError.retry),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(S.of(context).service_view_retry_button_title),
        ),
        if (configInfo.protectorConfig != null)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mainWhite,
              side: BorderSide(color: AppColors.mainGrey),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => openWebView(context, apiClient, configInfo),
            icon: const Icon(Icons.public_rounded),
            label: Text(S.of(context).service_view_open_web_view_button_title),
          ),
      ],
    );
  }

  Widget _buildSourceError(
    BuildContext context,
    SourceErrorDescription description,
  ) {
    final void Function() retry = stateError.retry;
    void retryWithInterceptor() {
      unawaited(BrowserInterceptorScope.retry(context, retry));
    }

    return SourceErrorView(
      description: description,
      onRetry: retryWithInterceptor,
      onSignIn: () => unawaited(
        signInToSource(
          context,
          apiClient: apiClient,
          configInfo: configInfo,
          onSignedIn: retry,
        ),
      ),
      extraActions: _galleryErrorExtraActions(
        context,
        description,
        onRetry: retryWithInterceptor,
      ),
    );
  }

  List<SourceErrorExtraAction> _galleryErrorExtraActions(
    BuildContext context,
    SourceErrorDescription description, {
    required VoidCallback onRetry,
  }) {
    final List<SourceErrorExtraAction> actions = <SourceErrorExtraAction>[];
    if (!description.offersRetry) {
      actions.add(SourceErrorExtraAction(
        icon: Icons.refresh_rounded,
        label: S.of(context).source_error_retry_button,
        onPressed: onRetry,
      ));
    }
    if (configInfo.protectorConfig != null && !description.offersSignIn) {
      actions.add(SourceErrorExtraAction(
        icon: Icons.public_rounded,
        label: S.of(context).service_view_open_web_view_button_title,
        onPressed: () => unawaited(openWebView(context, apiClient, configInfo)),
      ));
    }
    return actions;
  }

  Future<void> _onGalleryViewClick(BuildContext context, G galleryView) async {
    await Navigator.of(context).pushNamed(
      kind.concreteRoute,
      arguments: kind.concreteArguments(
        client: apiClient,
        configInfo: configInfo,
        galleryView: galleryView,
        coverHeaders:
            stateInitialized.galleryViewImagesHeaders[galleryView.uid] ??
            <String, String>{},
      ),
    );
  }
}
