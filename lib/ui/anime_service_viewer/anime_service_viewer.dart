import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/anime_service_view/anime_service_view_cubit.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/local_gallery_view_wrapper.dart';
import 'package:wakaranai/ui/manga_service_viewer/filters/filters_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';

class AnimeServiceViewerData {
  final RemoteConfig remoteConfig;

  const AnimeServiceViewerData({required this.remoteConfig});
}

class AnimeServiceViewer extends StatefulWidget {
  const AnimeServiceViewer({Key? key, required this.data}) : super(key: key);

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
        remoteConfig: widget.data.remoteConfig, builder: _buildWidget);
  }

  Widget _buildWidget(AnimeApiClient apiClient) {
    return WebBrowserWrapper<AnimeApiClient>(
        builder: (context, interceptor) {
          return WillPopScope(
            onWillPop: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (route) => false);
              return Future.value(false);
            },
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AnimeServiceViewCubit>(
                    create: (context) => AnimeServiceViewCubit(
                        AnimeServiceViewInitial(client: apiClient))),
                if (widget.data.remoteConfig.config.protectorConfig
                        ?.inAppBrowserInterceptor ??
                    false)
                  BlocProvider<BrowserInterceptorCubit>(
                      lazy: false,
                      create: (context) {
                        final cubit = BrowserInterceptorCubit()
                          ..init(
                              url: widget.data.remoteConfig.config
                                  .protectorConfig!.pingUrl,
                              initCompleter: interceptor);
                        apiClient.passWebBrowserInterceptorController(
                            controller: cubit);
                        return cubit;
                      })
              ],
              child: MultiBlocListener(
                listeners: [
                  BlocListener<AnimeServiceViewCubit, AnimeServiceViewState>(
                    listener: (context, state) {
                      if (state is AnimeServiceViewInitialized) {
                        _refreshController.loadComplete();
                      }
                    },
                  ),
                ],
                child: _buildBody(apiClient),
              ),
            ),
          );
        },
        onInterceptorInitialized: () {
          _scaffold.currentContext
              ?.read<AnimeServiceViewCubit>()
              .init(widget.data.remoteConfig);
        },
        configInfo: widget.data.remoteConfig.config,
        apiClient: apiClient);
  }

  Widget _buildBody(AnimeApiClient apiClient) {
    return BlocBuilder<AnimeServiceViewCubit, AnimeServiceViewState>(
      builder: (context, state) {
        return Scaffold(
          key: _scaffold,
          backgroundColor: AppColors.backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width,
                  widget.data.remoteConfig.config.searchAvailable ? 80 : 60),
              child: _buildSearchableAppBar(
                  context,
                  state is AnimeServiceViewInitialized ? state : null,
                  apiClient)),
          endDrawer: Container(
            decoration: BoxDecoration(
                color: AppColors.backgroundColor.withOpacity(0.90)),
            child: state is AnimeServiceViewInitialized &&
                    state.configInfo.filters.isNotEmpty
                ? FiltersPage(
                    filters: state.configInfo.filters,
                    selectedFilters: state.selectedFilters)
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
          ),
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
                  controller: _refreshController,
                  onLoading: () {
                    context.read<AnimeServiceViewCubit>().getGallery();
                  },
                  child: state is AnimeServiceViewInitialized
                      ? GridView.builder(
                          itemBuilder: (context, index) {
                            final galleryView = state.galleryViews[index];
                            return LocalGalleryViewWrapper(
                              uid: galleryView.uid,
                              type: LibraryItemType.ANIME,
                              builder: (context, state) => GalleryViewCard(
                                inLibrary:
                                    state is LocalGalleryViewCardLoaded &&
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
                                      apiClient: apiClient,
                                      canAdd:
                                          state is LocalGalleryViewCardLoaded &&
                                              state.libraryItem == null);
                                },
                                onTap: () {
                                  _onGalleryViewClick(
                                      context, galleryView, apiClient);
                                },
                              ),
                            );
                          },
                          itemCount: state.galleryViews.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: GalleryViewCard.aspectRatio,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8))
                      : const SizedBox()),
              if (state is! AnimeServiceViewInitialized &&
                  state is! AnimeServiceViewError)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              else if (state is AnimeServiceViewError)
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
                                onPressed: state.retry,
                                icon: const Icon(Icons.refresh),
                                splashRadius: 18,
                              ),
                              Text(
                                S.current.service_view_retry_button_title,
                                style: regular(
                                    color: AppColors.mainWhite, size: 14),
                              )
                            ],
                          ),
                          Text(S.current.service_view_error,
                              style: regular(
                                  color: AppColors.mainWhite, size: 18)),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.webhook),
                                onPressed: () {
                                  openWebView(context, apiClient,
                                      widget.data.remoteConfig.config);
                                },
                                splashRadius: 18,
                              ),
                              Text(
                                S.current
                                    .service_view_open_web_view_button_title,
                                style: regular(
                                    color: AppColors.mainWhite, size: 14),
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
      },
    );
  }

  Widget _buildSearchableAppBar(BuildContext context,
          AnimeServiceViewInitialized? state, AnimeApiClient apiClient) =>
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
                    widget.data.remoteConfig.config.name,
                    style: medium(size: 24),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.webhook,
                      color: widget.data.remoteConfig.config.protectorConfig !=
                              null
                          ? AppColors.mainWhite
                          : Colors.transparent,
                    ),
                    onPressed:
                        widget.data.remoteConfig.config.protectorConfig != null
                            ? () {
                                openWebView(context, apiClient,
                                    widget.data.remoteConfig.config);
                              }
                            : null)
              ],
            ),
            if (state != null &&
                widget.data.remoteConfig.config.searchAvailable)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      context
                          .read<AnimeServiceViewCubit>()
                          .search(_searchController.text);
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
      {required AnimeGalleryView galleryView,
      required AnimeApiClient apiClient,
      required bool canAdd}) {
    if (canAdd) {
      context.read<LocalGalleryViewCardCubit>().create(
          LibraryItem(
              localApiClient: LocalApiClient.fromApiClient(
                  apiClient, widget.data.remoteConfig.config),
              localGalleryView: LocalAnimeGalleryView.fromRemote(galleryView),
              type: LibraryItemType.ANIME,
              galleryViewId: galleryView.uid), () {
        _showNotificationSnackBar(
            context,
            S.current.gallery_view_anime_item_added_to_library_notification(
                galleryView.title));
      });
    } else {
      showConfirmationDialog(
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
          context.read<LocalGalleryViewCardCubit>().delete(
            () {
              _showNotificationSnackBar(
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

  void _showNotificationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.backgroundColor,
        content: Text(
          message,
          style: medium(size: 16),
        )));
  }

  void _onGalleryViewClick(
      BuildContext context, AnimeGalleryView e, AnimeApiClient apiClient) {
    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
        arguments: AnimeConcreteViewerData(
            client: apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: widget.data.remoteConfig.config));
  }
}
