
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  bool _controlsVisible = false;

  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.data.initialPage);
    totalPages = widget.data.pages.length;
    currentPage = widget.data.initialPage + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _controlsVisible = !_controlsVisible;
              });
            },
            child: PhotoViewGallery.builder(
                allowImplicitScrolling: true,
                pageController: pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                itemCount: widget.data.pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index + 1;
                  });
                },
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                      minScale: 0.2,
                      imageProvider: CachedNetworkImageProvider(NHentaiUrls.pageItemSource(
                          widget.data.mediaId, widget.data.pages[index].t, index + 1)));
                }),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(seconds: 1),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Container(
                          width: 70,
                          height: 30,
                          margin: const EdgeInsets.all(8.0),
                          child: Center(child: Text('$currentPage/$totalPages')),
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
          ),
        ],
      ),
    );
  }
}
