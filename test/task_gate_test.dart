import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/page_bitmap.dart';

void main() {
  test('never runs more tasks at once than its capacity', () async {
    final TaskGate gate = TaskGate(2);
    final List<Completer<void>> releases = List<Completer<void>>.generate(
      5,
      (_) => Completer<void>(),
    );
    int running = 0;
    int peak = 0;

    final List<Future<int>> results = <Future<int>>[
      for (int i = 0; i < releases.length; i++)
        gate.run(() async {
          running++;
          peak = running > peak ? running : peak;
          await releases[i].future;
          running--;
          return i;
        }),
    ];

    for (final Completer<void> release in releases) {
      await Future<void>.delayed(Duration.zero);
      release.complete();
    }

    expect(await Future.wait(results), <int>[0, 1, 2, 3, 4]);
    expect(peak, 2);
  });

  test('a failing task frees its slot', () async {
    final TaskGate gate = TaskGate(1);

    await expectLater(
      gate.run<void>(() async => throw StateError('decode failed')),
      throwsStateError,
    );

    expect(await gate.run(() async => 'next'), 'next');
  });
}
