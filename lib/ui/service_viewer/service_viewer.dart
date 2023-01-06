import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/web_browser_interceptor.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/service_viewer/filters/filters_page.dart';
import 'package:wakaranai/ui/service_viewer/gallery_view_card.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/logger.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

import '../routes.dart';
import 'concrete_viewer/concrete_viewer.dart';

class ServiceViewData {
  final ApiClient apiClient;
  final ConfigInfo configInfo;

  const ServiceViewData({
    required this.apiClient,
    required this.configInfo,
  });
}

class ServiceView extends StatefulWidget {
  const ServiceView(
      {Key? key, required this.apiClient, required this.configInfo})
      : super(key: key);

  final ApiClient apiClient;
  final ConfigInfo configInfo;

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final GlobalKey _scaffold = GlobalKey();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  final Completer<bool> _interceptorInitCompleter = Completer();
  final Completer<bool> _protectorInitCompleter = Completer();

  late Future<bool> _interceptorInitDone;
  late Future<bool> _protectorInitDone;

  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _interceptorInitDone = _interceptorInitCompleter.future;
    _protectorInitDone = _protectorInitCompleter.future;

    _initDone =
        !(widget.configInfo.protectorConfig?.inAppBrowserInterceptor ?? false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initDone) {
        _interceptorInitDone.then((_) {
          _initProtector().then((value) {
            logger.i("Init after interceptor and protector");
            _scaffold.currentContext?.read<ServiceViewCubit>().init();
          });
        });
      } else if (widget.configInfo.protectorConfig != null) {
        _initProtector().then((value) {
          logger.i("init after protector");
          _scaffold.currentContext?.read<ServiceViewCubit>().init();
        });
      } else {
        logger.i("Init no protector");
        _scaffold.currentContext?.read<ServiceViewCubit>().init();
      }
    });
  }

  Future<bool> _initProtector() async {
    await _init().then((value) {
      _protectorInitCompleter.complete(true);
      _initDone = true;
      setState(() {});
    });
    return _protectorInitDone;
  }

  Future<void> _init() async {
    final uid = '${widget.configInfo.name}_${widget.configInfo.version}';

    final cachedProtector = await ProtectorStorageService().getItem(uid: uid);
    if (cachedProtector == null) {
      final result = await Navigator.of(context).pushNamed(Routes.webBrowser,
          arguments:
              WebBrowserData(config: widget.configInfo.protectorConfig!));
      if (result != null) {
        await widget.apiClient
            .passProtector(data: result as Map<String, dynamic>);
        await ProtectorStorageService()
            .saveItem(item: ProtectorStorageItem(uid: uid, headers: result));
      } else {
        return;
      }
    } else if (widget.configInfo.protectorConfig != null) {
      await widget.apiClient.passProtector(data: cachedProtector.headers);
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.home, (route) => false);
        return Future.value(false);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ServiceViewCubit>(create: (context) {
            final cubit =
                ServiceViewCubit(ServiceViewInitial(client: widget.apiClient));

            if (_initDone) {
              cubit.init();
            }

            return cubit;
          }),
          if (widget.configInfo.protectorConfig?.inAppBrowserInterceptor ??
              false)
            BlocProvider<BrowserInterceptorCubit>(create: (context) {
              final cubit = BrowserInterceptorCubit();
              widget.apiClient
                  .passWebBrowserInterceptorController(controller: cubit);
              return cubit;
            })
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<ServiceViewCubit, ServiceViewState>(
              listener: (context, state) {
                if (state is ServiceViewInitialized) {
                  _refreshController.loadComplete();
                }
              },
            ),
          ],
          child: Stack(
            children: [
              // _buildBody(),
              if (widget.configInfo.protectorConfig?.inAppBrowserInterceptor ??
                  false)
                WebBrowserInterceptorWidget(
                  initUrl: widget.configInfo.protectorConfig!.pingUrl,
                  initCompleter: _interceptorInitCompleter,
                ),
              _buildBody()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ServiceViewCubit, ServiceViewState>(
      builder: (context, state) {
        return Scaffold(
          key: _scaffold,
          backgroundColor: AppColors.backgroundColor,
          extendBodyBehindAppBar: true,
          endDrawer: Container(
            decoration: BoxDecoration(
                color: AppColors.backgroundColor.withOpacity(0.90)),
            child: state is ServiceViewInitialized
                ? FiltersPage(state: state)
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
          ),
          body: Stack(
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
                    context.read<ServiceViewCubit>().getGallery();
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
                          flexibleSpace: _buildSearchableAppBar(context,
                              state is ServiceViewInitialized ? state : null),
                        ),
                        if (state is ServiceViewInitialized)
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 16),
                            sliver: SliverGrid.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio:
                                  (MediaQuery.of(context).size.width * .5) /
                                      GalleryViewCard.height,
                              children: state.galleryViews
                                  .map((e) => GalleryViewCard(
                                        data: e,
                                        onTap: () {
                                          _onGalleryViewClick(context, e);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                      ])),
              if (state is! ServiceViewInitialized &&
                  state is! ServiceViewError)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              else if (state is ServiceViewError)
                Center(
                  child: Column(
                    children: const [
                      Text("Error :c"),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Timer? _searchTimer;

  Widget _buildSearchableAppBar(
          BuildContext context, ServiceViewInitialized? state) =>
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
                          onPressed: () async {
                            final config =
                                await widget.apiClient.getConfigInfo();
                            final uid = '${config.name}_${config.version}';
                            final result = await Navigator.of(context)
                                .pushNamed(Routes.webBrowser,
                                    arguments: WebBrowserData(
                                        config: config.protectorConfig!,
                                        protectorStorageItem:
                                            await ProtectorStorageService()
                                                .getItem(uid: uid)));
                            if (result != null) {
                              await widget.apiClient.passProtector(
                                  data: result as Map<String, dynamic>);
                              await ProtectorStorageService().saveItem(
                                  item: ProtectorStorageItem(
                                      uid: uid, headers: result));
                            } else {
                              return;
                            }
                          },
                        ))
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
                          .read<ServiceViewCubit>()
                          .search(_searchController.text);
                    },
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

  void _onGalleryViewClick(BuildContext context, GalleryView e) {
    Navigator.of(context).pushNamed(Routes.concreteViewer,
        arguments: ConcreteViewerData(
            client: widget.apiClient,
            uid: e.uid,
            galleryView: e,
            configInfo: widget.configInfo));
  }
}
