import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/heroes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard(
      {Key? key,
      this.onTap,
      this.onLongPress,
      required this.inLibrary,
      required this.uid,
      required this.cover,
      required this.title})
      : super(key: key);

  final bool inLibrary;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final String uid;
  final String cover;
  final String title;

  static const double aspectRatio = 6 / 9;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: Heroes.galleryViewToConcreteView(uid),
      child: Material(
        child: Ink.image(
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.width * .5 / aspectRatio,
            width: MediaQuery.of(context).size.width,
            image: CachedNetworkImageProvider(cover),
            child: InkWell(
              splashColor: AppColors.mediumLight.withOpacity(0.3),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Stack(
                children: [
                  Container(
                    height:
                        MediaQuery.of(context).size.width * .5 / aspectRatio,
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
                    height:
                        MediaQuery.of(context).size.width * .5 / aspectRatio,
                    child: Stack(children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: inLibrary
                            ? Container(
                                height: MediaQuery.of(context).size.width *
                                    .5 /
                                    aspectRatio,
                                width: double.maxFinite,
                                color:
                                    AppColors.backgroundColor.withOpacity(0.6))
                            : const SizedBox(),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: inLibrary
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.mediumDark,
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.mediumLight
                                                    .withOpacity(0.1),
                                                blurRadius: 6,
                                                spreadRadius: 4)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                            S.current
                                                .gallery_view_item_in_library_title,
                                            style: regular(size: 14)),
                                      )),
                                ))
                            : const SizedBox(),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            maxLines: 4,
                            style: medium(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
