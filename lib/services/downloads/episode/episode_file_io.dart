import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

const String kPartSuffix = '.part';

File partFileOf(File target) => File('${target.path}$kPartSuffix');

Future<int> pipeStreamToFile(
  Stream<List<int>> body,
  File file, {
  required CancelToken cancelToken,
  FileMode mode = FileMode.write,
  void Function(int chunkLength)? onChunk,
}) async {
  await file.parent.create(recursive: true);
  final RandomAccessFile handle = await file.open(mode: mode);
  try {
    return await _pumpIntoFile(body, handle, cancelToken, onChunk);
  } finally {
    await handle.close();
  }
}

Future<int> _pumpIntoFile(
  Stream<List<int>> body,
  RandomAccessFile handle,
  CancelToken cancelToken,
  void Function(int chunkLength)? onChunk,
) {
  final Completer<int> done = Completer<int>();
  int written = 0;
  late final StreamSubscription<List<int>> subscription;

  void fail(Object error, [StackTrace? stackTrace]) {
    if (done.isCompleted) {
      return;
    }
    done.completeError(error, stackTrace);
    unawaited(subscription.cancel());
  }

  void writeChunk(List<int> chunk) {
    subscription.pause();
    handle.writeFrom(chunk).then((_) {
      written += chunk.length;
      onChunk?.call(chunk.length);
      subscription.resume();
    }, onError: fail);
  }

  subscription = body.listen(
    writeChunk,
    onError: fail,
    onDone: () {
      if (!done.isCompleted) {
        done.complete(written);
      }
    },
    cancelOnError: true,
  );
  if (cancelToken.isCancelled) {
    fail(cancelToken.cancelError!);
  } else {
    unawaited(cancelToken.whenCancel.then(fail));
  }
  return done.future;
}

Future<Uint8List> readStreamFully(
  Stream<List<int>> body, {
  required CancelToken cancelToken,
}) async {
  final BytesBuilder builder = BytesBuilder(copy: false);
  await for (final List<int> chunk in body) {
    throwIfCancelled(cancelToken);
    builder.add(chunk);
  }
  throwIfCancelled(cancelToken);
  return builder.takeBytes();
}

String decodeText(List<int> bytes) {
  return utf8.decode(bytes, allowMalformed: true);
}

Stream<List<int>> sliceByteStream(
  Stream<List<int>> source, {
  required int offset,
  required int length,
}) async* {
  final int end = offset + length;
  int position = 0;
  await for (final List<int> chunk in source) {
    final int chunkStart = position;
    final int chunkEnd = position + chunk.length;
    position = chunkEnd;
    if (chunkEnd <= offset) {
      continue;
    }
    final int from = chunkStart < offset ? offset - chunkStart : 0;
    final int to = chunkEnd > end ? end - chunkStart : chunk.length;
    if (to > from) {
      yield chunk.sublist(from, to);
    }
    if (chunkEnd >= end) {
      break;
    }
  }
}

void throwIfCancelled(CancelToken cancelToken) {
  final DioException? error = cancelToken.cancelError;
  if (error != null) {
    throw error;
  }
}

Future<void> writeTextAtomically(File target, String content) async {
  await target.parent.create(recursive: true);
  final File temp = File('${target.path}.tmp');
  await temp.writeAsString(content, flush: true);
  await temp.rename(target.path);
}

Future<void> deleteIfExists(FileSystemEntity entity) async {
  try {
    if (await entity.exists()) {
      await entity.delete(recursive: true);
    }
  } on FileSystemException {
    return;
  }
}
