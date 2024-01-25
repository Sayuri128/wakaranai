import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_loader.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/service_viewer_app_bar.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimeServiceViewerBody extends StatelessWidget {
  const AnimeServiceViewerBody(
      {Key? key,
      required this.apiClient,
      required this.configInfo,
      required this.scaffold,
      required this.refreshController,
      required this.searchController,
      required this.state})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              configInfo.searchAvailable ? 96 : 60),
          child: Builder(builder: (context) {
            return _buildSearchableAppBar(
                context,
                state is ServiceViewInitialized<AnimeApiClient,
                        AnimeGalleryView>
                    ? stateInitialized
                    : null);
          })),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SmartRefresher(
              enablePullUp: true,
              enablePullDown: false,
              footer: CustomFooter(
                builder: (context, mode) {
                  return ServiceViewerLoader(
                      cubit: context.read<
                          ServiceViewCubit<AnimeApiClient,
                              AnimeGalleryView>>());
                },
              ),
              controller: refreshController,
              onLoading: () {
                if (state is! ServiceViewLoading<AnimeApiClient,
                        AnimeGalleryView> ||
                    (state is ServiceViewInitialized<AnimeApiClient,
                            AnimeGalleryView> &&
                        !(state as ServiceViewInitialized<AnimeApiClient,
                                AnimeGalleryView>)
                            .loading)) {
                  context
                      .read<
                          ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>()
                      .getGallery();
                }
              },
              child: state is ServiceViewInitialized<AnimeApiClient,
                      AnimeGalleryView>
                  ? GridView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        final galleryView =
                            stateInitialized.galleryViews[index];
                        return GalleryViewCard(
                          cover: galleryView.cover,
                          uid: galleryView.uid,
                          title: galleryView.title,
                          headers: stateInitialized
                                  .galleryViewImagesHeaders[galleryView.uid] ??
                              {},
                          onLongPress: () {
                            // _onLongGalleryViewPress(context,
                            //     galleryView: galleryView,
                            //     canAdd: false);
                          },
                          onTap: () {
                            _onGalleryViewClick(context, galleryView);
                          },
                        );
                      },
                      itemCount: stateInitialized.galleryViews.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width ~/ 170,
                          childAspectRatio: GalleryViewCard.aspectRatio(
                            MediaQuery.of(context).size.width,
                          ),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8),
                    )
                  : const SizedBox()),
          if (state is! ServiceViewInitialized<AnimeApiClient,
                  AnimeGalleryView> &&
              state is! ServiceViewError<AnimeApiClient, AnimeGalleryView>)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          else if (state is ServiceViewError<AnimeApiClient, AnimeGalleryView>)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: stateError.retry,
                            icon: const Icon(Icons.refresh),
                            splashRadius: 18,
                          ),
                          Text(
                            S.current.service_view_retry_button_title,
                            style:
                                regular(color: AppColors.mainWhite, size: 14),
                          )
                        ],
                      ),
                      Text(S.current.service_view_error,
                          style: regular(color: AppColors.mainWhite, size: 18)),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.webhook),
                            onPressed: () {
                              openWebView(context, apiClient, configInfo);
                            },
                            splashRadius: 18,
                          ),
                          Text(
                            S.current.service_view_open_web_view_button_title,
                            style:
                                regular(color: AppColors.mainWhite, size: 14),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSearchableAppBar(
    BuildContext context,
    ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>? state,
  ) =>
      ServiceViewerAppBar(
        configInfo: configInfo,
        apiClient: apiClient,
        state: state,
        searchController: searchController,
        cubit:
            context.read<ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>(),
      );

  void _onGalleryViewClick(BuildContext context, AnimeGalleryView e) {
    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
        arguments: AnimeConcreteViewerData(
            client: apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: configInfo));
  }
}
