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
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/pages_change_button.dart';
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
    return Material(
      child: BlocProvider<ChapterViewCubit>(
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
                  _pageController.jumpToPage(max(0, state.currentPage - 2));
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
                ),
              ),
              GestureDetector(
                // behavior: HitTestBehavior.translucent,
                onTap: () {
                  _pageController.jumpToPage(min(
                      state.currentPages.value.length - 1, state.currentPage));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                      color: _showGestureOverlay
                          ? AppColors.primary.withOpacity(0.25)
                          : Colors.transparent),
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
                const SizedBox(),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 72),
                child: Container(
                  width: centeredElementWidth,
                  decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: DropdownButtonFormField<ChapterViewMode>(
                            value: state.mode,
                            borderRadius: BorderRadius.circular(16.0),
                            style: medium(),
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent))),
                            items: ChapterViewMode.values
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      alignment: Alignment.center,
                                      child: Text(chapterViewModelToString(e),
                                          textAlign: TextAlign.center),
                                    ))
                                .toList(),
                            onChanged: (mode) {
                              if (mode != null) {
                                context
                                    .read<ChapterViewCubit>()
                                    .onModeChanged(mode);
                              }
                            }),
                      )
                    ],
                  ),
                ),
              ),
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
                            ))
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

  Widget _buildViewer(BuildContext context, ChapterViewInitialized state) {
    return GestureDetector(
      onTap: () {
        context.read<ChapterViewCubit>().onChangeVisibility();
      },
      behavior: HitTestBehavior.translucent,
      child: _buildPageViewer(state, context),
    );
  }

  Widget _buildPageViewer(ChapterViewInitialized state, BuildContext context) {
    return _buildPageViewerPage(state, context);
  }

  Widget _buildPageViewerPage(
      ChapterViewInitialized state, BuildContext context) {
    switch (state.mode) {
      case ChapterViewMode.RIGHT_TO_LEFT:
      case ChapterViewMode.LEFT_TO_RIGHT:
        return PhotoViewGallery.builder(
            allowImplicitScrolling: true,
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
                notification.metrics.maxScrollExtent - 200) {
              _canLoadNext = true;
            } else {
              _canLoadNext = false;
            }

            if ((notification.metrics.pixels <=
                notification.metrics.minScrollExtent + 200)) {
              _canLoadPrevious = true;
            } else {
              _canLoadPrevious = false;
            }

            return false;
          },
          child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemCount: state.currentPages.value.length,
              itemBuilder: (context, index) => VisibilityDetector(
                    key: ValueKey<int>(index),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction >= 0.2) {
                        context
                            .read<ChapterViewCubit>()
                            .onPageChanged(index + 1);
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: state.currentPages.value[index],
                      progressIndicatorBuilder: (context, url, progress) =>
                          SizedBox(
                        height: 360,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: state.mode != ChapterViewMode.RIGHT_TO_LEFT
                  ? _buildControlButtons(context, state)
                  : _buildControlButtons(context, state).reversed.toList(),
            ),
            const SizedBox(
              height: 162,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildControlButtons(
      BuildContext context, ChapterViewInitialized state) {
    return [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _canLoadPrevious && state.canGetPreviousPages
            ? _buildPreviousPageButton(context, state)
            : const SizedBox(),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _canLoadNext && state.canGetNextPages
            ? _buildNextPageButton(context, state)
            : const SizedBox(),
      ),
    ];
  }

  PagesChangeButton _buildNextPageButton(
      BuildContext context, ChapterViewInitialized state) {
    return PagesChangeButton(
        icon: Icon(
            state.mode != ChapterViewMode.RIGHT_TO_LEFT
                ? Icons.arrow_right
                : Icons.arrow_left,
            size: 32),
        onTap: () {
          context.read<ChapterViewCubit>().onPagesChanged(next: true);
          _canLoadNext = false;
          _canLoadPrevious = true;
        });
  }

  PagesChangeButton _buildPreviousPageButton(
      BuildContext context, ChapterViewInitialized state) {
    return PagesChangeButton(
        icon: Icon(
            state.mode != ChapterViewMode.RIGHT_TO_LEFT
                ? Icons.arrow_left
                : Icons.arrow_right,
            size: 32),
        onTap: () {
          context.read<ChapterViewCubit>().onPagesChanged(next: false);
          _canLoadPrevious = false;
          _canLoadNext = true;
        });
  }
}
