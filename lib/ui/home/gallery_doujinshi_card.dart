import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryDoujinshiCard extends StatelessWidget {
  const GalleryDoujinshiCard({Key? key, required this.doujinshi}) : super(key: key);

  final Doujinshi doujinshi;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        shadowColor: AppColors.mainGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          children: [
            FadeInImage(
                placeholder: Image.memory(kTransparentImage).image,
                height: 200,
                width: 120,
                fit: BoxFit.fitWidth,
                image: Image.network(
                  NHentaiUrls.thumbnailUrl(doujinshi.mediaId, doujinshi.images.thumbnail.t),
                ).image),
            Center(
              child: Text(doujinshi.title.pretty?.overflow ?? '', maxLines: 1),
            )
          ],
        ),
      ),
    );
  }
}
