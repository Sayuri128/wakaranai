import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/service_viewer/gallery_view_card.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';

import '../routes.dart';
import 'concrete_viewer/concrete_viewer.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({Key? key, required this.apiClient}) : super(key: key);

  final ApiClient apiClient;

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

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
          BlocProvider<ServiceViewCubit>(
              create: (context) =>
                  ServiceViewCubit(ServiceViewInitial(client: widget.apiClient))
                    ..init())
        ],
        child: BlocListener<ServiceViewCubit, ServiceViewState>(
          listener: (context, state) {
            if (state is ServiceViewInitialized) {
              _refreshController.loadComplete();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            extendBodyBehindAppBar: true,
            body: BlocBuilder<ServiceViewCubit, ServiceViewState>(
              builder: (context, state) {
                return SmartRefresher(
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
                              CircularProgressIndicator(),
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
                    child: state is ServiceViewInitialized
                        ? CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                                SliverAppBar(
                                  floating: true,
                                  backgroundColor: AppColors.backgroundColor,
                                  elevation: 0,
                                  expandedHeight: 50,
                                  toolbarHeight:
                                      state.client.isSearchByQueryAvailable()
                                          ? 70
                                          : 40,
                                  flexibleSpace: state.client
                                          .isSearchByQueryAvailable()
                                      ? _buildSearchableAppBar(context, state)
                                      : _buildTitleAppBar(state),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.only(top: 16),
                                  sliver: SliverGrid.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio:
                                        (MediaQuery.of(context).size.width *
                                                .5) /
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
                              ])
                        : const Center(
                            child: CircularProgressIndicator(),
                          ));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAppBar(ServiceViewInitialized state) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Center(
          child: Text(
        state.configInfo.name,
        style: medium(size: 24),
      )),
    );
  }

  Timer? _searchTimer;

  Widget _buildSearchableAppBar(
          BuildContext context, ServiceViewInitialized state) =>
      Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
                child: Text(
              state.configInfo.name,
              style: medium(size: 24),
            )),
            const SizedBox(
              height: 8,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchTimer?.cancel();
                    _searchTimer = Timer(const Duration(seconds: 1), () {
                      context
                          .read<ServiceViewCubit>()
                          .search(_searchController.text);
                    });
                  },
                  onSubmitted: (value) {
                    _searchTimer?.cancel();
                    context
                        .read<ServiceViewCubit>()
                        .search(_searchController.text);
                  },
                  decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.accentGreen)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.accentGreen)),
                      hintText: S.current.service_viewer_search_field_hint_text,
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
        arguments: ConcreteViewerData(client: widget.apiClient, uid: e.uid));
  }
}