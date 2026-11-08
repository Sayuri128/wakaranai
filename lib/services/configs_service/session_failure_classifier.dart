import 'package:capyscript/AST/throw/capyscript_error.dart';
import 'package:capyscript/Interpreter/capyscript_runtime_error.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/http/http_response.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/utils/browser_challenge_detector.dart';

class SessionFailureClassifier {
  const SessionFailureClassifier._();

  static const Set<int> authFailureStatusCodes = <int>{401, 403};
  static const int _maxUnwrapDepth = 6;

  static final RegExp _labelledAuthStatusPattern = RegExp(
    r'\b(?:status(?:\s*code)?|statusCode|http(?:\s*error)?)\s*[:=(]?\s*(?:401|403)\b',
    caseSensitive: false,
  );
  static final RegExp _namedAuthStatusPattern = RegExp(
    r'\b(?:401\s+unauthorized|403\s+forbidden)\b',
    caseSensitive: false,
  );

  static SourceNeedsAttention? classify(
    Object error,
    ConfigInfo config, {
    bool challengeObserved = false,
  }) {
    if (error is SourceNeedsAttention) {
      return error;
    }
    if (config.protectorConfig == null) {
      return null;
    }
    if (challengeObserved) {
      return SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.challengeRequired,
      );
    }
    final SourceError? sourceError = sourceErrorIn(error);
    if (sourceError != null) {
      return _attentionForSourceError(sourceError, config);
    }
    if (indicatesExpiredSession(error)) {
      return SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.sessionExpired,
      );
    }
    return null;
  }

  static SourceNeedsAttention? _attentionForSourceError(
    SourceError sourceError,
    ConfigInfo config,
  ) {
    if (sourceError.kind == SourceErrorKind.loginRequired) {
      return SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.loginRequired,
      );
    }
    if (BrowserChallengeDetector.isChallenge(sourceError.message)) {
      return SourceNeedsAttention(
        config: config,
        reason: SourceAttentionReason.sessionExpired,
      );
    }
    return null;
  }

  static SourceError? sourceErrorIn(Object? error) {
    if (error == null) {
      return null;
    }
    for (final Object cause in _causeChain(error)) {
      if (cause is SourceError) {
        return cause;
      }
    }
    return null;
  }

  static bool indicatesExpiredSession(Object error) {
    for (final Object cause in _causeChain(error)) {
      if (_causeIndicatesExpiredSession(cause)) {
        return true;
      }
    }
    return false;
  }

  static bool _causeIndicatesExpiredSession(Object cause) {
    if (cause is CapyHttpResponse) {
      return _responseIndicatesExpiredSession(cause.statusCode, cause.body);
    }
    if (cause is Map) {
      final Object? statusCode = cause['statusCode'];
      final Object? body = cause['body'];
      if (statusCode is int) {
        return _responseIndicatesExpiredSession(
          statusCode,
          body is String ? body : '',
        );
      }
    }
    if (cause is FormatException) {
      final Object? source = cause.source;
      if (source is String && BrowserChallengeDetector.isChallenge(source)) {
        return true;
      }
    }
    return textIndicatesExpiredSession(cause.toString());
  }

  static bool _responseIndicatesExpiredSession(int statusCode, String body) {
    if (authFailureStatusCodes.contains(statusCode)) {
      return true;
    }
    return BrowserChallengeDetector.isChallenge(body);
  }

  static bool textIndicatesExpiredSession(String text) {
    if (_labelledAuthStatusPattern.hasMatch(text)) {
      return true;
    }
    if (_namedAuthStatusPattern.hasMatch(text)) {
      return true;
    }
    return BrowserChallengeDetector.isChallenge(text);
  }

  static Iterable<Object> _causeChain(Object error) sync* {
    Object? current = error;
    int depth = 0;
    while (current != null && depth < _maxUnwrapDepth) {
      yield current;
      depth++;
      if (current is CapyScriptRuntimeError) {
        current = current.cause;
      } else if (current is CapyScriptError) {
        current = current.value;
      } else {
        current = null;
      }
    }
  }
}
