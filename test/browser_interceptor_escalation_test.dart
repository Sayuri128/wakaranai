import 'dart:async';

import 'package:capyscript/modules/http/http_interceptor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/widgets/browser_check_banner.dart';
import 'package:wakaranai/ui/services/widgets/browser_interceptor_escalation.dart';
import 'package:wakaranai/utils/browser_challenge_detector.dart';

const BrowserInterceptorChallengeRequired _challenge =
    BrowserInterceptorChallengeRequired(
  url: 'https://example.com',
  kind: BrowserChallengeKind.cloudflare,
);

const BrowserInterceptorLoadFailed _failure = BrowserInterceptorLoadFailed(
  url: 'https://example.com',
  reason: 'timeout',
);

const BrowserInterceptorPageLoaded _pageLoaded = BrowserInterceptorPageLoaded(
  body: '<html></html>',
  data: <String, dynamic>{},
);

BrowserInterceptorLoadingPage _loadingPage() {
  return BrowserInterceptorLoadingPage(
    url: 'https://example.com',
    onLoaded: Completer<HttpInterceptorControllerResponse>(),
    body: null,
  );
}

Future<void> _pumpBanner(
  WidgetTester tester, {
  required bool reconnecting,
  VoidCallback? onOpenBrowser,
  VoidCallback? onDismiss,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: BrowserCheckBanner(
          reconnecting: reconnecting,
          onOpenBrowser: onOpenBrowser ?? () {},
          onDismiss: onDismiss ?? () {},
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('BrowserInterceptorEscalation.onState', () {
    test('a challenge always asks the user', () {
      for (final BrowserInterceptorEscalation current
          in BrowserInterceptorEscalation.values) {
        expect(
          current.onState(_challenge),
          BrowserInterceptorEscalation.challenge,
        );
      }
    });

    test('a load failure marks the interceptor as failed', () {
      expect(
        BrowserInterceptorEscalation.none.onState(_failure),
        BrowserInterceptorEscalation.failed,
      );
      expect(
        BrowserInterceptorEscalation.failed.onState(_failure),
        BrowserInterceptorEscalation.failed,
      );
    });

    test('a load failure does not hide a pending challenge', () {
      expect(
        BrowserInterceptorEscalation.challenge.onState(_failure),
        BrowserInterceptorEscalation.challenge,
      );
    });

    test('a loaded page or a finished init clears the escalation', () {
      for (final BrowserInterceptorEscalation current
          in BrowserInterceptorEscalation.values) {
        expect(
          current.onState(_pageLoaded),
          BrowserInterceptorEscalation.none,
        );
        expect(
          current.onState(BrowserInterceptorInitialized()),
          BrowserInterceptorEscalation.none,
        );
      }
    });

    test('loading and initial states keep the current escalation', () {
      for (final BrowserInterceptorEscalation current
          in BrowserInterceptorEscalation.values) {
        expect(current.onState(_loadingPage()), current);
        expect(current.onState(BrowserInterceptorInitial()), current);
      }
    });
  });

  group('BrowserInterceptorEscalation.onInitCompleted', () {
    test('a successful init clears the escalation', () {
      for (final BrowserInterceptorEscalation current
          in BrowserInterceptorEscalation.values) {
        expect(
          current.onInitCompleted(true),
          BrowserInterceptorEscalation.none,
        );
      }
    });

    test('a failed init without a challenge is a failure', () {
      expect(
        BrowserInterceptorEscalation.none.onInitCompleted(false),
        BrowserInterceptorEscalation.failed,
      );
    });

    test('a failed init keeps a reported challenge', () {
      expect(
        BrowserInterceptorEscalation.challenge.onInitCompleted(false),
        BrowserInterceptorEscalation.challenge,
      );
    });

    test('init result and challenge state agree in either order', () {
      expect(
        BrowserInterceptorEscalation.none
            .onInitCompleted(false)
            .onState(_challenge),
        BrowserInterceptorEscalation.challenge,
      );
      expect(
        BrowserInterceptorEscalation.none
            .onState(_challenge)
            .onInitCompleted(false),
        BrowserInterceptorEscalation.challenge,
      );
    });
  });

  test('only a challenge needs the user, any escalation needs a reconnect', () {
    expect(BrowserInterceptorEscalation.none.needsUser, isFalse);
    expect(BrowserInterceptorEscalation.failed.needsUser, isFalse);
    expect(BrowserInterceptorEscalation.challenge.needsUser, isTrue);
    expect(BrowserInterceptorEscalation.none.needsReconnect, isFalse);
    expect(BrowserInterceptorEscalation.failed.needsReconnect, isTrue);
    expect(BrowserInterceptorEscalation.challenge.needsReconnect, isTrue);
  });

  group('BrowserCheckBanner', () {
    testWidgets('prompts to open the browser and reports taps', (
      WidgetTester tester,
    ) async {
      int opened = 0;
      int dismissed = 0;
      await _pumpBanner(
        tester,
        reconnecting: false,
        onOpenBrowser: () => opened++,
        onDismiss: () => dismissed++,
      );

      expect(
        find.text('This source needs a quick check in the browser'),
        findsOneWidget,
      );
      await tester.tap(find.text('Open browser'));
      await tester.tap(find.byIcon(Icons.close_rounded));

      expect(opened, 1);
      expect(dismissed, 1);
    });

    testWidgets('shows progress instead of actions while reconnecting', (
      WidgetTester tester,
    ) async {
      await _pumpBanner(tester, reconnecting: true);

      expect(find.text('Reconnecting to the source…'), findsOneWidget);
      expect(find.text('Open browser'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
