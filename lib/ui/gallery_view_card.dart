import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryViewCard extends StatelessWidget {
  const GalleryViewCard({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.uid,
    required this.headers,
    required this.cover,
    required this.title,
    this.inLibrary = false,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Map<String, String> headers;
  final String uid;
  final String cover;
  final String title;
  final bool inLibrary;

  static double aspectRatio(double width) => width <= 200 ? 9 / 16 : 6 / 9;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: Heroes.galleryViewToConcreteView(uid),
      flightShuttleBuilder: Heroes.crossfadeFlightShuttle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Heroes.galleryCardRadius),
        child: Material(
          color: AppColors.shimmerBase,
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
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    _buildCover(context, constraints),
              ),
              Positioned(top: 6, right: 6, child: _buildLibraryBadge()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryBadge() {
    return IgnorePointer(
      child: AnimatedScale(
        scale: inLibrary ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_rounded,
            size: 14,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, BoxConstraints constraints) {
    final int? decodeWidth = constraints.hasBoundedWidth
        ? decodeWidthFor(context, constraints.maxWidth)
        : null;
    return Ink.image(
      fit: BoxFit.cover,
      image: getImageProvider(
        cover,
        headers: headers,
        decodeWidth: decodeWidth,
      ),
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
                  style: medium(color: AppColors.onMedia).copyWith(
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
    );
  }
}
