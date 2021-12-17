import 'package:flutter/material.dart';
import 'package:h_reader/main.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/ui/routes.dart';
import 'package:h_reader/ui/widgets/cached_image.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';

class GalleryDoujinshiCard extends StatelessWidget {
  const GalleryDoujinshiCard({Key? key, required this.doujinshi}) : super(key: key);

  final Doujinshi doujinshi;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Card(
        shadowColor: AppColors.mainGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              MyApp.navigator?.pushNamed(Routes.doujinshiView, arguments: doujinshi);
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Column(
              children: [
                CachedImage(
                    url: NHentaiUrls.thumbnailUrl(doujinshi.mediaId, doujinshi.images.thumbnail.t),
                    width: 200,
                    height: 180),
                Center(
                  child: Text(doujinshi.title.pretty?.overflow ?? '', maxLines: 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
