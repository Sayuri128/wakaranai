import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/pages_item/pages_item.dart';
import 'package:h_reader/ui/home/doujinshi_view/doujinshi_source_view.dart';
import 'package:h_reader/ui/routes.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:transparent_image/transparent_image.dart';

class DoujinshiPageView extends StatefulWidget {
  const DoujinshiPageView({Key? key, required this.mediaId, required this.pages}) : super(key: key);

  final String mediaId;
  final List<PagesItem> pages;

  @override
  State<DoujinshiPageView> createState() => _DoujinshiPageViewState();
}

class _DoujinshiPageViewState extends State<DoujinshiPageView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            List.generate(widget.pages.length, (index) => _buildPageItem(widget.pages[index])),
      ),
    );
  }

  Widget _buildPageItem(PagesItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.doujinshiSourceView,
            arguments: DoujinshiSourceViewData(
                mediaId: widget.mediaId,
                pages: widget.pages,
                initialPage: widget.pages.indexOf(item)));
      },
      child: FractionallySizedBox(
        widthFactor: 0.45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage(
              placeholder: Image.memory(kTransparentImage).image,
              fit: BoxFit.fitHeight,
              image: Image.network(
                      NHentaiUrls.pageItem(widget.mediaId, item.t, widget.pages.indexOf(item) + 1))
                  .image),
        ),
      ),
    );
  }
}
