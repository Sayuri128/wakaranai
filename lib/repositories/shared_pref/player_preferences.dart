import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kMinPlaybackSpeed = 0.25;
const double kMaxPlaybackSpeed = 4.0;
const double kPlaybackSpeedStep = 0.05;

const List<double> kHoldSpeedOptions = <double>[1.5, 2.0, 3.0, 4.0];
const List<int> kSkipOpeningOptions = <int>[60, 75, 85, 90, 120];

const double kDefaultHoldSpeed = 2.0;
const double kHoldSpeedStepFactor = 1.5;
const int kDefaultSkipOpeningSeconds = 85;
const bool kDefaultAutoPlayNext = true;
const bool kDefaultAutoSkipMarkers = false;

enum PlayerFitMode { fit, fill, stretch }

PlayerFitMode nextFitMode(PlayerFitMode mode) {
  final List<PlayerFitMode> modes = PlayerFitMode.values;
  return modes[(mode.index + 1) % modes.length];
}

double normalizePlaybackSpeed(double speed) {
  if (speed.isNaN) {
    return 1.0;
  }
  final double clamped = speed.clamp(kMinPlaybackSpeed, kMaxPlaybackSpeed);
  final double steps = (clamped / kPlaybackSpeedStep).roundToDouble();
  final double stepped = steps * kPlaybackSpeedStep;
  return double.parse(stepped.toStringAsFixed(2));
}

double? holdPlaybackSpeed({
  required double currentSpeed,
  required double configuredHoldSpeed,
}) {
  if (configuredHoldSpeed > currentSpeed) {
    return configuredHoldSpeed;
  }
  final double stepped =
      normalizePlaybackSpeed(currentSpeed * kHoldSpeedStepFactor);
  if (stepped <= currentSpeed) {
    return null;
  }
  return stepped;
}

enum SubtitlePreferenceKind { off, language, label }

class SubtitlePreference {
  const SubtitlePreference.off()
      : kind = SubtitlePreferenceKind.off,
        value = '';

  const SubtitlePreference.language(this.value)
      : kind = SubtitlePreferenceKind.language;

  const SubtitlePreference.label(this.value)
      : kind = SubtitlePreferenceKind.label;

  final SubtitlePreferenceKind kind;
  final String value;

  String encode() {
    if (kind == SubtitlePreferenceKind.off) {
      return kind.name;
    }
    return '${kind.name}:$value';
  }

