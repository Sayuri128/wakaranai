import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_bottom_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_top_bar.dart';

const Size _landscape = Size(800, 400);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = _landscape;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[child, const Spacer()],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

NativePlayerTopBar _topBar({
  VoidCallback? onEpisodes,
  VoidCallback? onGroups,
  VoidCallback? onSubtitles,
  VoidCallback? onQuality,
  String? qualityLabel,
  double playbackSpeed = 1.0,
  VoidCallback? onBack,
  VoidCallback? onMore,
}) {
  return NativePlayerTopBar(
    title: 'Frieren',
    subtitle: 'Episode 3',
    onBack: onBack ?? () {},
    playbackSpeed: playbackSpeed,
    onSpeed: () {},
    onMore: onMore ?? () {},
    onEpisodes: onEpisodes,
    onGroups: onGroups,
    onSubtitles: onSubtitles,
    onQuality: onQuality,
    qualityLabel: qualityLabel,
  );
}

NativePlayerBottomControls _bottomControls({
  bool showEpisodeNavigation = true,
  VoidCallback? onPreviousEpisode,
  VoidCallback? onNextEpisode,
}) {
  return NativePlayerBottomControls(
    isPlaying: false,
    onTogglePlay: () {},
    fitMode: PlayerFitMode.fit,
    onFitMode: () {},
    onLock: () {},
    showEpisodeNavigation: showEpisodeNavigation,
    onPreviousEpisode: onPreviousEpisode,
    onNextEpisode: onNextEpisode,
  );
}

void main() {
  group('top bar', () {
    testWidgets('shows back, titles and every available action',
        (WidgetTester tester) async {
      bool backPressed = false;
      await _pump(
        tester,
        _topBar(
          onBack: () => backPressed = true,
          onEpisodes: () {},
          onGroups: () {},
          onSubtitles: () {},
          onQuality: () {},
          qualityLabel: '720p',
        ),
      );

      expect(find.text('Frieren'), findsOneWidget);
      expect(find.text('Episode 3'), findsOneWidget);
      expect(find.byIcon(Icons.format_list_numbered_rounded), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over_rounded), findsOneWidget);
      expect(find.byIcon(Icons.closed_caption_off_outlined), findsOneWidget);
      expect(find.text('720p'), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backPressed, isTrue);
    });

    testWidgets('hides actions that are unavailable',
        (WidgetTester tester) async {
      await _pump(tester, _topBar());

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.format_list_numbered_rounded), findsNothing);
      expect(find.byIcon(Icons.record_voice_over_rounded), findsNothing);
      expect(find.byIcon(Icons.closed_caption_off_outlined), findsNothing);
      expect(find.byIcon(Icons.high_quality_rounded), findsNothing);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('long quality labels fall back to the icon',
        (WidgetTester tester) async {
      await _pump(
        tester,
        _topBar(onQuality: () {}, qualityLabel: 'Auto (H.264)'),
      );

      expect(find.text('Auto (H.264)'), findsNothing);
      expect(find.byIcon(Icons.high_quality_rounded), findsOneWidget);
    });

    testWidgets('shows a non-default speed as text',
        (WidgetTester tester) async {
      await _pump(tester, _topBar(playbackSpeed: 1.5));

      expect(find.text('1.5×'), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsNothing);
    });

    testWidgets('the overflow sheet offers fit modes and the web player',
        (WidgetTester tester) async {
      PlayerFitMode? pickedMode;
      bool webPlayerOpened = false;
      await _pump(
        tester,
        Builder(
          builder: (BuildContext context) => _topBar(
            onMore: () => showPlayerMoreSheet(
              context,
              fitMode: PlayerFitMode.fit,
              onFitModeSelected: (PlayerFitMode mode) => pickedMode = mode,
              onOpenWebPlayer: () => webPlayerOpened = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Fit'), findsOneWidget);
      expect(find.text('Fill'), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(find.text('Open in web player'), findsOneWidget);

      await tester.tap(find.text('Fill'));
      await tester.pumpAndSettle();
      expect(pickedMode, PlayerFitMode.fill);

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open in web player'));
      await tester.pumpAndSettle();
      expect(webPlayerOpened, isTrue);
    });
  });

  group('bottom controls', () {
    testWidgets('centres play between previous and next',
        (WidgetTester tester) async {
      await _pump(
        tester,
        _bottomControls(onPreviousEpisode: () {}, onNextEpisode: () {}),
      );

      final Offset play = tester.getCenter(find.byIcon(Icons.play_arrow_rounded));
      final Offset previous =
          tester.getCenter(find.byIcon(Icons.skip_previous_rounded));
      final Offset next = tester.getCenter(find.byIcon(Icons.skip_next_rounded));
      expect(play.dx, moreOrLessEquals(_landscape.width / 2));
      expect(previous.dx, lessThan(play.dx));
      expect(next.dx, greaterThan(play.dx));
      expect(
        tester.getCenter(find.byIcon(Icons.lock_outline_rounded)).dx,
        lessThan(previous.dx),
      );
      expect(
        tester.getCenter(find.byIcon(Icons.fit_screen_rounded)).dx,
        greaterThan(next.dx),
      );
    });

    testWidgets('keeps play centred without a playlist',
        (WidgetTester tester) async {
      await _pump(tester, _bottomControls(showEpisodeNavigation: false));

      expect(find.byIcon(Icons.skip_previous_rounded), findsNothing);
      expect(find.byIcon(Icons.skip_next_rounded), findsNothing);
      expect(
        tester.getCenter(find.byIcon(Icons.play_arrow_rounded)).dx,
        moreOrLessEquals(_landscape.width / 2),
      );
    });

    testWidgets('disables previous on the first episode',
        (WidgetTester tester) async {
      await _pump(tester, _bottomControls(onNextEpisode: () {}));

      final IconButton previous = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.skip_previous_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(previous.onPressed, isNull);
      expect(
        tester.getCenter(find.byIcon(Icons.play_arrow_rounded)).dx,
        moreOrLessEquals(_landscape.width / 2),
      );
    });
  });
}
