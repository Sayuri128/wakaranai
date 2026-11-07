import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_grid_skeleton.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_page.dart';
import 'package:wakaranai/ui/home/service_viewer_header.dart';
import 'package:wakaranai/ui/widgets/keep_alive_page.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ServiceViewerBody<T extends ApiClient, G extends GalleryView>
    extends StatefulWidget {
  const ServiceViewerBody({
    super.key,
    required this.kind,
    required this.scaffold,
    required this.apiClient,
    required this.configInfo,
    required this.searchController,
  });

  final ServiceGalleryKind<T, G> kind;
  final GlobalKey scaffold;
  final T apiClient;
  final ConfigInfo configInfo;
  final TextEditingController searchController;

  @override
  State<ServiceViewerBody<T, G>> createState() =>
      _ServiceViewerBodyState<T, G>();
}

class _ServiceViewerBodyState<T extends ApiClient, G extends GalleryView>
    extends State<ServiceViewerBody<T, G>> {
  static const Duration _pageAnimationDuration = Duration(milliseconds: 300);

  late final ServiceGalleryCubit<T, G> _gallery =
      context.read<ServiceGalleryCubit<T, G>>();
  late final PageController _pageController = PageController(
    initialPage: _gallery.selectedFeedIndex,
  );
  int? _tabAnimationTarget;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceGalleryCubit<T, G>, ServiceGalleryState>(
      bloc: _gallery,
      builder: (BuildContext context, ServiceGalleryState galleryState) {
        return Scaffold(
          key: widget.scaffold,
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: <Widget>[
              ServiceViewerHeader(
                configInfo: widget.configInfo,
                apiClient: widget.apiClient,
                searchController: widget.searchController,
                gallery: _gallery,
              ),
              if (_gallery.hasFeeds) _buildFeedTabs(galleryState),
              _buildSearchChip(galleryState),
              Expanded(child: _buildGalleries(galleryState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedTabs(ServiceGalleryState galleryState) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: galleryState.searching
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SegmentedTabs(
                labels: <String>[
                  for (final GalleryFeed feed in _gallery.feeds) feed.title,
                ],
                selectedIndex: _gallery.selectedFeedIndex,
                pageController: _pageController,
                semanticsLabel: S.of(context).feeds_row_label,
                onSelected: (int index) => unawaited(_onTabSelected(index)),
              ),
            ),
    );
  }

  Future<void> _onTabSelected(int index) async {
    _gallery.selectFeed(_gallery.feeds[index].id);
    if (!_pageController.hasClients) {
      return;
    }
    _tabAnimationTarget = index;
    await _pageController.animateToPage(
      index,
      duration: _pageAnimationDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted || _tabAnimationTarget != index) {
      return;
    }
    _tabAnimationTarget = null;
    _selectFeedAtCurrentPage();
  }

  void _onPageChanged(int index) {
    if (_tabAnimationTarget != null) {
      return;
    }
    _gallery.selectFeed(_gallery.feeds[index].id);
  }

  void _selectFeedAtCurrentPage() {
    if (!_pageController.hasClients) {
      return;
    }
    final double? page = _pageController.page;
    if (page == null) {
      return;
    }
    _gallery.selectFeed(_gallery.feeds[page.round()].id);
  }

  Widget _buildSearchChip(ServiceGalleryState galleryState) {
    final ServiceViewCubit<T, G>? single = _gallery.singleGallery;
    if (single == null) {
      return _buildSearchChipFor(galleryState.searchQuery);
    }
    return BlocBuilder<ServiceViewCubit<T, G>, ServiceViewState<T, G>>(
      bloc: single,
      builder: (BuildContext context, ServiceViewState<T, G> state) {
        if (state is ServiceViewInitialized<T, G>) {
          return _buildSearchChipFor(state.searchQuery);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchChipFor(String searchQuery) {
    if (searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          backgroundColor: AppColors.overlay(0.08),
          side: BorderSide.none,
          label: Text(
            S.of(context).service_view_search_results_for(searchQuery),
            style: regular(size: 13),
          ),
          deleteIconColor: AppColors.mainGrey,
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          onDeleted: () {
            widget.searchController.clear();
            _gallery.search('');
          },
        ),
      ),
    );
  }

  Widget _buildGalleries(ServiceGalleryState galleryState) {
    final ServiceViewCubit<T, G>? single = _gallery.singleGallery;
    if (single != null) {
      return _buildGalleryPage(single, active: true);
    }
    final ServiceViewCubit<T, G>? search = _gallery.searchGallery;
    final bool searching = galleryState.searching && search != null;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Offstage(
          offstage: searching,
          child: TickerMode(
            enabled: !searching,
            child: HeroMode(
              enabled: !searching,
              child: _buildFeedPages(galleryState, searching: searching),
            ),
          ),
        ),
        if (searching)
          _buildGalleryPage(search, active: true, key: ObjectKey(search)),
      ],
    );
  }

  Widget _buildFeedPages(
    ServiceGalleryState galleryState, {
    required bool searching,
  }) {
    final List<GalleryFeed> feeds = _gallery.feeds;
    return PageView.builder(
      controller: _pageController,
      itemCount: feeds.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        final GalleryFeed feed = feeds[index];
        final bool selected = feed.id == galleryState.selectedFeedId;
        return KeepAlivePage(
          key: ValueKey<String>(feed.id),
          child: HeroMode(
            enabled: selected,
            child: _buildFeedPage(feed, active: selected && !searching),
          ),
        );
      },
    );
  }

  Widget _buildFeedPage(GalleryFeed feed, {required bool active}) {
    final ServiceViewCubit<T, G>? cubit = _gallery.feedGallery(feed.id);
    if (cubit == null) {
      return BlocBuilder<GalleryLayoutCubit, GalleryLayout>(
        builder: (BuildContext context, GalleryLayout layout) =>
            GalleryGridSkeleton(layout: layout),
      );
    }
    return _buildGalleryPage(cubit, active: active);
  }

  Widget _buildGalleryPage(
    ServiceViewCubit<T, G> cubit, {
    required bool active,
    Key? key,
  }) {
    return ServiceGalleryPage<T, G>(
      key: key,
      kind: widget.kind,
      cubit: cubit,
      apiClient: widget.apiClient,
      configInfo: widget.configInfo,
      active: active,
    );
  }
}
