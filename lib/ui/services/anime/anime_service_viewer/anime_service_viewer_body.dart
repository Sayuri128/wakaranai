import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_grid_skeleton.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_loader.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/service_viewer_header.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/widgets/scroll_to_top_area.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimeServiceViewerBody extends StatelessWidget {
  const AnimeServiceViewerBody(
      {super.key,
      required this.apiClient,
      required this.configInfo,
      required this.scaffold,
      required this.refreshController,
      required this.searchController,
      required this.state});

  final ServiceViewState<AnimeApiClient, AnimeGalleryView> state;
  final RefreshController refreshController;
  final TextEditingController searchController;
  final AnimeApiClient apiClient;
  final ConfigInfo configInfo;
  final GlobalKey scaffold;

  ServiceViewError<AnimeApiClient, AnimeGalleryView> get stateError =>
      state as ServiceViewError<AnimeApiClient, AnimeGalleryView>;

  ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>
      get stateInitialized =>
          state as ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>;

  ServiceViewCubit<AnimeApiClient, AnimeGalleryView> _cubit(
          BuildContext context) =>
      context.read<ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>();

  @override
  Widget build(BuildContext context) {
    final bool initialized =
        state is ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>;
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
                  SmartRefresher(
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
                      if (state is ServiceViewLoading<AnimeApiClient,
                          AnimeGalleryView>) {
                        return;
                      }
                      if (initialized && !stateInitialized.loading) {
                        _cubit(context).getGallery();
                      }
                    },
                    child: _buildGrid(context),
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
                  if (!initialized &&
                      state is! ServiceViewError<AnimeApiClient,
                          AnimeGalleryView>)
                    const GalleryGridSkeleton()
                  else if (state is ServiceViewError<AnimeApiClient,
                      AnimeGalleryView>)
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

  Widget _buildGrid(BuildContext context) {
    if (state is! ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>) {
      return const SizedBox();
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: kGalleryGridPadding,
      gridDelegate: kGalleryGridDelegate,
      itemCount: stateInitialized.galleryViews.length,
      itemBuilder: (BuildContext context, int index) {
        final AnimeGalleryView galleryView =
            stateInitialized.galleryViews[index];
        return GalleryViewCard(
          cover: galleryView.cover,
          uid: galleryView.uid,
          title: galleryView.title,
          headers:
              stateInitialized.galleryViewImagesHeaders[galleryView.uid] ??
                  <String, String>{},
          onLongPress: () {},
          onTap: () => _onGalleryViewClick(context, galleryView),
        );
      },
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
            S.of(context).service_view_search_results_for(
                stateInitialized.searchQuery),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: stateError.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(S.of(context).service_view_retry_button_title),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.mainWhite,
            side: BorderSide(color: AppColors.mainGrey),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _onGalleryViewClick(BuildContext context, AnimeGalleryView e) {
    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
        arguments: AnimeConcreteViewerData(
            client: apiClient,
            uid: e.uid,
            galleryData: e.data,
            galleryCover: e.cover,
            configInfo: configInfo));
  }
}
