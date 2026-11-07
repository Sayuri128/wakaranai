import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';

enum BrowserInterceptorEscalation {
  none,
  challenge,
  failed;

  bool get needsReconnect => this != BrowserInterceptorEscalation.none;

  bool get needsUser => this == BrowserInterceptorEscalation.challenge;

  BrowserInterceptorEscalation onState(BrowserInterceptorState state) {
    if (state is BrowserInterceptorChallengeRequired) {
      return BrowserInterceptorEscalation.challenge;
    }
    if (state is BrowserInterceptorLoadFailed) {
      if (needsUser) {
        return this;
      }
      return BrowserInterceptorEscalation.failed;
    }
    if (state is BrowserInterceptorPageLoaded ||
        state is BrowserInterceptorInitialized) {
      return BrowserInterceptorEscalation.none;
    }
    return this;
  }

  BrowserInterceptorEscalation onInitCompleted(bool succeeded) {
    if (succeeded) {
      return BrowserInterceptorEscalation.none;
    }
    if (this == BrowserInterceptorEscalation.none) {
      return BrowserInterceptorEscalation.failed;
    }
    return this;
  }
}
