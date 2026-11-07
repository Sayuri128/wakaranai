import 'dart:async';
import 'dart:ui';

import 'package:capyscript/AST/throw/capyscript_error.dart';
import 'package:capyscript/Interpreter/capyscript_runtime_error.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/http/http_response.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/source_attention_preferences.dart';
import 'package:wakaranai/services/configs_service/session_failure_classifier.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/library_updates/source_attention_text.dart';

const String _cloudflarePage =
    '<!DOCTYPE html><html lang="en-US"><head><title>Just a moment...</title>'
    '</head><body><div id="cf-challenge-running"></div></body></html>';

ConfigInfo _config({
  String uid = 'ext.protected',
  String name = 'MangaLib',
  bool protected = true,
  bool needToLogin = true,
  String? sessionGroup,
}) {
  return ConfigInfo(
    uid: uid,
    name: name,
    logoUrl: '',
    nsfw: false,
    language: 'en',
    version: 1,
    filters: const [],
    type: ConfigInfoType.MANGA,
    searchAvailable: true,
    protectorConfig: protected
        ? ProtectorConfig(
            pingUrl: 'https://example.com',
            needToLogin: needToLogin,
            inAppBrowserInterceptor: true,
            sessionGroup: sessionGroup,
          )
        : null,
  );
}

SourceAttentionReason? _reasonFor(
  Object error, {
  ConfigInfo? config,
  bool challengeObserved = false,
}) {
  return SessionFailureClassifier.classify(
    error,
    config ?? _config(),
    challengeObserved: challengeObserved,
  )?.reason;
}

CapyHttpResponse _response(int statusCode, String body) {
  return CapyHttpResponse(
    statusCode: statusCode,
    body: body,
    contentLength: body.length,
    headers: const <String, String>{},
  );
}

