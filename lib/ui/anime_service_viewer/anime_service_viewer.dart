import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/anime_service_view/anime_service_view_cubit.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/manga_service_viewer/filters/filters_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/service_viewer/service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

import '../../models/protector/protector_storage_item.dart';

class AnimeServiceViewerData {
  final AnimeApiClient apiClient;
  final ConfigInfo configInfo;

  const AnimeServiceViewerData({
    required this.apiClient,
    required this.configInfo,
  });
}

class AnimeServiceViewer extends StatefulWidget {
  const AnimeServiceViewer({Key? key, required this.data}) : super(key: key);

  final AnimeServiceViewerData data;

  AnimeApiClient get apiClient => data.apiClient;

  ConfigInfo get configInfo => data.configInfo;

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
    return ServiceViewer<AnimeApiClient>(
        builder: (context, initDone, interceptor) {
          return WillPopScope(
            onWillPop: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (route) => false);
              return Future.value(false);
            },
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AnimeServiceViewCubit>(create: (context) {
                  final cubit = AnimeServiceViewCubit(
                      AnimeServiceViewInitial(client: widget.data.apiClient));

                  if (initDone) {
                    cubit.init();
                  }

                  return cubit;
                }),
                if (widget.data.configInfo.protectorConfig
                        ?.inAppBrowserInterceptor ??
                    false)
                  BlocProvider<BrowserInterceptorCubit>(
                      lazy: false,
                      create: (context) {
                        final cubit = BrowserInterceptorCubit()
                          ..init(
                              url: widget
                                  .data.configInfo.protectorConfig!.pingUrl,
                              initCompleter: interceptor);
                        widget.data.apiClient
                            .passWebBrowserInterceptorController(
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
                child: _buildBody(),
              ),
            ),
          );
        },
        onInterceptorInitialized: () {
          _scaffold.currentContext?.read<AnimeServiceViewCubit>().init();
        },
        configInfo: widget.data.configInfo,
        apiClient: widget.data.apiClient);
  }

  Widget _buildBody() {
    return BlocBuilder<AnimeServiceViewCubit, AnimeServiceViewState>(
      builder: (context, state) {
        return Scaffold(
          key: _scaffold,
          backgroundColor: AppColors.backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width,
                  widget.configInfo.searchAvailable ? 80 : 60),
              child: _buildSearchableAppBar(context,
                  state is AnimeServiceViewInitialized ? state : null)),
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
                            final e = state.galleryViews[index];
                            return GalleryViewCard(
                              cover: e.cover,
                              uid: e.uid,
                              title: e.title,
                              onTap: () {
                                _onGalleryViewClick(context, e);
                              },
                            );
                          },
                          itemCount: state.galleryViews.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                onPressed: _openWebView,
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

  Widget _buildSearchableAppBar(
          BuildContext context, AnimeServiceViewInitialized? state) =>
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
                    widget.configInfo.name,
                    style: medium(size: 24),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.webhook,
                      color: widget.configInfo.protectorConfig != null
                          ? AppColors.mainWhite
                          : Colors.transparent,
                    ),
                    onPressed: widget.configInfo.protectorConfig != null
                        ? _openWebView
                        : null)
              ],
            ),
            if (state != null && widget.data.configInfo.searchAvailable)
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
                        contentPadding: EdgeInsets.only(bottom: 4.0),
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

  void _onGalleryViewClick(BuildContext context, AnimeGalleryView e) {
    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
        arguments: AnimeConcreteViewerData(
            client: widget.apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: widget.configInfo));
  }

  Future<void> _openWebView() async {
    final config = await widget.data.apiClient.getConfigInfo();
    final uid = '${config.name}_${config.version}';
    final result = await Navigator.of(context).pushNamed(Routes.webBrowser,
        arguments: WebBrowserData(
            config: config.protectorConfig!,
            protectorStorageItem:
                await ProtectorStorageService().getItem(uid: uid)));
    if (result != null) {
      await widget.data.apiClient
          .passProtector(data: result as Map<String, dynamic>);
      await ProtectorStorageService()
          .saveItem(item: ProtectorStorageItem(uid: uid, headers: result));
    } else {
      return;
    }
  }
}