  static SubtitlePreference? decode(String? stored) {
    if (stored == null || stored.isEmpty) {
      return null;
    }
    if (stored == SubtitlePreferenceKind.off.name) {
      return const SubtitlePreference.off();
    }
    final int separator = stored.indexOf(':');
    if (separator <= 0) {
      return null;
    }
    final String kindName = stored.substring(0, separator);
    final String value = stored.substring(separator + 1);
    if (value.isEmpty) {
      return null;
    }
    if (kindName == SubtitlePreferenceKind.language.name) {
      return SubtitlePreference.language(value);
    }
    if (kindName == SubtitlePreferenceKind.label.name) {
      return SubtitlePreference.label(value);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return other is SubtitlePreference &&
        other.kind == kind &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(kind, value);
}

class QualityPreference {
  const QualityPreference({
    this.streamLabel,
    this.renditionLabel,
    this.audioLabel,
  }) : fromLegacyLabel = false;

  const QualityPreference.legacy(String label)
      : streamLabel = label,
        renditionLabel = label,
        audioLabel = null,
        fromLegacyLabel = true;

  final String? streamLabel;
  final String? renditionLabel;
  final String? audioLabel;
  final bool fromLegacyLabel;

  bool get isEmpty => streamLabel == null && renditionLabel == null;

  @override
  bool operator ==(Object other) {
    return other is QualityPreference &&
        other.streamLabel == streamLabel &&
        other.renditionLabel == renditionLabel &&
        other.audioLabel == audioLabel &&
        other.fromLegacyLabel == fromLegacyLabel;
  }

  @override
  int get hashCode =>
      Object.hash(streamLabel, renditionLabel, audioLabel, fromLegacyLabel);
}

String? _trimmedOrNull(String? value) {
  final String? trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class PlayerPreferences {
  static const String playbackSpeedKey = 'PLAYER_PLAYBACK_SPEED';
  static const String holdSpeedKey = 'PLAYER_HOLD_SPEED';
  static const String subtitleKey = 'PLAYER_SUBTITLE';
  static const String legacyQualityKey = 'PLAYER_QUALITY';
  static const String qualityStreamKey = 'PLAYER_QUALITY_STREAM';
  static const String qualityRenditionKey = 'PLAYER_QUALITY_RENDITION';
  static const String qualityAudioKey = 'PLAYER_QUALITY_AUDIO';
  static const String skipOpeningSecondsKey = 'PLAYER_SKIP_OPENING_SECONDS';
  static const String autoPlayNextKey = 'PLAYER_AUTO_PLAY_NEXT';
  static const String fitModeKey = 'PLAYER_FIT_MODE';
  static const String autoSkipMarkersKey = 'PLAYER_AUTO_SKIP_MARKERS';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<double> getPlaybackSpeed() async {
    final SharedPreferences preferences = await _load();
    final double? stored = preferences.getDouble(playbackSpeedKey);
    if (stored == null) {
      return 1.0;
    }
    return normalizePlaybackSpeed(stored);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final SharedPreferences preferences = await _load();
    await preferences.setDouble(
      playbackSpeedKey,
      normalizePlaybackSpeed(speed),
    );
  }

  Future<double> getHoldSpeed() async {
    final SharedPreferences preferences = await _load();
    final double? stored = preferences.getDouble(holdSpeedKey);
    if (stored == null || !kHoldSpeedOptions.contains(stored)) {
      return kDefaultHoldSpeed;
    }
    return stored;
  }

  Future<void> setHoldSpeed(double speed) async {
    final SharedPreferences preferences = await _load();
    await preferences.setDouble(holdSpeedKey, speed);
  }

  Future<SubtitlePreference?> getSubtitle() async {
    final SharedPreferences preferences = await _load();
    return SubtitlePreference.decode(preferences.getString(subtitleKey));
  }

  Future<void> setSubtitle(SubtitlePreference preference) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(subtitleKey, preference.encode());
  }

  Future<QualityPreference> getQualityPreference() async {
    final SharedPreferences preferences = await _load();
    final String? streamLabel =
        _trimmedOrNull(preferences.getString(qualityStreamKey));
    final String? renditionLabel =
        _trimmedOrNull(preferences.getString(qualityRenditionKey));
    final String? audioLabel =
        _trimmedOrNull(preferences.getString(qualityAudioKey));
    if (streamLabel != null || renditionLabel != null || audioLabel != null) {
      return QualityPreference(
        streamLabel: streamLabel,
        renditionLabel: renditionLabel,
        audioLabel: audioLabel,
      );
    }
    final String? legacyLabel =
        _trimmedOrNull(preferences.getString(legacyQualityKey));
    if (legacyLabel == null) {
      return const QualityPreference();
    }
    return QualityPreference.legacy(legacyLabel);
  }

  Future<void> setQualityPreference(QualityPreference preference) async {
    final SharedPreferences preferences = await _load();
    await _writeOptionalString(
      preferences,
      qualityStreamKey,
      _trimmedOrNull(preference.streamLabel),
    );
    await _writeOptionalString(
      preferences,
      qualityRenditionKey,
      _trimmedOrNull(preference.renditionLabel),
    );
    await _writeOptionalString(
      preferences,
      qualityAudioKey,
      _trimmedOrNull(preference.audioLabel),
    );
    await preferences.remove(legacyQualityKey);
  }

  Future<void> _writeOptionalString(
    SharedPreferences preferences,
    String key,
    String? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }
    await preferences.setString(key, value);
  }

  Future<int> getSkipOpeningSeconds() async {
    final SharedPreferences preferences = await _load();
    final int? stored = preferences.getInt(skipOpeningSecondsKey);
    if (stored == null || !kSkipOpeningOptions.contains(stored)) {
      return kDefaultSkipOpeningSeconds;
    }
    return stored;
  }

  Future<void> setSkipOpeningSeconds(int seconds) async {
    final SharedPreferences preferences = await _load();
    await preferences.setInt(skipOpeningSecondsKey, seconds);
  }

  Future<bool> getAutoPlayNext() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(autoPlayNextKey) ?? kDefaultAutoPlayNext;
  }

  Future<void> setAutoPlayNext(bool enabled) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(autoPlayNextKey, enabled);
  }

  Future<bool> getAutoSkipMarkers() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(autoSkipMarkersKey) ?? kDefaultAutoSkipMarkers;
  }

  Future<void> setAutoSkipMarkers(bool enabled) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(autoSkipMarkersKey, enabled);
  }

  Future<PlayerFitMode> getFitMode() async {
    final SharedPreferences preferences = await _load();
    final String? stored = preferences.getString(fitModeKey);
    return PlayerFitMode.values.firstWhereOrNull(
          (PlayerFitMode mode) => mode.name == stored,
        ) ??
        PlayerFitMode.fit;
  }

  Future<void> setFitMode(PlayerFitMode mode) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(fitModeKey, mode.name);
  }
}
