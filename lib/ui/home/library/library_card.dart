import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';


class LibraryCard extends StatelessWidget {
  const LibraryCard(
      {Key? key,
        this.onTap,
        this.onLongPress,
        required this.uid,
        required this.cover,
        required this.title})
      : super(key: key);

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final String uid;
  final String cover;
  final String title;

  static const double aspectRatio = 6 / 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: ThemeData().splashColor.withOpacity(0.2),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Hero(
            tag: Heroes.galleryViewToConcreteView(uid),
            child: Material(
              child: CachedNetworkImage(
                imageUrl: cover,
                alignment: Alignment.center,
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
                  title,
                  maxLines: 4,
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
