import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/src/provider.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/settings_overlay.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/chapter/chapter.dart';

class ChapterViewerData {
  final ApiClient apiClient;
  final Chapter chapter;

  const ChapterViewerData({
    required this.apiClient,
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
  late final PageController pageController;

  bool _showGestureOverlay = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<ChapterViewCubit>(
        create: (context) => ChapterViewCubit(apiClient: widget.data.apiClient)
          ..init(widget.data.chapter),
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
            _buildHorizontalGestures(state, context),
            _buildControls(context, state),
          ],
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(),
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
                  pageController.jumpToPage(max(0, state.currentPage - 2));
                },
                // behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                      color: _showGestureOverlay
                          ? AppColors.accentGreen.withOpacity(0.25)
                          : Colors.transparent),
                ),
              ),
              GestureDetector(
                // behavior: HitTestBehavior.translucent,
                onTap: () {
                  pageController.jumpToPage(
                      min(state.pages.value.length - 1, state.currentPage));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                      color: _showGestureOverlay
                          ? AppColors.accentGreen.withOpacity(0.25)
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
                InkWell(
                  child: const Icon(Icons.arrow_back),
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      color: Colors.transparent, shape: BoxShape.circle),
                  child: const SizedBox(),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 144,
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
                        pageController.jumpToPage(
                          min((index as double).toInt(),
                              state.pages.value.length - 1),
                        );
                      },
                      tooltip: FlutterSliderTooltip(
                          custom: (v) => CachedNetworkImage(
                                imageUrl: state.pages.value[min(
                                    (v as double).toInt(),
                                    state.pages.value.length - 1)],
                                progressIndicatorBuilder:
                                    (context, url, progress) =>
                                        CircularProgressIndicator(
                                            value: progress.progress ?? 0.01),
                                fit: BoxFit.cover,
                              ),
                          textStyle: regular(color: AppColors.mainWhite)),
                      trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(
                              color: AppColors.mainBlack,
                              borderRadius: BorderRadius.circular(16.0)),
                          activeTrackBar: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(16.0))),
                      handler: FlutterSliderHandler(
                          child: const SizedBox(),
                          decoration: const BoxDecoration(
                              color: AppColors.accentGreen,
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
                                  color: AppColors.accentGreen,
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
                      color: AppColors.accentGreen,
                    ),
                  ))
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
      child: PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: state.pages.value.length,
          onPageChanged: (index) {
            context.read<ChapterViewCubit>().onPageChanged(index + 1);
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
                minScale: 0.1,
                maxScale: 0.5,
                basePosition: Alignment.center,
                // gestureDetectorBehavior: HitTestBehavior.translucent,
                tightMode: true,
                imageProvider:
                    CachedNetworkImageProvider(state.pages.value[index]));
          }),
    );
  }

  Container _buildBackground(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
    );
  }
}
