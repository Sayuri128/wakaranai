import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard(
      {super.key,
      this.onTap,
      this.onLongPress,
      required this.uid,
      required this.headers,
      required this.cover,
      required this.title});

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
      flightShuttleBuilder: Heroes.crossfadeFlightShuttle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: const Color(0xFF3A3A3A),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white24,
                  size: 32,
                ),
              ),
              Ink.image(
                fit: BoxFit.cover,
                image: getImageProvider(cover, headers: headers),
                child: InkWell(
                  splashColor: AppColors.mediumLight.withValues(alpha: 0.3),
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.55,
                          widthFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.black.withValues(alpha: 0.0),
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            maxLines: 3,
                            style: medium().copyWith(
                              shadows: const <Shadow>[
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
