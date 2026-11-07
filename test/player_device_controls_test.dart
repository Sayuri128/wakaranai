import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';

void main() {
  group('shouldRestoreVolume', () {
    test('restores after a swipe left the volume changed', () {
      expect(
        shouldRestoreVolume(
          openingVolume: 0.4,
          lastGestureVolume: 0.8,
          currentVolume: 0.8,
        ),
        isTrue,
      );
    });

    test('leaves the volume alone without a swipe', () {
      expect(
        shouldRestoreVolume(
          openingVolume: 0.4,
          lastGestureVolume: null,
          currentVolume: 0.7,
        ),
        isFalse,
      );
    });

    test('leaves a hardware key change after the last swipe alone', () {
      expect(
        shouldRestoreVolume(
          openingVolume: 0.4,
          lastGestureVolume: 0.8,
          currentVolume: 0.733,
        ),
        isFalse,
      );
    });

    test('does nothing when the volume is already back where it started', () {
      expect(
        shouldRestoreVolume(
          openingVolume: 0.4,
          lastGestureVolume: 0.4,
          currentVolume: 0.4,
        ),
        isFalse,
      );
    });

    test('does nothing when a volume could not be read', () {
      expect(
        shouldRestoreVolume(
          openingVolume: null,
          lastGestureVolume: 0.8,
          currentVolume: 0.8,
        ),
        isFalse,
      );
      expect(
        shouldRestoreVolume(
          openingVolume: 0.4,
          lastGestureVolume: 0.8,
          currentVolume: null,
        ),
        isFalse,
      );
    });
  });
}
