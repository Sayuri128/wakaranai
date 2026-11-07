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
  final _FilePump pump = _FilePump(handle, onChunk);
  bool succeeded = false;
  try {
    final int written = await pump.run(body, cancelToken);
    succeeded = true;
    return written;
  } finally {
    await pump.settle();
    await _closeHandle(handle, quietly: !succeeded);
  }
}

Future<void> _closeHandle(
  RandomAccessFile handle, {
  required bool quietly,
}) async {
  try {
    await handle.close();
  } on FileSystemException {
    if (!quietly) {
      rethrow;
    }
  }
}

class _FilePump {
  _FilePump(this._handle, this._onChunk);

  final RandomAccessFile _handle;
  final void Function(int chunkLength)? _onChunk;
  final Completer<int> _done = Completer<int>();
  late final StreamSubscription<List<int>> _subscription;
  Future<void>? _pendingWrite;
  int _written = 0;

  Future<int> run(Stream<List<int>> body, CancelToken cancelToken) {
    _subscription = body.listen(
      _writeChunk,
      onError: _fail,
      onDone: _finish,
      cancelOnError: true,
    );
    final DioException? cancelError = cancelToken.cancelError;
    if (cancelError != null) {
      _fail(cancelError);
    } else {
      unawaited(cancelToken.whenCancel.then(_fail));
    }
    return _done.future;
  }

  Future<void> settle() async {
    final Future<void>? pendingWrite = _pendingWrite;
    if (pendingWrite == null) {
      return;
    }
    try {
      await pendingWrite;
    } catch (_) {
      return;
    }
  }

  void _writeChunk(List<int> chunk) {
    _subscription.pause();
    final Future<void> write = _handle.writeFrom(chunk);
    _pendingWrite = write;
    write.then((_) => _afterWrite(chunk.length), onError: _fail);
  }

  void _afterWrite(int chunkLength) {
    if (_done.isCompleted) {
      return;
    }
    _written += chunkLength;
    _onChunk?.call(chunkLength);
    _subscription.resume();
  }

  void _finish() {
    if (!_done.isCompleted) {
      _done.complete(_written);
    }
  }

  void _fail(Object error, [StackTrace? stackTrace]) {
    if (_done.isCompleted) {
      return;
    }
    _done.completeError(error, stackTrace);
    unawaited(_subscription.cancel());
  }
}

class StreamHead {
  StreamHead._(this._chunks, this._rest);

  final List<List<int>> _chunks;
  final StreamIterator<List<int>>? _rest;

  Uint8List get bytes {
    final BytesBuilder builder = BytesBuilder(copy: true);
    for (final List<int> chunk in _chunks) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Stream<List<int>> get body async* {
    for (final List<int> chunk in _chunks) {
      yield chunk;
    }
    final StreamIterator<List<int>>? rest = _rest;
    if (rest == null) {
      return;
    }
    try {
      while (await rest.moveNext()) {
        yield rest.current;
      }
    } finally {
      await rest.cancel();
    }
  }

  Future<void> discard() async {
    await _rest?.cancel();
  }
}

Future<StreamHead> peekStreamHead(Stream<List<int>> source, int length) async {
  final StreamIterator<List<int>> iterator = StreamIterator<List<int>>(source);
  final List<List<int>> chunks = <List<int>>[];
  int peeked = 0;
  try {
    while (peeked < length) {
      if (!await iterator.moveNext()) {
        return StreamHead._(chunks, null);
      }
      chunks.add(iterator.current);
      peeked += iterator.current.length;
    }
  } catch (_) {
    await iterator.cancel();
    rethrow;
  }
  return StreamHead._(chunks, iterator);
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
