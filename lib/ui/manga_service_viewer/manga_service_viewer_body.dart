import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/data/library_manga_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/home_view.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/local_gallery_view_wrapper.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class MangaServiceViewBody extends StatelessWidget {
  const MangaServiceViewBody(
      {Key? key,
      required this.scaffold,
      required this.state,
      required this.apiClient,
      required this.configInfo,
      required this.refreshController,
      required this.searchController})
      : super(key: key);

  final ServiceViewState<MangaApiClient, MangaGalleryView> state;
  final GlobalKey scaffold;
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;

  final RefreshController refreshController;
  final TextEditingController searchController;

  ServiceViewInitialized<MangaApiClient, MangaGalleryView>
      get stateInitialized =>
          state as ServiceViewInitialized<MangaApiClient, MangaGalleryView>;

  ServiceViewError<MangaApiClient, MangaGalleryView> get stateError =>
      state as ServiceViewError<MangaApiClient, MangaGalleryView>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              configInfo.searchAvailable ? 80 : 60),
          child: _buildSearchableAppBar(
              context,
              state is ServiceViewInitialized<MangaApiClient, MangaGalleryView>
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
                if (state
                    is! ServiceViewLoading<MangaApiClient, MangaGalleryView>) {
                  context
                      .read<
                          ServiceViewCubit<MangaApiClient, MangaGalleryView>>()
                      .getGallery();
                }
              },
              child: state is ServiceViewInitialized<MangaApiClient,
                      MangaGalleryView>
                  ? GridView.builder(
                      itemBuilder: (context, index) {
                        final galleryView =
                            stateInitialized.galleryViews[index];
                        return LocalGalleryViewWrapper<LibraryMangaItem,
                            LocalMangaGalleryView>(
                          uid: galleryView.uid,
                          type: ConfigInfoType.MANGA,
                          builder: (context, state) => GalleryViewCard(
                            inLibrary: state is LocalGalleryViewCardLoaded<
                                    LibraryMangaItem, LocalMangaGalleryView> &&
                                state.libraryItem != null,
                            cover: galleryView.cover,
                            uid: galleryView.uid,
                            title: galleryView.title,
                            onLongPress: () {
                              if (state is LocalGalleryViewCardInitial<
                                  LibraryMangaItem, LocalMangaGalleryView>) {
                                return;
                              }
                              _onLongGalleryViewPress(context,
                                  galleryView: galleryView,
                                  canAdd: state is LocalGalleryViewCardLoaded<
                                          LibraryMangaItem,
                                          LocalMangaGalleryView> &&
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
          if (state is! ServiceViewInitialized<MangaApiClient,
                  MangaGalleryView> &&
              state is! ServiceViewError<MangaApiClient, MangaGalleryView>)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          else if (state is ServiceViewError<MangaApiClient, MangaGalleryView>)
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

  void _onLongGalleryViewPress(BuildContext context,
      {required MangaGalleryView galleryView, required bool canAdd}) {
    if (canAdd) {
      context
          .read<
              LocalGalleryViewCardCubit<LibraryMangaItem,
                  LocalMangaGalleryView>>()
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
                  .gallery_view_manga_item_delete_from_library_confirmation_title(
                      galleryView.title),
              okLabel: S.current
                  .gallery_view_manga_item_delete_from_library_confirmation_ok_label,
              cancelLabel: S.current
                  .gallery_view_manga_item_delete_from_library_confirmation_cancel_label)
          .then((value) {
        if (value == OkCancelResult.ok) {
          context
              .read<
                  LocalGalleryViewCardCubit<LibraryMangaItem,
                      LocalMangaGalleryView>>()
              .delete(
            () {
              showNotificationSnackBar(
                  context,
                  S.current
                      .gallery_view_manga_item_deleted_from_library_notification(
                          galleryView.title));
            },
          );
        }
      });
    }
  }

  Widget _buildSearchableAppBar(BuildContext context,
          ServiceViewInitialized<MangaApiClient, MangaGalleryView>? state) =>
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
                              ServiceViewCubit<MangaApiClient,
                                  MangaGalleryView>>()
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

  void _onGalleryViewClick(BuildContext context, MangaGalleryView e) {
    Navigator.of(context).pushNamed(Routes.mangaConcreteViewer,
        arguments: MangaConcreteViewerData(
            client: apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: configInfo));
  }
}
