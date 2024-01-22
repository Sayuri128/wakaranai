import 'package:flutter/material.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard(
      {Key? key,
      this.onTap,
      this.onLongPress,
      required this.uid,
      required this.headers,
      required this.cover,
      required this.title})
      : super(key: key);

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Map<String, String> headers;
  final String uid;
  final String cover;
  final String title;

  static double aspectRatio(double width) => width <= 200 ? 9 / 16 : 6 / 9;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: Heroes.galleryViewToConcreteView(uid),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          4.0,
        ),
        child: Material(
          child: Ink.image(
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              image: getImageProvider(cover, headers: headers),
              child: InkWell(
                splashColor: AppColors.mediumLight.withOpacity(0.3),
                onTap: onTap,
                onLongPress: onLongPress,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
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
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          maxLines: 3,
                          style: medium(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
