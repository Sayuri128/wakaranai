import 'package:flutter/material.dart';

class Heroes {
  static String galleryViewToConcreteView(String uid) =>
      "galleryViewToConcreteView_$uid";

  /// Crossfades the source and destination hero children over the flight so
  /// endpoints with different treatments (gallery card: rounded, dark title
  /// gradient, title text — vs concrete cover: square, background fade) morph
  /// smoothly instead of hard-swapping at flight start.
  static Widget crossfadeFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Widget fromChild = (fromHeroContext.widget as Hero).child;
    final Widget toChild = (toHeroContext.widget as Hero).child;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeInOut.transform(animation.value);
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Opacity(opacity: (1.0 - t).clamp(0.0, 1.0), child: fromChild),
            Opacity(opacity: t.clamp(0.0, 1.0), child: toChild),
          ],
        );
      },
    );
  }
}
