import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/bottom_modal_settings.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/settings_overlay.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class ChapterViewerData {
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;
  final ChaptersGroup group;
  final MangaGalleryView galleryView;
  final Chapter chapter;

  const ChapterViewerData({
    required this.apiClient,
    required this.configInfo,
    required this.group,
    required this.galleryView,
    required this.chapter,
  });
}

class ChapterViewer extends StatefulWidget {
  const ChapterViewer({Key? key, required this.data}) : super(key: key);

  final ChapterViewerData data;

  @override
  State<ChapterViewer> createState() => _ChapterViewerState();
}

class _ChapterViewerState extends State<ChapterViewer>
    with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  final PageController _pageController = PageController(initialPage: 0);
  final ItemScrollController _itemScrollController = ItemScrollController();

  bool _showGestureOverlay = false;

  bool _canLoadNext = false;
  bool _canLoadPrevious = true;

  Map<String, String> _headers = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.data.configInfo.protectorConfig != null) {
        _headers = widget.data.apiClient.getProtectorHeaders();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<ChapterViewCubit>(
        create: (context) => ChapterViewCubit(
            apiClient: widget.data.apiClient,
            settingsCubit: context.read<SettingsCubit>(),
            pageController: _pageController,
            itemScrollController: _itemScrollController)
          ..init(widget.data),
        child: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return BlocBuilder<ChapterViewCubit, ChapterViewState>(
        builder: (context, state) {
      if (state is ChapterViewInitialized) {
        return Stack(
          key: _key,
          children: [
            _buildBackground(context),
            _buildViewer(context, state),
            if (state.mode != ChapterViewMode.WEBTOON)
              _buildHorizontalGestures(state, context),
            _buildControls(context, state),
            _buildLoaders(context, state)
          ],
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
    });
  }

  TransparentPointer _buildHorizontalGestures(
      ChapterViewInitialized state, BuildContext context) {
    return TransparentPointer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(max(0, state.currentPage - 2),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease);
                },
                // behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                      color: _showGestureOverlay
                          ? AppColors.primary.withOpacity(0.25)
                          : Colors.transparent),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showGestureOverlay
                        ? Center(
                            child: Text(
                            state.mode == ChapterViewMode.LEFT_TO_RIGHT
                                ? "Prev"
                                : "Next",
                            style: semibold(size: 24).apply(shadows: [
                              BoxShadow(
                                  color: AppColors.mainBlack,
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ]),
                          ))
                        : const SizedBox(),
                  ),
                ),
              ),
              GestureDetector(
                // behavior: HitTestBehavior.translucent,
                onTap: () {
                  _pageController.animateToPage(
                      min(state.currentPages.value.length - 1,
                          state.currentPage),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                      color: _showGestureOverlay
                          ? AppColors.primary.withOpacity(0.25)
                          : Colors.transparent),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showGestureOverlay
                        ? Center(
                            child: Text(
                            state.mode == ChapterViewMode.LEFT_TO_RIGHT
                                ? "Next"
                                : "Prev",
                            style: semibold(size: 24).apply(shadows: [
                              BoxShadow(
                                  color: AppColors.mainBlack,
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ]),
                          ))
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Padding _buildControls(BuildContext context, ChapterViewInitialized state) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: state.controlsVisible
            ? _buildControlsView(context, state)
            : const SizedBox(),
      ),
    );
  }

  Padding _buildControlsView(
      BuildContext context, ChapterViewInitialized state) {
    final centeredElementWidth = MediaQuery.of(context).size.width - 144;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: AppColors.mainBlack.withOpacity(0.25),
                          blurRadius: 24,
                          spreadRadius: 24)
                    ]),
                    child: Text(
                        state.group.elements
                            .firstWhere((element) =>
                                element.uid == state.currentPages.chapterUid)
                            .title,
                        style: medium(size: 18),
                        maxLines: 4,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  width: 70,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColors.backgroundColor),
                  child: Center(
                      child: Text('${state.currentPage}/${state.totalPages}')),
                )
              ],
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                          shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Center(
                    child: Container(
                      width: centeredElementWidth,
                      decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FlutterSlider(
                          values: [state.currentPage.toDouble()],
                          min: 0,
                          max: state.totalPages.toDouble(),
                          handlerHeight: 24,
                          handlerWidth: 24,
                          onDragCompleted: (_, index, __) {
                            switch (state.mode) {
                              case ChapterViewMode.RIGHT_TO_LEFT:
                              case ChapterViewMode.LEFT_TO_RIGHT:
                                _pageController.jumpToPage(
                                  min((index as double).toInt(),
                                      state.currentPages.value.length - 1),
                                );
                                break;
                              case ChapterViewMode.WEBTOON:
                                _itemScrollController.scrollTo(
                                    index: min((index as double).toInt(),
                                        state.currentPages.value.length - 1),
                                    duration:
                                        const Duration(milliseconds: 300));
                                break;
                            }
                          },
                          tooltip: FlutterSliderTooltip(
                              custom: (v) => CachedNetworkImage(
                                    httpHeaders: _headers,
                                    imageUrl: state.currentPages.value[min(
                                        (v as double).toInt(),
                                        state.currentPages.value.length - 1)],
                                    progressIndicatorBuilder:
                                        (context, url, progress) =>
                                            CircularProgressIndicator(
                                      value: progress.progress ?? 0.01,
                                      color: AppColors.primary,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                              textStyle: regular(color: AppColors.mainWhite)),
                          trackBar: FlutterSliderTrackBar(
                              inactiveTrackBar: BoxDecoration(
                                  color: AppColors.mainBlack,
                                  borderRadius: BorderRadius.circular(16.0)),
                              activeTrackBar: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(16.0))),
                          handler: FlutterSliderHandler(
                              child: const SizedBox(),
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  SettingsOverlay(
                      entries: [
                        SettingsOverlayEntry(
                            onTap: () {
                              _showGestureOverlay = !_showGestureOverlay;
                              setState(() {});
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              child: _showGestureOverlay
                                  ? const Icon(
                                      Icons.layers_outlined,
                                      key: ValueKey(1),
                                      color: AppColors.primary,
                                    )
                                  : const Icon(
                                      Icons.layers_outlined,
                                      key: ValueKey(2),
                                    ),
                            )),
                        SettingsOverlayEntry(
                            onTap: () {
                              _showBottomSheetSettings(context, state);
                            },
                            icon: Icon(Icons.chrome_reader_mode))
                      ],
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: AppColors.backgroundColor,
                            shape: BoxShape.circle),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: AppColors.primary,
                        ),
                      ))
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  void _showBottomSheetSettings(
      BuildContext context, ChapterViewInitialized state) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        builder: (context) => BottomModalSettings(
              scaffoldKey: _key,
              state: state,
            ));
  }

  Widget _buildViewer(BuildContext context, ChapterViewInitialized state) {
    return GestureDetector(
      onTap: () {
        context.read<ChapterViewCubit>().onChangeVisibility();
      },
      behavior: HitTestBehavior.translucent,
      child: _buildPageViewerPage(state, context),
    );
  }

  Widget _buildPageViewerPage(
      ChapterViewInitialized state, BuildContext context) {
    switch (state.mode) {
      case ChapterViewMode.RIGHT_TO_LEFT:
      case ChapterViewMode.LEFT_TO_RIGHT:
        return PhotoViewGallery.builder(
            allowImplicitScrolling: true,
            loadingBuilder: (context, event) {
              return Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    value: event != null && event.expectedTotalBytes != null
                        ? event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!
                        : 0,
                  ),
                ),
              );
            },
            pageController: _pageController,
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: state.currentPages.value.length,
            reverse: state.mode == ChapterViewMode.RIGHT_TO_LEFT,
            onPageChanged: (index) {
              context.read<ChapterViewCubit>().onPageChanged(index + 1);
              if (index == 0) {
                _canLoadPrevious = true;
              } else if (index == state.currentPages.value.length - 1) {
                _canLoadNext = true;
              } else {
                _canLoadPrevious = false;
                _canLoadNext = false;
              }
              setState(() {});
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                  minScale: 0.1,
                  maxScale: 0.5,
                  basePosition: Alignment.center,
                  tightMode: true,
                  imageProvider: CachedNetworkImageProvider(
                      state.currentPages.value[index],
                      headers: _headers));
            });
      case ChapterViewMode.WEBTOON:
        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 500) {
              _canLoadNext = true;
              setState(() {});
            } else if (_canLoadNext) {
              _canLoadNext = false;
              setState(() {});
            }

            if ((notification.metrics.pixels <=
                notification.metrics.minScrollExtent + 500)) {
              _canLoadPrevious = true;
              setState(() {});
            } else if (_canLoadPrevious) {
              _canLoadPrevious = false;
              setState(() {});
            }

            return false;
          },
          child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              itemCount: state.currentPages.value.length,
              minCacheExtent: 600,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => VisibilityDetector(
                    key: ValueKey<String>(state.currentPages.value[index]),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction > 0) {
                        context
                            .read<ChapterViewCubit>()
                            .onPageChanged(index + 1);
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: state.currentPages.value[index],
                      progressIndicatorBuilder: (context, url, progress) =>
                          SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary,
                              value: progress.progress ?? 0),
                        ),
                      ),
                    ),
                  )),
        );
    }
  }

  Container _buildBackground(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
    );
  }

  Widget _buildLoaders(BuildContext context, ChapterViewInitialized state) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildControlButtons(context, state),
            const SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(
      BuildContext context, ChapterViewInitialized state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: (_canLoadPrevious && state.canGetPreviousPages) ||
              (_canLoadNext && state.canGetNextPages)
          ? ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(AppColors.backgroundColor)),
              onPressed: () {
                if (_canLoadNext) {
                  context.read<ChapterViewCubit>().onPagesChanged(next: true);
                  _canLoadNext = false;
                  _canLoadPrevious = true;
                } else {
                  context.read<ChapterViewCubit>().onPagesChanged(next: false);
                  _canLoadPrevious = false;
                  _canLoadNext = true;
                }
                setState(() {});
              },
              child: Text(
                _canLoadNext
                    ? S.current.chapter_viewer_next_chapter_button_title
                    : S.current.chapter_viewer_previous_chapter_button_title,
                style: medium(size: 16),
              ))
          : const SizedBox(),
    );
  }
}
