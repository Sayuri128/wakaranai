import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';

String? _normalized(String? value) {
  final String? trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed.toLowerCase();
}

String? _primaryLanguageTag(String? language) {
  final String? normalized = _normalized(language);
  if (normalized == null) {
    return null;
  }
  return normalized.split(RegExp('[-_]')).first;
}

int preferredStreamIndex(
  List<PlayableStream> streams,
  String? preferredQuality, {
  String? preferredAudio,
}) {
  final String? wantedQuality = _normalized(preferredQuality);
  final String? wantedAudio = _normalized(preferredAudio);
  bool sameQuality(PlayableStream stream) {
    return wantedQuality != null && _normalized(stream.quality) == wantedQuality;
  }

  bool sameAudio(PlayableStream stream) {
    return wantedAudio != null && _normalized(stream.audioLabel) == wantedAudio;
  }

  final List<bool Function(PlayableStream stream)> matchers =
      <bool Function(PlayableStream stream)>[
    (PlayableStream stream) => sameQuality(stream) && sameAudio(stream),
    sameAudio,
    sameQuality,
  ];
  for (final bool Function(PlayableStream stream) matcher in matchers) {
    final int index = streams.indexWhere(matcher);
    if (index >= 0) {
      return index;
    }
  }
  return 0;
}

SubtitlePreference? subtitlePreferenceFor(PlayableSubtitle subtitle) {
  final String? language = subtitle.language?.trim();
  if (language != null && language.isNotEmpty) {
    return SubtitlePreference.language(language);
  }
  final String? label = subtitle.label?.trim();
  if (label != null && label.isNotEmpty) {
    return SubtitlePreference.label(label);
  }
  return null;
}

int? preferredSubtitleIndex(
  List<PlayableSubtitle> subtitles,
  SubtitlePreference? preference,
) {
  if (preference == null || preference.kind == SubtitlePreferenceKind.off) {
    return null;
  }
  final String? wanted = _normalized(preference.value);
  if (wanted == null) {
    return null;
  }
  final List<int? Function()> matchers = _subtitleMatchers(
    subtitles,
    preference.kind,
    wanted,
  );
  for (final int? Function() matcher in matchers) {
    final int? index = matcher();
    if (index != null) {
      return index;
    }
  }
  return null;
}

List<int? Function()> _subtitleMatchers(
  List<PlayableSubtitle> subtitles,
  SubtitlePreferenceKind kind,
  String wanted,
) {
  int? byLanguage() => _indexWhere(
        subtitles,
        (PlayableSubtitle subtitle) => _normalized(subtitle.language) == wanted,
      );
  int? byLabel() => _indexWhere(
        subtitles,
        (PlayableSubtitle subtitle) => _normalized(subtitle.label) == wanted,
      );
  int? byPrimaryLanguage() => _indexWhere(
        subtitles,
        (PlayableSubtitle subtitle) =>
            _primaryLanguageTag(subtitle.language) ==
            _primaryLanguageTag(wanted),
      );
  if (kind == SubtitlePreferenceKind.language) {
    return <int? Function()>[byLanguage, byPrimaryLanguage, byLabel];
  }
  return <int? Function()>[byLabel, byLanguage];
}

int? _indexWhere(
  List<PlayableSubtitle> subtitles,
  bool Function(PlayableSubtitle subtitle) test,
) {
  final int index = subtitles.indexWhere(test);
  if (index < 0) {
    return null;
  }
  return index;
}
