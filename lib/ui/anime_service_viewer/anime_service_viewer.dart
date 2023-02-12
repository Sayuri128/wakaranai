import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/local_gallery_view_card/local_gallery_view_card_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/api_controller_wrapper.dart';
import 'package:wakaranai/ui/home/home_view.dart';
import 'package:wakaranai/ui/home/service_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/local_gallery_view_wrapper.dart';
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
        builder: (context, interceptorInitCompleter) {
          return WillPopScope(
            onWillPop: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (route) => false);
              return Future.value(false);
            },
            child: ServiceViewCubitWrapper<AnimeApiClient, AnimeGalleryView>(
              client: apiClient,
              builder: (context, state) => _wrapBrowserInterceptor(
                  child: BlocListener<
                      ServiceViewCubit<AnimeApiClient, AnimeGalleryView>,
                      ServiceViewState<AnimeApiClient, AnimeGalleryView>>(
                    listener: (context, state) {
                      if (state is ServiceViewInitialized<AnimeApiClient,
                          AnimeGalleryView>) {
                        _refreshController.loadComplete();
                      }
                    },
                    child: _buildBody(context, apiClient, state),
                  ),
                  apiClient: apiClient,
                  interceptorInitCompleter: interceptorInitCompleter),
            ),
          );
        },
        onInterceptorInitialized: () {
          _scaffold.currentContext
              ?.read<ServiceViewCubit<AnimeApiClient, AnimeGalleryView>>()
              .init(widget.data.remoteConfig);
        },
        configInfo: widget.data.remoteConfig.config,
        apiClient: apiClient);
  }

  Widget _wrapBrowserInterceptor(
      {required Widget child,
      required AnimeApiClient apiClient,
      required Completer<bool> interceptorInitCompleter}) {
    if (widget.data.remoteConfig.config.protectorConfig
            ?.inAppBrowserInterceptor ??
        false) {
      return BlocProvider<BrowserInterceptorCubit>(
        lazy: false,
        create: (context) {
          final cubit = BrowserInterceptorCubit()
            ..init(
                url: widget.data.remoteConfig.config.protectorConfig!.pingUrl,
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

  Widget _buildBody(BuildContext context, AnimeApiClient apiClient,
      ServiceViewState<AnimeApiClient, AnimeGalleryView> state) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              widget.data.remoteConfig.config.searchAvailable ? 80 : 60),
          child: _buildSearchableAppBar(
              context,
              state is ServiceViewInitialized<AnimeApiClient, AnimeGalleryView>
                  ? state
                  : null,
              apiClient)),
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
                        final galleryView = state.galleryViews[index];
                        return LocalGalleryViewWrapper(
                          uid: galleryView.uid,
                          type: LocalApiClientType.ANIME,
                          builder: (context, state) => GalleryViewCard(
                            inLibrary: state is LocalGalleryViewCardLoaded &&
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
                                  canAdd: state is LocalGalleryViewCardLoaded &&
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
                            onPressed: state.retry,
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
                              openWebView(context, apiClient,
                                  widget.data.remoteConfig.config);
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
          AnimeApiClient apiClient) =>
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
                          .read<
                              ServiceViewCubit<AnimeApiClient,
                                  AnimeGalleryView>>()
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
          type: LocalApiClientType.ANIME,
          galleryView: galleryView,
          remoteConfig: widget.data.remoteConfig,
          client: apiClient,
          onDone: () {
            showNotificationSnackBar(
                context,
                S.current.gallery_view_anime_item_added_to_library_notification(
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
          context.read<LocalGalleryViewCardCubit>().delete(
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
