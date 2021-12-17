import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/pages_item/pages_item.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:photo_view/photo_view.dart';

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
    return PageView.builder(
        controller: pageController,
        itemCount: widget.data.pages.length,
        itemBuilder: (_, index) => _buildPageItem(widget.data.pages[index]));
  }

  Widget _buildPageItem(PagesItem item) {
    return PhotoView(
        minScale: 0.3,
        loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 0),
              ),
            ),
        imageProvider: CachedNetworkImageProvider(NHentaiUrls.pageItemSource(
            widget.data.mediaId, item.t, widget.data.pages.indexOf(item) + 1)));
  }
}
