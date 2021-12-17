import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/pages_item/pages_item.dart';
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
    return PhotoViewGallery.builder(
        allowImplicitScrolling: true,
        pageController: pageController,
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: widget.data.pages.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
              minScale: 0.1,
              imageProvider: CachedNetworkImageProvider(NHentaiUrls.pageItemSource(
                  widget.data.mediaId, widget.data.pages[index].t, index + 1)));
        });
  }
}