void main() {
  group('SessionFailureClassifier', () {
    test('challenge HTML that failed to parse as JSON means the session expired',
        () {
      final Object error = CapyScriptRuntimeError(
        const FormatException('Unexpected character', _cloudflarePage, 0),
        <String>['getConcrete'],
      );

      expect(_reasonFor(error), SourceAttentionReason.sessionExpired);
    });

    test('a thrown 401 or 403 response means the session expired', () {
      expect(
        _reasonFor(CapyScriptError(_response(401, '{"message":"no"}'))),
        SourceAttentionReason.sessionExpired,
      );
      expect(
        _reasonFor(CapyScriptRuntimeError(
          CapyScriptError(<String, dynamic>{'statusCode': 403, 'body': ''}),
          <String>['getConcrete'],
        )),
        SourceAttentionReason.sessionExpired,
      );
    });

    test('an explicit auth status in the error text means the session expired',
        () {
      expect(_reasonFor(CapyScriptError('HTTP 403')),
          SourceAttentionReason.sessionExpired);
      expect(_reasonFor(Exception('Request failed with status code: 401')),
          SourceAttentionReason.sessionExpired);
      expect(_reasonFor(Exception('401 Unauthorized')),
          SourceAttentionReason.sessionExpired);
    });

    test('a challenge seen by the interceptor during the call needs a check',
        () {
      expect(
        _reasonFor(Exception('chapter list block not found'),
            challengeObserved: true),
        SourceAttentionReason.challengeRequired,
      );
    });

    test('an already typed attention passes through untouched', () {
      final SourceNeedsAttention attention = SourceNeedsAttention(
        config: _config(),
        reason: SourceAttentionReason.notSignedIn,
      );

      expect(
        identical(
            SessionFailureClassifier.classify(attention, _config()), attention),
        isTrue,
      );
    });

    test('unclear failures stay ordinary failures', () {
      expect(_reasonFor(Exception('network down')), isNull);
      expect(_reasonFor(TimeoutException('slow')), isNull);
      expect(_reasonFor(Exception('chapter 403 not found')), isNull);
      expect(_reasonFor(CapyScriptError(_response(500, 'oops'))), isNull);
      expect(
        _reasonFor(CapyScriptRuntimeError(
          const FormatException('Unexpected end of input', '{"data":', 8),
          <String>['getConcrete'],
        )),
        isNull,
      );
    });

    test('sources without a protector are never flagged', () {
      final ConfigInfo open = _config(protected: false);

      expect(_reasonFor(CapyScriptError('HTTP 403'), config: open), isNull);
      expect(
        _reasonFor(Exception('boom'), config: open, challengeObserved: true),
        isNull,
      );
    });

    test('sources sharing a session group share one session key', () {
      final SourceNeedsAttention mangaLib = SourceNeedsAttention(
        config: _config(uid: 'a', name: 'MangaLib', sessionGroup: 'lib_social'),
        reason: SourceAttentionReason.sessionExpired,
      );
      final SourceNeedsAttention hentaiLib = SourceNeedsAttention(
        config:
            _config(uid: 'b', name: 'HentaiLib', sessionGroup: 'lib_social'),
        reason: SourceAttentionReason.sessionExpired,
      );

      expect(mangaLib.sessionKey, hentaiLib.sessionKey);
    });

    test('a script login error asks the user to sign in', () {
      expect(
        _reasonFor(const SourceError(SourceErrorKind.loginRequired)),
        SourceAttentionReason.loginRequired,
      );
      expect(
        _reasonFor(CapyScriptRuntimeError(
          const SourceError(SourceErrorKind.loginRequired),
          <String>['getConcrete'],
        )),
        SourceAttentionReason.loginRequired,
      );
    });

    test('other script errors are never read as session failures', () {
      for (final SourceErrorKind kind in SourceErrorKind.values) {
        if (kind == SourceErrorKind.loginRequired) {
          continue;
        }
        expect(
          _reasonFor(SourceError(kind, 'HTTP 403')),
          isNull,
          reason: kind.name,
        );
      }
    });

    test('a challenge seen by the interceptor wins over the script error kind',
        () {
      for (final SourceErrorKind kind in SourceErrorKind.values) {
        expect(
          _reasonFor(
            CapyScriptRuntimeError(SourceError(kind), <String>['getConcrete']),
            challengeObserved: true,
          ),
          SourceAttentionReason.challengeRequired,
          reason: kind.name,
        );
      }
    });

    test('a script error carrying a challenge page means the session expired',
        () {
      expect(
        _reasonFor(
            const SourceError(SourceErrorKind.notFound, _cloudflarePage)),
        SourceAttentionReason.sessionExpired,
      );
      expect(
        _reasonFor(
            const SourceError(SourceErrorKind.sourceDown, _cloudflarePage)),
        SourceAttentionReason.sessionExpired,
      );
    });

    test('a script login error on an open source is not flagged', () {
      expect(
        _reasonFor(
          const SourceError(SourceErrorKind.loginRequired),
          config: _config(protected: false),
        ),
        isNull,
      );
    });
  });

  group('SourceAttentionText', () {
    setUpAll(() => S.load(const Locale('en')));

    test('words the message by reason and login need', () {
      expect(
        SourceAttentionText.message(SourceNeedsAttention(
          config: _config(),
          reason: SourceAttentionReason.sessionExpired,
        )),
        'MangaLib needs you to sign in again',
      );
      expect(
        SourceAttentionText.message(SourceNeedsAttention(
          config: _config(),
          reason: SourceAttentionReason.notSignedIn,
        )),
        'MangaLib needs you to sign in',
      );
      expect(
        SourceAttentionText.message(SourceNeedsAttention(
          config: _config(name: 'AniTube', needToLogin: false),
          reason: SourceAttentionReason.sessionExpired,
        )),
        'AniTube needs a quick check in the browser',
      );
      expect(
        SourceAttentionText.message(SourceNeedsAttention(
          config: _config(name: 'AniTube', needToLogin: false),
          reason: SourceAttentionReason.loginRequired,
        )),
        'AniTube needs you to sign in',
      );
      expect(
        SourceAttentionText.notificationTitle(<SourceNeedsAttention>[
          SourceNeedsAttention(
            config: _config(),
            reason: SourceAttentionReason.sessionExpired,
          ),
        ]),
        'Sign in needed: MangaLib',
      );
    });
  });

  group('SourceAttentionPreferences', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('notifies about a source at most once a day', () async {
      final SourceAttentionPreferences preferences =
          SourceAttentionPreferences();
      final List<SourceNeedsAttention> attentions = <SourceNeedsAttention>[
        SourceNeedsAttention(
          config: _config(sessionGroup: 'lib_social'),
          reason: SourceAttentionReason.sessionExpired,
        ),
      ];
      final DateTime morning = DateTime(2026, 11, 7, 8);

      expect(await preferences.dueForNotification(attentions, morning),
          hasLength(1));

      await preferences.markNotified(attentions, morning);

      expect(
        await preferences.dueForNotification(
            attentions, morning.add(const Duration(hours: 23))),
        isEmpty,
      );
      expect(
        await preferences.dueForNotification(
            attentions, morning.add(const Duration(days: 1))),
        hasLength(1),
      );

      await preferences.clear(attentions.single.sessionKey);
      expect(await preferences.dueForNotification(attentions, morning),
          hasLength(1));
    });
  });
}
