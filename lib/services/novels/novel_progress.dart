import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';

class NovelProgress {
  NovelProgress._();

  static const int scale = 1000;
  static const double completedFraction = 0.98;

  static double clampFraction(double fraction) {
    if (fraction.isNaN) {
      return 0;
    }
    return fraction.clamp(0.0, 1.0).toDouble();
  }

  static int unitsFor(double fraction, {bool keepCompleted = false}) {
    if (keepCompleted) {
      return scale;
    }
    final double clamped = clampFraction(fraction);
    if (clamped >= completedFraction) {
      return scale;
    }
    return (clamped * scale).round();
  }

  static bool isCompletedFraction(double fraction) {
    return clampFraction(fraction) >= completedFraction;
  }

  static double fractionOf(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return 0;
    }
    return clampFraction(activity.readPages / activity.totalPages);
  }

  static bool isFinished(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return false;
    }
    return activity.readPages >= activity.totalPages;
  }

  static double resumeFractionOf(ChapterActivityDomain? activity) {
    if (isFinished(activity)) {
      return 0;
    }
    return fractionOf(activity);
  }

  static int percentOf(ChapterActivityDomain activity) {
    return (fractionOf(activity) * 100).floor();
  }

  static double scrollFraction({
    required double offset,
    required double maxExtent,
  }) {
    if (maxExtent <= 0) {
      return 1;
    }
    return clampFraction(offset / maxExtent);
  }
}
