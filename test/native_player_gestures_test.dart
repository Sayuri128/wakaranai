import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_gesture_layer.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';

void main() {
  const Duration duration = Duration(minutes: 24);

  test('a full-width drag scrubs by the scrub range', () {
    expect(
      scrubTarget(
        start: const Duration(minutes: 5),
        dragDistance: 800,
        width: 800,
        duration: duration,
      ),
      const Duration(minutes: 5) + kScrubRangePerScreenWidth,
    );
    expect(
      scrubTarget(
        start: const Duration(minutes: 5),
        dragDistance: -400,
        width: 800,
        duration: duration,
      ),
      const Duration(minutes: 5) - kScrubRangePerScreenWidth ~/ 2,
    );
  });

  test('scrubbing is clamped to the video', () {
    expect(
      scrubTarget(
        start: const Duration(seconds: 10),
        dragDistance: -800,
        width: 800,
        duration: duration,
      ),
      Duration.zero,
    );
    expect(
      scrubTarget(
        start: const Duration(minutes: 23, seconds: 50),
        dragDistance: 800,
        width: 800,
        duration: duration,
      ),
      duration,
    );
  });

  test('pinching out fills and pinching in fits', () {
    expect(fitModeForPinch(1.3), PlayerFitMode.fill);
    expect(fitModeForPinch(0.7), PlayerFitMode.fit);
    expect(fitModeForPinch(1.02), isNull);
  });

  test('fit mode cycles through every mode', () {
    expect(nextFitMode(PlayerFitMode.fit), PlayerFitMode.fill);
    expect(nextFitMode(PlayerFitMode.fill), PlayerFitMode.stretch);
    expect(nextFitMode(PlayerFitMode.stretch), PlayerFitMode.fit);
  });

  test('speed labels show the exact multiplier', () {
    expect(speedMultiplierLabel(2), '2×');
    expect(speedMultiplierLabel(1.35), '1.35×');
    expect(speedMultiplierLabel(2.5), '2.5×');
    expect(speedMultiplierLabel(0.25), '0.25×');
  });
}
