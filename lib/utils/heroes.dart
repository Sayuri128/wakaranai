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

    final Animation<double> fadeIn = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        FadeTransition(
          opacity: ReverseAnimation(fadeIn),
          child: RepaintBoundary(child: fromChild),
        ),
        FadeTransition(
          opacity: fadeIn,
          child: RepaintBoundary(child: toChild),
        ),
      ],
    );
  }
}
