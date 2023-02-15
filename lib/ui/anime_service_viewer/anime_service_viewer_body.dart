import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/data/gallery/local_anime_gallery_view.dart';
import 'package:wakaranai/models/data/library/library_anime_item.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/home_view.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/local_gallery_view_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

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
              configInfo.searchAvailable ? 80 : 60),
          child: _buildSearchableAppBar(
              context,
              state is ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>
                  ? stateInitialized
                  : null)),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SmartRefresher(
              enablePullUp: true,
              enablePullDown: false,
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.loading) {
                    return Column(
                      children: const [
                        SizedBox(
                          height: 24,
                        ),
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(
                          height: 24,
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
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
                      itemBuilder: (context, index) {
                        final galleryView =
                            stateInitialized.galleryViews[index];
                        return LocalGalleryViewWrapper<LibraryAnimeItem,
                            LocalAnimeGalleryView>(
                          uid: galleryView.uid,
                          type: ConfigInfoType.ANIME,
                          builder: (context, state) => GalleryViewCard(
                            inLibrary: state is LocalGalleryViewCardLoaded<
                                    LibraryAnimeItem, LocalAnimeGalleryView> &&
                                state.libraryItem != null,
                            cover: galleryView.cover,
                            uid: galleryView.uid,
                            title: galleryView.title,
                            onLongPress: () {
                              if (state is LocalGalleryViewCardInitial) {
                                return;
                              }
                              _onLongGalleryViewPress(context,
                                  galleryView: galleryView,
                                  canAdd: state is LocalGalleryViewCardLoaded<
                                          LibraryAnimeItem,
                                          LocalAnimeGalleryView> &&
                                      state.libraryItem == null);
                            },
                            onTap: () {
                              _onGalleryViewClick(context, galleryView);
                            },
                          ),
                        );
                      },
                      itemCount: stateInitialized.galleryViews.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: GalleryViewCard.aspectRatio,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8))
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

  Widget _buildSearchableAppBar(BuildContext context,
          ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>? state) =>
      Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    configInfo.name,
                    style: medium(size: 24),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.webhook,
                      color: configInfo.protectorConfig != null
                          ? AppColors.mainWhite
                          : Colors.transparent,
                    ),
                    onPressed: configInfo.protectorConfig != null
                        ? () {
                            openWebView(context, apiClient, configInfo);
                          }
                        : null)
              ],
            ),
            if (state != null && configInfo.searchAvailable)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      context
                          .read<
                              ServiceViewCubit<AnimeApiClient,
                                  AnimeGalleryView>>()
                          .search(searchController.text);
                    },
                    cursorColor: AppColors.primary,
                    style: medium(size: 16),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 4.0),
                        isCollapsed: true,
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                        hintText:
                            S.current.service_viewer_search_field_hint_text,
                        hintStyle: medium(size: 16)),
                  ),
                ),
              )
          ],
        ),
      );

  void _onLongGalleryViewPress(BuildContext context,
      {required AnimeGalleryView galleryView, required bool canAdd}) {
    if (canAdd) {
      context
          .read<
              LocalGalleryViewCardCubit<LibraryAnimeItem,
                  LocalAnimeGalleryView>>()
          .create(
              galleryView: galleryView,
              configInfo: configInfo,
              client: apiClient,
              onDone: () {
                showNotificationSnackBar(
                    context,
                    S.current
                        .gallery_view_anime_item_added_to_library_notification(
                            galleryView.title));
              });
    } else {
      showOkCancelAlertDialog(
              context: context,
              title: S.current
                  .gallery_view_anime_item_delete_from_library_confirmation_title(
                      galleryView.title),
              okLabel: S.current
                  .gallery_view_anime_item_delete_from_library_confirmation_ok_label,
              cancelLabel: S.current
                  .gallery_view_anime_item_delete_from_library_confirmation_cancel_label)
          .then((value) {
        if (value == OkCancelResult.ok) {
          context
              .read<
                  LocalGalleryViewCardCubit<LibraryAnimeItem,
                      LocalAnimeGalleryView>>()
              .delete(
            () {
              showNotificationSnackBar(
                  context,
                  S.current
                      .gallery_view_anime_item_deleted_from_library_notification(
                          galleryView.title));
            },
          );
        }
      });
    }
  }

  void _onGalleryViewClick(BuildContext context, AnimeGalleryView e) {
    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
        arguments: AnimeConcreteViewerData(
            client: apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: configInfo));
  }
}
