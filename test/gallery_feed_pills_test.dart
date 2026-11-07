import 'package:capyscript/modules/waka_models/models/config_info/gallery_feed/gallery_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_feed_pills.dart';
import 'package:wakaranai/utils/app_colors.dart';

const List<GalleryFeed> _feeds = <GalleryFeed>[
  GalleryFeed(id: 'popular', title: 'Popular'),
  GalleryFeed(id: 'latest', title: 'Latest'),
  GalleryFeed(id: 'top', title: 'Top rated'),
];

Widget _host(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

Material _pillSurface(WidgetTester tester, String title) {
  return tester.widget<Material>(
    find.ancestor(of: find.text(title), matching: find.byType(Material)).first,
  );
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  group('GalleryFeedPills', () {
    testWidgets('shows every feed and highlights the selected one',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(GalleryFeedPills(
        feeds: _feeds,
        selectedFeedId: 'latest',
        onSelected: (_) {},
      )));

      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
      expect(find.text('Top rated'), findsOneWidget);
      expect(_pillSurface(tester, 'Latest').color, AppColors.primary);
      expect(_pillSurface(tester, 'Popular').color, isNot(AppColors.primary));
    });

    testWidgets('reports the tapped feed id', (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(_host(GalleryFeedPills(
        feeds: _feeds,
        selectedFeedId: 'popular',
        onSelected: selected.add,
      )));

      await tester.tap(find.text('Top rated'));
      await tester.pump();

      expect(selected, <String>['top']);
    });

    testWidgets('scrolls horizontally when the feeds overflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(GalleryFeedPills(
        feeds: List<GalleryFeed>.generate(
          12,
          (int index) => GalleryFeed(id: 'f$index', title: 'Feed $index'),
        ),
        selectedFeedId: 'f0',
        onSelected: (_) {},
      )));

      final ListView list = tester.widget<ListView>(find.byType(ListView));
      expect(list.scrollDirection, Axis.horizontal);
      expect(tester.takeException(), isNull);
    });
  });
  group('GalleryFeedSegments', () {
    BoxDecoration segmentDecoration(WidgetTester tester, String title) {
      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text(title),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      return container.decoration! as BoxDecoration;
    }

    testWidgets('splits the width between feeds and highlights the selected one',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(GalleryFeedSegments(
        feeds: _feeds.take(2).toList(),
        selectedFeedId: 'popular',
        onSelected: (_) {},
      )));

      expect(find.byType(Expanded), findsNWidgets(2));
      expect(segmentDecoration(tester, 'Popular').color, AppColors.primary);
      expect(segmentDecoration(tester, 'Latest').color, Colors.transparent);
    });

    testWidgets('reports the tapped feed id', (WidgetTester tester) async {
      final List<String> selected = <String>[];
      await tester.pumpWidget(_host(GalleryFeedSegments(
        feeds: _feeds.take(2).toList(),
        selectedFeedId: 'popular',
        onSelected: selected.add,
      )));

      await tester.tap(find.text('Latest'));
      await tester.pump();

      expect(selected, <String>['latest']);
    });

    testWidgets('fits three feeds on a narrow screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GalleryFeedSegments(
          feeds: _feeds,
          selectedFeedId: 'top',
          onSelected: (_) {},
        ),
      )));

      expect(tester.takeException(), isNull);
      expect(find.text('Top rated'), findsOneWidget);
    });
  });
}
