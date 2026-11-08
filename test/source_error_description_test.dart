import 'dart:ui';

import 'package:capyscript/Interpreter/capyscript_runtime_error.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/source_error_description.dart';

SourceErrorDescription? _describe(
  Object? error, {
  bool canSignIn = true,
}) {
  return describeSourceError(
    error,
    sourceName: 'MangaLib',
    canSignIn: canSignIn,
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('a login error asks to sign in to the source', () {
    final SourceErrorDescription description =
        _describe(const SourceError(SourceErrorKind.loginRequired))!;

    expect(description.title, 'Sign in to MangaLib');
    expect(description.actions, <SourceErrorAction>[SourceErrorAction.signIn]);
    expect(description.offersSignIn, isTrue);
    expect(description.offersRetry, isFalse);
  });

  test('a login error falls back to retry when the source has no sign in', () {
    final SourceErrorDescription description = _describe(
      const SourceError(SourceErrorKind.loginRequired),
      canSignIn: false,
    )!;

    expect(description.actions, <SourceErrorAction>[SourceErrorAction.retry]);
  });

  test('each kind maps to its own title and actions', () {
    final Map<SourceErrorKind, String> titles = <SourceErrorKind, String>{
      SourceErrorKind.rateLimited: 'Too many requests, try again later',
      SourceErrorKind.notFound: 'Removed from the source',
      SourceErrorKind.regionBlocked: 'Not available in your region',
      SourceErrorKind.sourceDown: 'The source is down, try again later',
      SourceErrorKind.unsupported: 'Not supported by this source',
    };
    final Map<SourceErrorKind, List<SourceErrorAction>> actions =
        <SourceErrorKind, List<SourceErrorAction>>{
      SourceErrorKind.rateLimited: <SourceErrorAction>[SourceErrorAction.retry],
      SourceErrorKind.notFound: <SourceErrorAction>[],
      SourceErrorKind.regionBlocked: <SourceErrorAction>[],
      SourceErrorKind.sourceDown: <SourceErrorAction>[SourceErrorAction.retry],
      SourceErrorKind.unsupported: <SourceErrorAction>[],
    };

    for (final SourceErrorKind kind in titles.keys) {
      final SourceErrorDescription description =
          _describe(SourceError(kind))!;
      expect(description.kind, kind);
      expect(description.title, titles[kind], reason: kind.name);
      expect(description.actions, actions[kind], reason: kind.name);
    }
  });

  test('every kind is described', () {
    for (final SourceErrorKind kind in SourceErrorKind.values) {
      expect(_describe(SourceError(kind)), isNotNull, reason: kind.name);
    }
  });

  test('the script message becomes secondary text', () {
    final SourceErrorDescription description = _describe(
      const SourceError(SourceErrorKind.sourceDown, '  Maintenance until 5pm '),
    )!;

    expect(description.detail, 'Maintenance until 5pm');
    expect(
      description.summary,
      'The source is down, try again later\nMaintenance until 5pm',
    );
  });

  test('an empty script message adds no secondary text', () {
    final SourceErrorDescription description =
        _describe(const SourceError(SourceErrorKind.notFound, '   '))!;

    expect(description.detail, isNull);
    expect(description.summary, 'Removed from the source');
    expect(description.isNotFound, isTrue);
  });

  test('a source error wrapped by the runtime is still recognised', () {
    final SourceErrorDescription? description = _describe(
      CapyScriptRuntimeError(
        const SourceError(SourceErrorKind.regionBlocked),
        <String>['getGallery'],
      ),
    );

    expect(description?.kind, SourceErrorKind.regionBlocked);
  });

  test('other errors keep the generic presentation', () {
    expect(_describe(Exception('network down')), isNull);
    expect(_describe(null), isNull);
    expect(_describe('SourceError(notFound)'), isNull);
  });
}
