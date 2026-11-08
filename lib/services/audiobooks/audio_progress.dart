import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';

class AudioProgress {
  AudioProgress._();

  static const Duration finishedTail = Duration(seconds: 15);
  static const double finishedFraction = 0.98;
  static const Duration rewindOnResume = Duration(seconds: 2);

  static bool isFinished(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return false;
    }
    return activity.readPages >= activity.totalPages;
  }

  static double fractionOf(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return 0;
    }
    return (activity.readPages / activity.totalPages).clamp(0.0, 1.0).toDouble();
  }

  static Duration positionOf(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return Duration.zero;
    }
    return Duration(seconds: activity.readPages);
  }

  static Duration durationOf(ChapterActivityDomain? activity) {
    if (activity == null || activity.totalPages <= 0) {
      return Duration.zero;
    }
    return Duration(seconds: activity.totalPages);
  }

  static Duration resumePositionOf(ChapterActivityDomain? activity) {
    if (isFinished(activity)) {
      return Duration.zero;
    }
    final Duration position = positionOf(activity) - rewindOnResume;
    if (position.isNegative) {
      return Duration.zero;
    }
    return position;
  }

  static bool reachedEnd({
    required Duration position,
    required Duration duration,
  }) {
    if (duration <= Duration.zero) {
      return false;
    }
    if (position >= duration - _tailOf(duration)) {
      return true;
    }
    return position.inMilliseconds / duration.inMilliseconds >=
        finishedFraction;
  }

  static Duration _tailOf(Duration duration) {
    final Duration tenth = duration ~/ 10;
    if (tenth < finishedTail) {
      return tenth;
    }
    return finishedTail;
  }

  static int? storedSecondsOf(Duration duration) {
    final int seconds = duration.inSeconds;
    if (seconds <= 0) {
      return null;
    }
    return seconds;
  }

  static ChapterActivityDomain? activityFor({
    required Chapter track,
    required int concreteId,
    required Duration position,
    required Duration duration,
    bool finished = false,
  }) {
    final int? totalSeconds = storedSecondsOf(duration);
    if (totalSeconds == null) {
      return null;
    }
    int readSeconds = position.inSeconds.clamp(0, totalSeconds);
    if (finished || reachedEnd(position: position, duration: duration)) {
      readSeconds = totalSeconds;
    } else if (readSeconds >= totalSeconds) {
      readSeconds = totalSeconds - 1;
    }
    return ChapterActivityDomain(
      id: 0,
      uid: track.uid,
      concreteId: concreteId,
      title: track.title,
      data: jsonEncode(track.data),
      timestamp: track.timestamp,
      readPages: readSeconds,
      totalPages: totalSeconds,
      createdAt: DateTime.now(),
    );
  }

  static int completedUnits(ChapterActivityDomain? existing) {
    if (existing != null && existing.totalPages > 0) {
      return existing.totalPages;
    }
    return 1;
  }

  static String formatClock(Duration value) {
    final Duration safe = value.isNegative ? Duration.zero : value;
    final int hours = safe.inHours;
    final String minutes = safe.inMinutes.remainder(60).toString();
    final String seconds =
        safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String progressLabel(ChapterActivityDomain activity) {
    return '${formatClock(positionOf(activity))} / '
        '${formatClock(durationOf(activity))}';
  }
}
