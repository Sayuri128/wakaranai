import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/bottom_modal_settings.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ChapterViewerData {
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;
  final ConcreteView<ChaptersGroup> concreteView;
  final ChaptersGroup group;
  final MangaGalleryView galleryView;
  final Chapter chapter;
  final int initialPage;

  const ChapterViewerData(
      {required this.apiClient,
      required this.configInfo,
      required this.group,
      required this.concreteView,
      required this.galleryView,
      required this.chapter,
      this.initialPage = 1});
}

class ChapterViewer extends StatefulWidget {
  const ChapterViewer({super.key, required this.data});

  final ChapterViewerData data;

  @override
  State<ChapterViewer> createState() => _ChapterViewerState();
}

class _ChapterViewerState extends State<ChapterViewer>
    with TickerProviderStateMixin {
  final GlobalKey _scaffoldKey = GlobalKey();

  late final ChapterViewCubit _chapterViewCubit;

  late final PageController _pageController;
  late final ItemScrollController _itemScrollController;

  final bool _showGestureOverlay = false;

  bool _canLoadNext = false;
  bool _canLoadPrevious = false;

  Map<String, String> _headers = <String, String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: max(0, widget.data.initialPage - 1),
    );
    _itemScrollController = ItemScrollController();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    if (widget.data.configInfo.protectorConfig != null) {
      _headers = widget.data.apiClient.getProtectorHeaders();
    }

    _chapterViewCubit = ChapterViewCubit(
      apiClient: widget.data.apiClient,
      initialPage: widget.data.initialPage,
      settingsCubit: context.read<SettingsCubit>(),
      pageController: _pageController,
      itemScrollController: _itemScrollController,
    )..init(
        widget.data,
        pagesLoaded: (int current, int total) {
          _canLoadNext = current == total;
          _canLoadPrevious = current == 1;
          if (mounted) {
            setState(() {});
          }
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chapterViewCubit,
      child: Scaffold(
        key: _scaffoldKey,
        body: _buildPage(),
        backgroundColor: AppColors.mainBlack,
      ),
    );
  }

  Widget _buildPage() {
    return BlocBuilder<ChapterViewCubit, ChapterViewState>(
        builder: (BuildContext context, ChapterViewState state) {
      if (state is ChapterViewInitialized) {
        return Stack(
          children: <Widget>[
            _buildBackground(
              context,
            ),
            _buildViewer(context, state),
            if (state.mode != ChapterViewMode.webtoon)
              _buildHorizontalGestures(
                state,
                context,
              ),
            _buildControls(
              context,
              state,
            ),
            _buildLoaders(
              context,
              state,
            ),
            _buildPageCounter(
              context,
              state,
            ),
          ],
        );
      } else if (state is ChapterViewError) {
        return Center(
          child: Text(
            state.message,
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
    });
  }

  Positioned _buildPageCounter(
      BuildContext context, ChapterViewInitialized state) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppColors.mainBlack.withOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: 24)
            ]),
        child: Center(
            child: Text(
          '${state.currentPage}/${state.totalPages}',
          style: medium(size: 18, color: AppColors.mainWhite).copyWith(
            shadows: <Shadow>[
              BoxShadow(
                  color: AppColors.mainBlack, blurRadius: 4, spreadRadius: 4)
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildHorizontalGestures(
      ChapterViewInitialized state, BuildContext context) {
    if(!state.controlsEnabled) {
      return const SizedBox();
    }

    return TransparentPointer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(max(0, state.currentPage - 2),
                      duration: const Duration(milliseconds: 200),
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
                            state.mode == ChapterViewMode.leftToRight
                                ? "Prev"
                                : "Next",
                            style: semibold(size: 24).apply(shadows: <Shadow>[
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
                      duration: const Duration(milliseconds: 200),
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
                            state.mode == ChapterViewMode.leftToRight
                                ? "Next"
                                : "Prev",
                            style: semibold(size: 24).apply(shadows: <Shadow>[
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
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        child: state.controlsVisible
            ? _buildControlsView(context, state)
            : const SizedBox(),
      ),
    );
  }

  Padding _buildControlsView(
      BuildContext context, ChapterViewInitialized state) {
    final double centeredElementWidth = MediaQuery.of(context).size.width - 144;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppColors.mainBlack.withOpacity(0.25),
                          blurRadius: 24,
                          spreadRadius: 24)
                    ]),
                    child: Text(
                        state.group.elements
                            .firstWhere((Chapter element) =>
                                element.uid == state.currentPages.chapterUid)
                            .title,
                        style: medium(size: 18),
                        maxLines: 4,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
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
                          color: AppColors.mainWhite,
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
                            values: <double>[state.currentPage.toDouble()],
                            min: 1,
                            max: state.totalPages.toDouble(),
                            jump: true,
                            handlerHeight: 24,
                            handlerWidth: 24,
                            onDragCompleted: (_, index, __) {
                              switch (state.mode) {
                                case ChapterViewMode.rightToLeft:
                                case ChapterViewMode.leftToRight:
                                  _pageController.jumpToPage(min(
                                      (index as double).toInt() - 1,
                                      state.currentPages.value.length - 1));
                                  break;
                                case ChapterViewMode.webtoon:
                                  _itemScrollController.jumpTo(
                                    index: min((index).toInt(),
                                        state.currentPages.value.length - 1),
                                    alignment:
                                        index == state.totalPages.toDouble() - 1
                                            ? 1
                                            : 0,
                                  );
                                  break;
                              }

                              _canLoadNext = (index).toInt() - 1 ==
                                  state.currentPages.value.length - 1;
                              _canLoadPrevious = (index).toInt() - 1 == 0;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            tooltip: FlutterSliderTooltip(
                                custom: (v) => CachedNetworkImage(
                                      httpHeaders: _headers,
                                      imageUrl: state.currentPages.value[min(
                                          (v as double).toInt(),
                                          state.currentPages.value.length - 1)],
                                      progressIndicatorBuilder:
                                          (BuildContext context, String url,
                                                  DownloadProgress progress) =>
                                              CircularProgressIndicator(
                                        value: progress.progress ?? 0.01,
                                        color: AppColors.mainWhite,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                textStyle: regular(color: AppColors.mainWhite)),
                            trackBar: FlutterSliderTrackBar(
                                inactiveTrackBar: BoxDecoration(
                                    color: AppColors.mainGrey,
                                    borderRadius: BorderRadius.circular(16.0)),
                                activeTrackBar: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(16.0))),
                            handler: FlutterSliderHandler(
                                child: const SizedBox(),
                                decoration: const BoxDecoration(
                                    color: AppColors.mainWhite,
                                    shape: BoxShape.circle)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                        onTap: () {
                          _showBottomSheetSettings(context, state);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                              color: AppColors.backgroundColor,
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.mainWhite,
                          ),
                        ))
                  ],
                ),
              ),
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
      builder: (_) => BottomModalSettings(
        chapterViewCubit: context.read<ChapterViewCubit>(),
        state: state,
      ),
    );
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
      case ChapterViewMode.rightToLeft:
      case ChapterViewMode.leftToRight:
        return PhotoViewGallery.builder(
            allowImplicitScrolling: true,
            loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
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
            reverse: state.mode == ChapterViewMode.rightToLeft,
            onPageChanged: (int index) {
              context.read<ChapterViewCubit>().onPageChanged(
                  index + 1, state.currentPages, onDone: (Pages currentPages) {
                if (index == 0) {
                  _canLoadPrevious = true;
                } else if (index == currentPages.value.length - 1) {
                  _canLoadNext = true;
                } else {
                  _canLoadPrevious = false;
                  _canLoadNext = false;
                }
              });
              setState(() {});
            },
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                  minScale: 0.1,
                  maxScale: 0.5,
                  basePosition: Alignment.center,
                  tightMode: true,
                  imageProvider: CachedNetworkImageProvider(
                      state.currentPages.value[index],
                      headers: _headers));
            });
      case ChapterViewMode.webtoon:
        return NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification notification) {
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
                initialScrollIndex: max(0, state.currentPage - 1),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                itemCount: state.currentPages.value.length,
                minCacheExtent: 99999,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) =>
                    VisibilityDetector(
                      key: ValueKey(state.currentPages.value[index]),
                      onVisibilityChanged: (VisibilityInfo info) {
                        if (info.visibleFraction > 0) {
                          context
                              .read<ChapterViewCubit>()
                              .onPageChanged(index + 1, state.currentPages);
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: state.currentPages.value[index],
                        progressIndicatorBuilder: (BuildContext context,
                                String url, DownloadProgress progress) =>
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
                    )));
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
          children: <Widget>[
            _buildControlButtons(context, state),
            const SizedBox(
              height: 96,
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
                if (_canLoadNext && state.canGetNextPages) {
                  context.read<ChapterViewCubit>().onPagesChanged(
                      next: true,
                      onDone: () {
                        _canLoadNext = false;
                        _canLoadPrevious = true;
                        setState(() {});
                      });
                } else if (_canLoadPrevious && state.canGetPreviousPages) {
                  context.read<ChapterViewCubit>().onPagesChanged(
                      next: false,
                      onDone: () {
                        _canLoadPrevious = false;
                        _canLoadNext = true;
                        setState(() {});
                      });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _canLoadNext && state.canGetNextPages
                      ? S.current.chapter_viewer_next_chapter_button_title
                      : _canLoadPrevious && state.canGetPreviousPages
                          ? S.current
                              .chapter_viewer_previous_chapter_button_title
                          : "",
                  style: medium(size: 16),
                ),
              ))
          : const SizedBox(),
    );
  }
}
