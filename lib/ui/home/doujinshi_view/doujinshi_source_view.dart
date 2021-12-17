import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/source_view/source_view_cubit.dart';
import 'package:h_reader/models/nhentai/doujinshi/pages_item/pages_item.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:photo_view/photo_view_gallery.dart';

class DoujinshiSourceViewData {
  final int initialPage;
  final String mediaId;
  final List<PagesItem> pages;

  const DoujinshiSourceViewData({
    this.initialPage = 0,
    required this.mediaId,
    required this.pages,
  });
}

class DoujinshiSourceView extends StatefulWidget {
  const DoujinshiSourceView({Key? key, required this.data}) : super(key: key);

  final DoujinshiSourceViewData data;

  @override
  State<DoujinshiSourceView> createState() => _DoujinshiSourceViewState();
}

class _DoujinshiSourceViewState extends State<DoujinshiSourceView> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.data.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<SourceViewCubit>(
        create: (context) => SourceViewCubit(SourceViewState(
            currentPage: widget.data.initialPage + 1,
            totalPages: widget.data.pages.length,
            controlsVisible: true)),
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
      child: BlocBuilder<SourceViewCubit, SourceViewState>(
        builder: (context, state) {
          return IgnorePointer(
            ignoring: !state.controlsVisible,
            child: AnimatedOpacity(
              opacity: state.controlsVisible ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Padding(
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
                              borderRadius: BorderRadius.circular(16.0),
                              color: AppColors.accentGreen),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  GestureDetector _buildViewer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SourceViewCubit>().onChangeVisibility();
      },
      child: PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.data.pages.length,
          onPageChanged: (index) {
            context.read<SourceViewCubit>().onPageChanged(index + 1);
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
                minScale: 0.2,
                imageProvider: CachedNetworkImageProvider(NHentaiUrls.pageItemSource(
                    widget.data.mediaId, widget.data.pages[index].t, index + 1)));
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
