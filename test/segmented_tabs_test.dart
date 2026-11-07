import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/widgets/segmented_tabs.dart';
import 'package:wakaranai/utils/app_colors.dart';

const List<String> _sixFeeds = <String>[
  'Popular today',
  'Latest updates',
  'Top rated of all time',
  'Recently added',
  'Completed series',
  'Random picks',
];

Widget _host(Widget child, {double width = 360}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

Finder _indicator() {
  return find.byWidgetPredicate((Widget widget) {
    if (widget is! DecoratedBox) {
      return false;
    }
    final Decoration decoration = widget.decoration;
    return decoration is BoxDecoration && decoration.color == AppColors.primary;
  });
}

Finder _segment(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(GestureDetector),
  );
}

Rect _trackViewport(WidgetTester tester) {
  return tester.getRect(find.byType(SingleChildScrollView));
}

class _TabsHarness extends StatefulWidget {
  const _TabsHarness({required this.labels, this.initialIndex = 0});

  final List<String> labels;
  final int initialIndex;

  @override
  State<_TabsHarness> createState() => _TabsHarnessState();
}

class _TabsHarnessState extends State<_TabsHarness> {
  late int selected = widget.initialIndex;

  void select(int index) {
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedTabs(
      labels: widget.labels,
      selectedIndex: selected,
      onSelected: select,
    );
  }
}

class _PagedHarness extends StatefulWidget {
  const _PagedHarness();

  @override
  State<_PagedHarness> createState() => _PagedHarnessState();
}

class _PagedHarnessState extends State<_PagedHarness> {
  final PageController controller = PageController();
  int selected = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SegmentedTabs(
          labels: const <String>['First', 'Second'],
          selectedIndex: selected,
          pageController: controller,
          onSelected: (int index) => controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        ),
        Expanded(
          child: PageView(
            controller: controller,
            onPageChanged: (int index) => setState(() => selected = index),
            children: const <Widget>[
              Center(child: Text('page one')),
              Center(child: Text('page two')),
            ],
          ),
        ),
      ],
    );
  }
}

void main() {
  group('equal-width mode', () {
    testWidgets('splits two tabs evenly and slides the indicator on change',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(
        labels: <String>['Manga', 'Anime'],
      )));

      expect(find.byType(SingleChildScrollView), findsNothing);
      final Rect first = tester.getRect(_segment('Manga'));
      final Rect second = tester.getRect(_segment('Anime'));
      expect(first.width, moreOrLessEquals(second.width));
      expect(tester.getRect(_indicator()).left, moreOrLessEquals(first.left));
      expect(tester.getRect(_indicator()).width, moreOrLessEquals(first.width));

      await tester.tap(find.text('Anime'));
      await tester.pumpAndSettle();

      expect(tester.getRect(_indicator()).left, moreOrLessEquals(second.left));
    });

    testWidgets('keeps three tabs equal width', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(
        labels: <String>['A', 'Much longer label', 'C'],
      )));

      final double width = tester.getRect(_segment('A')).width;
      expect(tester.getRect(_segment('Much longer label')).width,
          moreOrLessEquals(width));
      expect(tester.getRect(_segment('C')).width, moreOrLessEquals(width));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows badges only for positive counts',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(SegmentedTabs(
        labels: const <String>['Titles', 'Downloads'],
        badges: const <int>[0, 3],
        selectedIndex: 0,
        onSelected: (int index) {},
      )));

      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      expect(
        find.descendant(of: _segment('Downloads'), matching: find.text('3')),
        findsOneWidget,
      );
    });
  });

  group('scrollable mode', () {
    testWidgets('fits six tabs into 360 px without overflowing',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(labels: _sixFeeds)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getSize(find.byType(SegmentedTabs)).width, 360);
      expect(tester.getSize(find.byType(SegmentedTabs)).height,
          SegmentedTabs.height);
      final double shortWidth = tester.getRect(_segment('Random picks')).width;
      final double longWidth =
          tester.getRect(_segment('Top rated of all time')).width;
      expect(longWidth, greaterThan(shortWidth));
    });

    testWidgets('scrolls the selected tab into view',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(labels: _sixFeeds)));
      await tester.pumpAndSettle();
      final Rect viewport = _trackViewport(tester);
      expect(
        tester.getRect(_segment('Random picks')).left,
        greaterThan(viewport.right),
      );

      tester.state<_TabsHarnessState>(find.byType(_TabsHarness)).select(5);
      await tester.pumpAndSettle();

      final Rect selected = tester.getRect(_segment('Random picks'));
      expect(selected.left, greaterThanOrEqualTo(viewport.left));
      expect(selected.right, lessThanOrEqualTo(viewport.right));
      expect(tester.getRect(_indicator()).left, moreOrLessEquals(selected.left));
      expect(tester.getRect(_indicator()).width, moreOrLessEquals(selected.width));
    });

    testWidgets('opens with a selected tab past the edge already visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(
        labels: _sixFeeds,
        initialIndex: 4,
      )));
      await tester.pumpAndSettle();

      final Rect viewport = _trackViewport(tester);
      final Rect selected = tester.getRect(_segment('Completed series'));
      expect(selected.left, greaterThanOrEqualTo(viewport.left));
      expect(selected.right, lessThanOrEqualTo(viewport.right));
    });

    testWidgets('stretches short labels to fill the track',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const _TabsHarness(
        labels: <String>['A', 'B', 'C', 'D'],
      )));
      await tester.pumpAndSettle();

      final Rect viewport = _trackViewport(tester);
      expect(tester.getRect(_segment('D')).right,
          moreOrLessEquals(viewport.right));
    });
  });

  testWidgets('the indicator follows a page swipe', (WidgetTester tester) async {
    await tester.pumpWidget(_host(const _PagedHarness(), width: 400));
    final Rect first = tester.getRect(_segment('First'));
    final Rect second = tester.getRect(_segment('Second'));

    final TestGesture gesture =
        await tester.startGesture(tester.getCenter(find.text('page one')));
    await gesture.moveBy(const Offset(-100, 0));
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();

    final double midSwipe = tester.getRect(_indicator()).left;
    expect(midSwipe, greaterThan(first.left));
    expect(midSwipe, lessThan(second.left));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(_indicator()).left, moreOrLessEquals(second.left));

    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();
    expect(find.text('page one'), findsOneWidget);
    expect(tester.getRect(_indicator()).left, moreOrLessEquals(first.left));
  });
}
