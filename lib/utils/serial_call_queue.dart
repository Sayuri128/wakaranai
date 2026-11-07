final Expando<Future<void>> _pendingCallTails =
    Expando<Future<void>>('serialCallTail');

Future<R> runSerializedOn<R>(Object owner, Future<R> Function() call) {
  final Future<void> previous = _pendingCallTails[owner] ?? Future<void>.value();
  final Future<R> result = previous.then((_) => call());
  _pendingCallTails[owner] = result.then<void>(
    (R _) {},
    onError: (Object _) {},
  );
  return result;
}
