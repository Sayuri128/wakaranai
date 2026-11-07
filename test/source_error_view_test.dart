import 'package:capyscript/api_clients/source_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';
import 'package:wakaranai/utils/source_error_description.dart';

Widget _host(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  group('SourceErrorView', () {
    SourceErrorDescription describe(SourceError error) {
      return describeSourceError(error, sourceName: 'MangaLib', canSignIn: true)!;
    }

    testWidgets('offers sign in for a login error',
        (WidgetTester tester) async {
      int signIns = 0;
      await tester.pumpWidget(_host(SourceErrorView(
        description: describe(
          const SourceError(SourceErrorKind.loginRequired, 'Session ended'),
        ),
        onRetry: () {},
        onSignIn: () => signIns++,
      )));

      expect(find.text('Sign in to MangaLib'), findsOneWidget);
      expect(find.text('Session ended'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);

      await tester.tap(find.text('Sign in'));
      expect(signIns, 1);
    });

    testWidgets('offers retry for a source that is down',
        (WidgetTester tester) async {
      int retries = 0;
      await tester.pumpWidget(_host(SourceErrorView(
        description: describe(const SourceError(SourceErrorKind.sourceDown)),
        onRetry: () => retries++,
        onSignIn: () {},
      )));

      expect(find.text('The source is down, try again later'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);

      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('shows extra actions for a removed title',
        (WidgetTester tester) async {
      int removals = 0;
      await tester.pumpWidget(_host(SourceErrorView(
        description: describe(const SourceError(SourceErrorKind.notFound)),
        onRetry: () {},
        extraActions: <SourceErrorExtraAction>[
          SourceErrorExtraAction(
            icon: Icons.delete_outline_rounded,
            label: 'Remove from library',
            onPressed: () => removals++,
          ),
        ],
      )));

      expect(find.text('Removed from the source'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);

      await tester.tap(find.text('Remove from library'));
      expect(removals, 1);
    });
  });
}
