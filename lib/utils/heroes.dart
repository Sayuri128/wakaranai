import 'package:flutter/material.dart';

class Heroes {
  static const double galleryCardRadius = 10.0;

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
    final bool isPush = flightDirection == HeroFlightDirection.push;
    final Widget lowerRouteChild = isPush ? fromChild : toChild;
    final Widget upperRouteChild = isPush ? toChild : fromChild;

    final Animation<double> upperRouteVisibility = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );
    return AnimatedBuilder(
      animation: upperRouteVisibility,
      builder: (BuildContext context, Widget? child) {
        final double radius =
            galleryCardRadius * (1 - upperRouteVisibility.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FadeTransition(
            opacity: ReverseAnimation(upperRouteVisibility),
            child: RepaintBoundary(child: lowerRouteChild),
          ),
          FadeTransition(
            opacity: upperRouteVisibility,
            child: RepaintBoundary(child: upperRouteChild),
          ),
        ],
      ),
    );
  }
}
