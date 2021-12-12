import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/nhentai/doujinshi/tags_item/tags_item.dart';
import 'package:h_reader/ui/home/doujinshi_view/doujinshi_page_view.dart';
import 'package:h_reader/ui/home/doujinshi_view/tag_item.dart';
import 'package:h_reader/ui/widgets/appbar.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:h_reader/utils/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:collection/collection.dart';

class DoujinshiView extends StatefulWidget {
  const DoujinshiView({Key? key, required this.doujinshi}) : super(key: key);

  final Doujinshi doujinshi;

  @override
  State<DoujinshiView> createState() => _DoujinshiViewState();
}

class _DoujinshiViewState extends State<DoujinshiView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: widget.doujinshi.title.pretty ?? ''),
      body: Transform.translate(
        offset: const Offset(0, -5),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildCover(context),
              if (widget.doujinshi.title.english != null) ...[
                const SizedBox(
                  height: 16.0,
                ),
                _buildTitle(title: widget.doujinshi.title.english!)
              ],
              if (widget.doujinshi.title.japanese != null) ...[
                const SizedBox(
                  height: 16.0,
                ),
                _buildTitle(title: widget.doujinshi.title.japanese!)
              ],
              const SizedBox(
                height: 8.0,
              ),
              _buildTags(),
              const SizedBox(
                height: 8.0,
              ),
              _buildPagesCount(),
              _buildUploadedDate(),
              const SizedBox(
                height: 8.0,
              ),
              DoujinshiPageView(
                  mediaId: widget.doujinshi.mediaId, pages: widget.doujinshi.images.pages)
            ],
          ),
        ),
      ),
    );
  }

  Wrap _buildTags() {
    return Wrap(
      children: widget.doujinshi.tags
          .sorted((TagsItem m, TagsItem o) => -m.count.compareTo(o.count))
          .map((e) => TagItem(
                item: e,
              ))
          .toList(),
    );
  }

  Padding _buildPagesCount() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            S.current.doujinshi_pages_count,
            style: medium(),
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            widget.doujinshi.numPages.toString(),
            style: medium(color: AppColors.green),
          )
        ],
      ),
    );
  }

  Padding _buildUploadedDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            S.current.doujinshi_uploaded,
            style: medium(),
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                int.parse('${widget.doujinshi.uploadDate.toString()}000'))),
            style: medium(color: AppColors.green),
          )
        ],
      ),
    );
  }

  Padding _buildTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: title));
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(S.current.copied_to_clipboard_message)));
        },
        child: Text(
          title,
          style: medium(color: AppColors.green, size: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
      child: FadeInImage(
          placeholder: Image.memory(kTransparentImage).image,
          width: min(MediaQuery.of(context).size.width, widget.doujinshi.images.cover.w.toDouble()),
          height: max(
              MediaQuery.of(context).size.height * 0.4, widget.doujinshi.images.cover.h.toDouble()),
          fit: BoxFit.fill,
          image: Image.network(
                  NHentaiUrls.coverUrl(widget.doujinshi.mediaId, widget.doujinshi.images.cover.t))
              .image),
    );
  }
}
