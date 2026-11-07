import 'package:capyscript/api_clients/source_error.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/session_failure_classifier.dart';

enum SourceErrorAction { signIn, retry }

class SourceErrorDescription {
  const SourceErrorDescription({
    required this.kind,
    required this.icon,
    required this.title,
    required this.detail,
    required this.actions,
  });

  final SourceErrorKind kind;
  final IconData icon;
  final String title;
  final String? detail;
  final List<SourceErrorAction> actions;

  bool get offersSignIn => actions.contains(SourceErrorAction.signIn);

  bool get offersRetry => actions.contains(SourceErrorAction.retry);

  bool get isNotFound => kind == SourceErrorKind.notFound;

  String get summary {
    final String? secondary = detail;
    if (secondary == null) {
      return title;
    }
    return '$title\n$secondary';
  }
}

SourceError? findSourceError(Object? error) {
  return SessionFailureClassifier.sourceErrorIn(error);
}

SourceErrorDescription? describeSourceError(
  Object? error, {
  required String sourceName,
  required bool canSignIn,
}) {
  final SourceError? sourceError = findSourceError(error);
  if (sourceError == null) {
    return null;
  }
  return SourceErrorDescription(
    kind: sourceError.kind,
    icon: _iconFor(sourceError.kind),
    title: _titleFor(sourceError.kind, sourceName.trim()),
    detail: _detailOf(sourceError),
    actions: _actionsFor(sourceError.kind, canSignIn: canSignIn),
  );
}

String? _detailOf(SourceError error) {
  final String message = error.message.trim();
  if (message.isEmpty) {
    return null;
  }
  return message;
}

String _titleFor(SourceErrorKind kind, String sourceName) {
  switch (kind) {
    case SourceErrorKind.loginRequired:
      return S.current.source_error_login_required_title(sourceName);
    case SourceErrorKind.rateLimited:
      return S.current.source_error_rate_limited_title;
    case SourceErrorKind.notFound:
      return S.current.source_error_not_found_title;
    case SourceErrorKind.regionBlocked:
      return S.current.source_error_region_blocked_title;
    case SourceErrorKind.sourceDown:
      return S.current.source_error_source_down_title;
    case SourceErrorKind.unsupported:
      return S.current.source_error_unsupported_title;
  }
}

IconData _iconFor(SourceErrorKind kind) {
  switch (kind) {
    case SourceErrorKind.loginRequired:
      return Icons.lock_outline_rounded;
    case SourceErrorKind.rateLimited:
      return Icons.hourglass_bottom_rounded;
    case SourceErrorKind.notFound:
      return Icons.search_off_rounded;
    case SourceErrorKind.regionBlocked:
      return Icons.public_off_rounded;
    case SourceErrorKind.sourceDown:
      return Icons.cloud_off_rounded;
    case SourceErrorKind.unsupported:
      return Icons.block_rounded;
  }
}

List<SourceErrorAction> _actionsFor(
  SourceErrorKind kind, {
  required bool canSignIn,
}) {
  switch (kind) {
    case SourceErrorKind.loginRequired:
      if (canSignIn) {
        return const <SourceErrorAction>[SourceErrorAction.signIn];
      }
      return const <SourceErrorAction>[SourceErrorAction.retry];
    case SourceErrorKind.rateLimited:
    case SourceErrorKind.sourceDown:
      return const <SourceErrorAction>[SourceErrorAction.retry];
    case SourceErrorKind.notFound:
    case SourceErrorKind.regionBlocked:
    case SourceErrorKind.unsupported:
      return const <SourceErrorAction>[];
  }
}
