import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/src/provider.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/chapter/chapter.dart';

class ChapterViewer extends StatefulWidget {
  const ChapterViewer({Key? key, required this.chapter}) : super(key: key);

  final Chapter chapter;

  @override
  State<ChapterViewer> createState() => _ChapterViewerState();
}

class _ChapterViewerState extends State<ChapterViewer> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<ChapterViewCubit>(
        create: (context) => ChapterViewCubit(ChapterViewState(
            currentPage: 1, totalPages: widget.chapter.pages.length, controlsVisible: true)),
        child: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return Builder(builder: (context) {
      return Stack(
        children: [
          _buildBackground(context),
          _buildViewer(context),
          _buildControls(context),
        ],
      );
    });
  }

  Padding _buildControls(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: BlocBuilder<ChapterViewCubit, ChapterViewState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: state.controlsVisible ? _buildControlsView(context, state) : const SizedBox(),
          );
        },
      ),
    );
  }

  Padding _buildControlsView(BuildContext context, ChapterViewState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
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
                child: Center(child: Text('${state.currentPage}/${state.totalPages}')),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0), color: AppColors.accentGreen),
              )
            ],
          )
        ],
      ),
    );
  }

  GestureDetector _buildViewer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ChapterViewCubit>().onChangeVisibility();
      },
      child: PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.chapter.pages.length,
          onPageChanged: (index) {
            context.read<ChapterViewCubit>().onPageChanged(index + 1);
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
                minScale: 0.2,
                imageProvider: CachedNetworkImageProvider(widget.chapter.pages[index]));
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
