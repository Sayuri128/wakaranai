import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/utils/page_image.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/bottom_modal_settings.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ChapterViewerData {
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;
  final ConcreteView<ChaptersGroup> concreteView;
  final ChaptersGroup group;
  final Chapter chapter;
  final int initialPage;

  const ChapterViewerData(
      {required this.apiClient,
      required this.configInfo,
      required this.group,
      required this.concreteView,
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

  final Map<String, Size> _pageSizes = <String, Size>{};

  late final ChapterViewCubit _chapterViewCubit;

  late final PageController _pageController;
  late final ItemScrollController _itemScrollController;

  final bool _showGestureOverlay = false;

  bool _canLoadNext = false;
  bool _canLoadPrevious = false;

  bool _initialized = false;

  late final AnimationController _sliderController;
  double _sliderFrom = 1;
  double _sliderTarget = 1;
  double? _seekOverride;
  ChapterViewMode? _lastMode;
  int _lastPage = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _itemScrollController = ItemScrollController();
    _sliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _chapterViewCubit = ChapterViewCubit(
      apiClient: widget.data.apiClient,
      initialPage: widget.data.initialPage,
      settingsCubit: context.read<SettingsCubit>(),
      pageController: _pageController,
      itemScrollController: _itemScrollController,
      chapterActivityRepository: context.read<ChapterActivityRepository>(),
      concreteDataRepository: context.read<ConcreteDataRepository>(),
      downloadRepository: context.read<DownloadRepository>(),
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
    _chapterViewCubit.close();
    _sliderController.dispose();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
    super.dispose();
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
    return BlocConsumer<ChapterViewCubit, ChapterViewState>(
        listenWhen: (ChapterViewState previous, ChapterViewState current) =>
            current is ChapterViewInitialized &&
            (!_initialized ||
                (previous is ChapterViewInitialized &&
                    (current.mode != previous.mode ||
                        current.currentPage != previous.currentPage))),
        listener: (BuildContext context, ChapterViewState state) {
          if (state is ChapterViewInitialized) {
            final bool isInit = !_initialized;
            final bool modeChanged =
                _lastMode != null && state.mode != _lastMode;
            _initialized = true;

            if (isInit || modeChanged) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (state.mode == ChapterViewMode.webtoon) {
                  _itemScrollController.jumpTo(
                      index: max(0, state.currentPage - 1));
                } else {
                  _pageController.jumpToPage(max(0, state.currentPage - 1));
                }
              });
              _animateSliderTo(state, animate: false);
            } else if (state.currentPage != _lastPage) {
              _animateSliderTo(state, animate: _seekOverride == null);
            }

            _lastMode = state.mode;
            _lastPage = state.currentPage;
          }
        },
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
            return Stack(
              children: <Widget>[
                ServiceViewerMessage(
                  icon: Icons.error_outline_rounded,
                  title: S.current.concrete_viewer_error_title,
                  message: state.message,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildRoundButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
        });
  }

  Widget _buildPageCounter(
      BuildContext context, ChapterViewInitialized state) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      right: 0,
      left: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state.controlsVisible ? 0.0 : 1.0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.currentPage}/${state.totalPages}',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalGestures(
      ChapterViewInitialized state, BuildContext context) {
    if (!state.controlsEnabled) {
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
                          ? AppColors.primary.withValues(alpha: 0.25)
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
                          ? AppColors.primary.withValues(alpha: 0.25)
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

  Widget _buildControls(BuildContext context, ChapterViewInitialized state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: state.controlsVisible
          ? _buildControlsView(context, state)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildControlsView(
      BuildContext context, ChapterViewInitialized state) {
    final String title = state.group.elements
        .firstWhere(
            (Chapter element) => element.uid == state.currentPages.chapterUid)
        .title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildTopBar(context, title),
        const Spacer(),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: Text(
        title,
        style: semibold(size: 16, color: AppColors.onMedia),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ChapterViewInitialized state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 40, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.currentPage}/${state.totalPages}',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _buildRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildSlider(context, state)),
              const SizedBox(width: 12),
              _buildRoundButton(
                icon: Icons.settings_rounded,
                onTap: () => _showBottomSheetSettings(context, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: AppColors.onMedia, size: 22),
        ),
      ),
    );
  }

  double _currentSliderValue() {
    return _sliderFrom +
        (_sliderTarget - _sliderFrom) *
            Curves.easeOut.transform(_sliderController.value);
  }

  void _animateSliderTo(ChapterViewInitialized state,
      {required bool animate}) {
    final double maxValue = max(2, state.totalPages).toDouble();
    final double target = state.currentPage.toDouble().clamp(1.0, maxValue);
    _sliderFrom = _currentSliderValue();
    _sliderTarget = target;
    if (animate) {
      _sliderController
        ..reset()
        ..forward();
    } else {
      _sliderController.value = 1.0;
    }
  }

  Widget _buildSlider(BuildContext context, ChapterViewInitialized state) {
    final double maxValue = max(2, state.totalPages).toDouble();

    return AnimatedBuilder(
      animation: _sliderController,
      builder: (BuildContext context, Widget? child) {
        final double value =
            (_seekOverride ?? _currentSliderValue()).clamp(1.0, maxValue);
        return FlutterSlider(
          values: <double>[value],
          min: 1,
          max: maxValue,
          jump: true,
          handlerHeight: 20,
          handlerWidth: 20,
          onDragStarted: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
            _sliderController.stop();
          },
          onDragging: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
          },
          onDragCompleted: (_, index, __) {
            final double dragged = (index as num).toDouble();
            _seekOverride = dragged;
            _sliderFrom = dragged;
            _sliderTarget = dragged;
            _sliderController.value = 1.0;
            switch (state.mode) {
              case ChapterViewMode.rightToLeft:
              case ChapterViewMode.leftToRight:
                _pageController.jumpToPage(min(dragged.toInt() - 1,
                    state.currentPages.value.length - 1));
                break;
              case ChapterViewMode.webtoon:
                _itemScrollController.jumpTo(
                  index: min(
                      dragged.toInt(), state.currentPages.value.length - 1),
                  alignment: dragged == state.totalPages.toDouble() - 1 ? 1 : 0,
                );
                break;
            }

            _canLoadNext =
                dragged.toInt() - 1 == state.currentPages.value.length - 1;
            _canLoadPrevious = dragged.toInt() - 1 == 0;
            if (mounted) {
              setState(() {});
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _seekOverride = null;
              if (mounted) {
                setState(() {});
              }
            });
          },
          tooltip: FlutterSliderTooltip(
              custom: (v) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: pageImageProvider(
                          state.currentPages.value[min((v as double).toInt(),
                              state.currentPages.value.length - 1)],
                          state.headers),
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? progress) {
                        if (progress == null) return child;
                        return CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : 0.01,
                          color: AppColors.onMedia,
                        );
                      },
                    ),
                  ),
              textStyle: regular(color: AppColors.onMedia)),
          trackBar: FlutterSliderTrackBar(
              activeTrackBarHeight: 5,
              inactiveTrackBarHeight: 5,
              inactiveTrackBar: BoxDecoration(
                  color: AppColors.overlay(0.25),
                  borderRadius: BorderRadius.circular(16.0)),
              activeTrackBar: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.0))),
          handler: FlutterSliderHandler(
              child: const SizedBox(),
              decoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle)),
        );
      },
    );
  }

  void _showBottomSheetSettings(
      BuildContext context, ChapterViewInitialized state) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      onLongPress: () {
        if (state.currentPages.value.isEmpty) return;
        final int index = (state.currentPage - 1)
            .clamp(0, state.currentPages.value.length - 1);
        showSaveImageSheet(
          context,
          url: state.currentPages.value[index],
          headers: state.headers,
        );
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
              final String page = state.currentPages.value[index];
              return PhotoViewGalleryPageOptions.customChild(
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  basePosition: Alignment.center,
                  // photo_view only applies zoom through its Transform when
                  // filterQuality is none; otherwise it scales the Image widget
                  // it builds, which a custom child never receives. PageImage
                  // does its own filtering.
                  filterQuality: FilterQuality.none,
                  childSize: _pageSizes[page],
                  child: PageImage(
                    path: page,
                    headers: state.headers,
                    intrinsic: true,
                    onSizeResolved: (Size size) {
                      if (_pageSizes[page] != size && mounted) {
                        setState(() => _pageSizes[page] = size);
                      }
                    },
                    loadingBuilder: (BuildContext context) =>
                        SizedBox.fromSize(
                      size: MediaQuery.of(context).size,
                    ),
                    errorBuilder:
                        (BuildContext context, VoidCallback retry) =>
                            SizedBox.fromSize(
                      size: MediaQuery.of(context).size,
                      child: _buildPageError(retry),
                    ),
                  ));
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
                      child: PageImage(
                        path: state.currentPages.value[index],
                        headers: state.headers,
                        errorBuilder:
                            (BuildContext context, VoidCallback retry) =>
                                SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: _buildPageError(retry),
                        ),
                        loadingBuilder: (BuildContext context) => SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child:
                                CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      ),
                    )));
    }
  }

  Widget _buildPageError(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.broken_image_rounded,
              size: 48, color: AppColors.onMedia.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: AppColors.onMedia,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              S.current.concrete_viewer_retry_button,
              style: medium(size: 14, color: AppColors.onMedia),
            ),
          ),
        ],
      ),
    );
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
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.mainBlack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
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
              icon: Icon(
                _canLoadNext && state.canGetNextPages
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                size: 20,
              ),
              label: Text(
                _canLoadNext && state.canGetNextPages
                    ? S.current.chapter_viewer_next_chapter_button_title
                    : _canLoadPrevious && state.canGetPreviousPages
                        ? S.current.chapter_viewer_previous_chapter_button_title
                        : "",
                style: semibold(size: 15, color: AppColors.mainBlack),
              ),
            )
          : const SizedBox(),
    );
  }
}
