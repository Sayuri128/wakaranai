import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryViewCard extends StatelessWidget {
  GalleryViewCard(
      {Key? key,
      this.onTap,
      required this.uid,
      required this.cover,
      required this.title})
      : super(key: key);

  final VoidCallback? onTap;

  final String uid;
  final String cover;
  final String title;

  static const double aspectRatio = 6 / 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: ThemeData().splashColor.withOpacity(0.2),
      onTap: onTap,
      child: Stack(
        children: [
          Hero(
            tag: Heroes.galleryViewToConcreteView(uid),
            child: Material(
              child: CachedNetworkImage(
                imageUrl: cover,
                height: MediaQuery.of(context).size.width * .5 / aspectRatio,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * .5 / aspectRatio,
            width: double.maxFinite,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: const Alignment(-1, 0),
                    end: const Alignment(-1, 1),
                    colors: [
                  AppColors.mainBlack.withOpacity(0.0),
                  AppColors.mainBlack.withOpacity(.8),
                ])),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * .5 / aspectRatio,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title.overflow,
                  maxLines: 3,
                  style: medium(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
