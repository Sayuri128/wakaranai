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
import 'package:wakaranai/ui/home/service_viewer_header.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_scope.dart';
import 'package:wakaranai/ui/services/widgets/gallery_title_actions_sheet.dart';
import 'package:wakaranai/ui/widgets/scroll_to_top_area.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ServiceViewerBody<T extends ApiClient, G extends GalleryView>
    extends StatelessWidget {
  const ServiceViewerBody({
    super.key,
    required this.kind,
    required this.scaffold,
    required this.state,
    required this.apiClient,
    required this.configInfo,
    required this.refreshController,
    required this.searchController,
  });

  final ServiceGalleryKind<T, G> kind;
  final ServiceViewState<T, G> state;
  final GlobalKey scaffold;
  final T apiClient;
  final ConfigInfo configInfo;

  final RefreshController refreshController;
  final TextEditingController searchController;

  ServiceViewInitialized<T, G> get stateInitialized =>
      state as ServiceViewInitialized<T, G>;

  ServiceViewError<T, G> get stateError => state as ServiceViewError<T, G>;

  ServiceViewCubit<T, G> _cubit(BuildContext context) =>
      context.read<ServiceViewCubit<T, G>>();

  @override
  Widget build(BuildContext context) {
    final bool initialized = state is ServiceViewInitialized<T, G>;
    return Scaffold(
      key: scaffold,
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: <Widget>[
          _buildHeader(context),
          if (initialized && stateInitialized.searchQuery.isNotEmpty)
            _buildSearchChip(context),
          Expanded(
            child: ScrollToTopArea(
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
            ),
          ),
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
        await _cubit(context).refresh();
        refreshController.refreshCompleted();
      },
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          return ServiceViewerLoader(cubit: _cubit(context));
        },
      ),
      controller: refreshController,
      onLoading: () async {
        if (state is ServiceViewLoading<T, G>) {
          return;
        }
        if (initialized && !stateInitialized.loading) {
          unawaited(_cubit(context).getGallery());
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

  Widget _buildSearchChip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          backgroundColor: AppColors.overlay(0.08),
          side: BorderSide.none,
          label: Text(
            S
                .of(context)
                .service_view_search_results_for(stateInitialized.searchQuery),
            style: regular(size: 13),
          ),
          deleteIconColor: AppColors.mainGrey,
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          onDeleted: () {
            searchController.clear();
            _cubit(context).search('');
          },
        ),
      ),
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

  Widget _buildHeader(BuildContext context) => ServiceViewerHeader(
    configInfo: configInfo,
    apiClient: apiClient,
    searchController: searchController,
    cubit: _cubit(context),
  );

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
