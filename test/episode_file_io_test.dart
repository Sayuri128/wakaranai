import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('episode_file_io_test');
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  test('a cancel during a pending write surfaces only the cancel', () async {
    final File target = File(p.join(dir.path, 'video.mp4.part'));
    final StreamController<List<int>> body = StreamController<List<int>>();
    final CancelToken cancelToken = CancelToken();
    final List<int> chunk = List<int>.filled(4 * 1024 * 1024, 7);

    final Future<int> piping = pipeStreamToFile(
      body.stream,
      target,
      cancelToken: cancelToken,
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    body.add(chunk);
    await Future<void>.microtask(() {});
    cancelToken.cancel('stop');

    Object? caught;
    try {
      await piping;
    } catch (error) {
      caught = error;
    }

    expect(caught, isA<DioException>());
    expect(CancelToken.isCancel(caught! as DioException), isTrue);
    await target.delete();
    expect(target.existsSync(), isFalse);
    await body.close();
  });

  test('a cancel before the first chunk closes the file', () async {
    final File target = File(p.join(dir.path, 'segment.ts.part'));
    final CancelToken cancelToken = CancelToken()..cancel('stop');

    await expectLater(
      pipeStreamToFile(
        Stream<List<int>>.fromIterable(<List<int>>[
          <int>[1, 2, 3],
        ]),
        target,
        cancelToken: cancelToken,
      ),
      throwsA(isA<DioException>()),
    );
    await target.delete();
    expect(target.existsSync(), isFalse);
  });
}
