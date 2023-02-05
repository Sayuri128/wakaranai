import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/manga_service_view/manga_service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/manga_service_viewer/filters/filters_page.dart';
import 'package:wakaranai/ui/service_viewer/service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

import '../routes.dart';
import 'concrete_viewer/manga_concrete_viewer.dart';

class MangaServiceViewData {
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;

  const MangaServiceViewData({
    required this.apiClient,
    required this.configInfo,
  });
}

class MangaServiceView extends StatefulWidget {
  const MangaServiceView({Key? key, required this.data}) : super(key: key);

  final MangaServiceViewData data;

  MangaApiClient get apiClient => data.apiClient;

  ConfigInfo get configInfo => data.configInfo;

  @override
  State<MangaServiceView> createState() => _MangaServiceViewState();
}

class _MangaServiceViewState extends State<MangaServiceView> {
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
    return ServiceViewer<MangaApiClient>(
        apiClient: widget.apiClient,
        builder: (context, initDone, interceptorInitCompleter) {
          return WillPopScope(
            onWillPop: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.home, (route) => false);
              return Future.value(false);
            },
            child: MultiBlocProvider(
              providers: [
                BlocProvider<MangaServiceViewCubit>(create: (context) {
                  final cubit = MangaServiceViewCubit(
                      MangaServiceViewInitial(client: widget.apiClient));

                  if (initDone) {
                    cubit.init();
                  }

                  return cubit;
                }),
                if (widget
                        .configInfo.protectorConfig?.inAppBrowserInterceptor ??
                    false)
                  BlocProvider<BrowserInterceptorCubit>(
                      lazy: false,
                      create: (context) {
                        final cubit = BrowserInterceptorCubit()
                          ..init(
                              url: widget.configInfo.protectorConfig!.pingUrl,
                              initCompleter: interceptorInitCompleter);
                        widget.apiClient.passWebBrowserInterceptorController(
                            controller: cubit);
                        return cubit;
                      })
              ],
              child: MultiBlocListener(
                listeners: [
                  BlocListener<MangaServiceViewCubit, MangaServiceViewState>(
                    listener: (context, state) {
                      if (state is MangaServiceViewInitialized) {
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
          _scaffold.currentContext?.read<MangaServiceViewCubit>().init();
        },
        configInfo: widget.configInfo);
  }

  Widget _buildBody() {
    return BlocBuilder<MangaServiceViewCubit, MangaServiceViewState>(
      builder: (context, state) {
        return Scaffold(
          key: _scaffold,
          backgroundColor: AppColors.backgroundColor,
          extendBodyBehindAppBar: true,
          endDrawer: Container(
            decoration: BoxDecoration(
                color: AppColors.backgroundColor.withOpacity(0.90)),
            child: state is MangaServiceViewInitialized &&
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
                    context.read<MangaServiceViewCubit>().getGallery();
                  },
                  child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0))),
                          backgroundColor: AppColors.backgroundColor,
                          elevation: 0,
                          expandedHeight:
                              widget.configInfo.searchAvailable ? 70 : 30,
                          toolbarHeight:
                              widget.configInfo.searchAvailable ? 110 : 70,
                          actions: const [SizedBox()],
                          flexibleSpace: _buildSearchableAppBar(
                              context,
                              state is MangaServiceViewInitialized
                                  ? state
                                  : null),
                        ),
                        if (state is MangaServiceViewInitialized)
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 16),
                            sliver: SliverGrid.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: GalleryViewCard.aspectRatio,
                              children: state.galleryViews
                                  .map((e) => GalleryViewCard(
                                        title: e.title,
                                        uid: e.uid,
                                        cover: e.cover,
                                        onTap: () {
                                          _onGalleryViewClick(context, e);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                      ])),
              if (state is! MangaServiceViewInitialized &&
                  state is! MangaServiceViewError)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              else if (state is MangaServiceViewError)
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
          BuildContext context, MangaServiceViewInitialized? state) =>
      Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    widget.configInfo.name,
                    style: medium(size: 24),
                  )),
                  if (widget.configInfo.protectorConfig != null)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                            icon: const Icon(Icons.webhook),
                            onPressed: _openWebView))
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (state != null && widget.configInfo.searchAvailable)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      context
                          .read<MangaServiceViewCubit>()
                          .search(_searchController.text);
                    },
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                        hintText:
                            S.current.service_viewer_search_field_hint_text,
                        hintStyle: medium()),
                  ),
                ),
              ),
            const SizedBox(
              height: 16.0,
            )
          ],
        ),
      );

  void _onGalleryViewClick(BuildContext context, MangaGalleryView e) {
    Navigator.of(context).pushNamed(Routes.mangaConcreteViewer,
        arguments: MangaConcreteViewerData(
            client: widget.apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: widget.configInfo));
  }

  Future<void> _openWebView() async {
    final config = await widget.apiClient.getConfigInfo();
    final uid = '${config.name}_${config.version}';
    final result = await Navigator.of(context).pushNamed(Routes.webBrowser,
        arguments: WebBrowserData(
            config: config.protectorConfig!,
            protectorStorageItem:
                await ProtectorStorageService().getItem(uid: uid)));
    if (result != null) {
      await widget.apiClient
          .passProtector(data: result as Map<String, dynamic>);
      await ProtectorStorageService()
          .saveItem(item: ProtectorStorageItem(uid: uid, headers: result));
    } else {
      return;
    }
  }
}
