import 'dart:math';

import 'package:flutter/material.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/models/nhentai/doujinshi/tags_item/tags_item.dart';
import 'package:h_reader/ui/home/doujinshi_view/tag_item.dart';
import 'package:h_reader/ui/widgets/appbar.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:h_reader/utils/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:collection/collection.dart';

class DoujinshiView extends StatelessWidget {
  const DoujinshiView({Key? key, required this.doujinshi}) : super(key: key);

  final Doujinshi doujinshi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: doujinshi.title.pretty ?? ''),
      body: Transform.translate(
        offset: const Offset(0, -5),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildCover(context),
            const SizedBox(
              height: 8.0,
            ),
            Wrap(
              children: doujinshi.tags
                  .sorted((TagsItem m, TagsItem o) => -m.count.compareTo(o.count))
                  .map((e) => TagItem(
                        item: e,
                      ))
                  .toList(),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Padding(
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
                    doujinshi.numPages.toString(),
                    style: medium(color: AppColors.green),
                  )
                ],
              ),
            ),
            Padding(
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
                        int.parse('${doujinshi.uploadDate.toString()}000'))),
                    style: medium(color: AppColors.green),
                  )
                ],
              ),
            ),
          ],
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
          width: MediaQuery.of(context).size.width,
          height:
              max(MediaQuery.of(context).size.height * 0.6, doujinshi.images.cover.h.toDouble()),
          fit: BoxFit.cover,
          image: Image.network(NHentaiUrls.coverUrl(doujinshi.mediaId, doujinshi.images.cover.t))
              .image),
    );
  }
}
