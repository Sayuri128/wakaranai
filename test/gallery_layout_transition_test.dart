import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout_transition.dart';
import 'package:wakaranai/ui/home/library_page/library_grid_geometry.dart';

const double _width = 411;
const double _height = 800;

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final ScrollController controller = ScrollController();
  GalleryLayout layout = GalleryLayout.comfortable;
  final List<GalleryMorph?> morphs = <GalleryMorph?>[];

  void show(GalleryLayout next) => setState(() => layout = next);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GalleryLayoutTransition(
          layout: layout,
          geometry: const ServiceGalleryGeometry(),
          position: () => controller.hasClients ? controller.position : null,
          builder:
              (BuildContext context, GalleryLayout shown, GalleryMorph? morph) {
                morphs.add(morph);
                if (shown == GalleryLayout.list) {
                  return ListView.builder(
                    controller: controller,
                    padding: kGalleryGridPadding,
                    itemCount: 60,
                    itemBuilder: (BuildContext context, int index) => SizedBox(
                      height: kGalleryListRowHeight,
                      child: Text('list $index'),
                    ),
                  );
                }
                return GridView.builder(
                  controller: controller,
                  padding: kGalleryGridPadding,
                  gridDelegate: galleryGridDelegateFor(shown),
                  itemCount: 60,
                  itemBuilder: (BuildContext context, int index) =>
                      GalleryMorphCell(
                        morph: morph,
                        index: index,
                        child: Text('${shown.name} $index'),
                      ),
                );
              },
        ),
      ),
    );
  }
}

Future<void> _pumpGrid(
  WidgetTester tester,
  SliverGridDelegate delegate,
  EdgeInsets padding,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _width,
          height: _height,
          child: GridView.builder(
            padding: padding,
            gridDelegate: delegate,
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) =>
                SizedBox.expand(key: ValueKey<int>(index)),
          ),
        ),
      ),
    ),
  );
}

void _expectCellsMatch(
  WidgetTester tester,
  GalleryGeometry geometry,
  GalleryLayout layout,
) {
  for (final int index in <int>[0, 1, 2, 3, 4, 5]) {
    final Rect actual = tester.getRect(find.byKey(ValueKey<int>(index)));
    final Rect predicted = geometry.cellRect(layout, _width, index);
    expect(actual.left, closeTo(predicted.left, 0.01), reason: 'left $index');
    expect(actual.top, closeTo(predicted.top, 0.01), reason: 'top $index');
    expect(actual.width, closeTo(predicted.width, 0.01));
    expect(actual.height, closeTo(predicted.height, 0.01));
  }
}

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      _width * 3,
      _height * 3,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('moves grid cells to their new columns instead of fading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _Host());
    final _HostState host = tester.state<_HostState>(find.byType(_Host));

    host.show(GalleryLayout.compact);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('compact 0'), findsOneWidget);
    expect(host.morphs.last, isNotNull);
    final FadeTransition fade = tester.widget(
      find.byType(FadeTransition).first,
    );
    expect(fade.opacity.value, 1);

    await tester.pumpAndSettle();
    expect(host.morphs.last, isNull);
  });

  testWidgets('a moving cell starts where it was in the old grid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _Host());
    final _HostState host = tester.state<_HostState>(find.byType(_Host));
    final Offset before = tester.getTopLeft(find.text('comfortable 3'));

    host.show(GalleryLayout.compact);
    await tester.pump();
    await tester.pump();

    final Offset start = tester.getTopLeft(find.text('compact 3'));
    expect(start.dx, closeTo(before.dx, 1));
    expect(start.dy, closeTo(before.dy, 1));

    await tester.pumpAndSettle();
    final Offset end = tester.getTopLeft(find.text('compact 3'));
    expect(end, isNot(equals(before)));
  });

  testWidgets('fades through when switching to the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _Host());
    final _HostState host = tester.state<_HostState>(find.byType(_Host));

    host.show(GalleryLayout.list);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('comfortable 0'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('list 0'), findsOneWidget);
    expect(host.morphs.whereType<GalleryMorph>(), isEmpty);
  });

  testWidgets('catches up when the layout changes again mid-transition', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _Host());
    final _HostState host = tester.state<_HostState>(find.byType(_Host));

    host.show(GalleryLayout.compact);
    await tester.pump(const Duration(milliseconds: 30));
    host.show(GalleryLayout.list);
    await tester.pumpAndSettle();

    expect(find.text('list 0'), findsOneWidget);
  });

  group('geometry matches the real grid layout', () {
    testWidgets('service comfortable and compact grids', (
      WidgetTester tester,
    ) async {
      const ServiceGalleryGeometry geometry = ServiceGalleryGeometry();
      for (final GalleryLayout layout in <GalleryLayout>[
        GalleryLayout.comfortable,
        GalleryLayout.compact,
      ]) {
        await _pumpGrid(
          tester,
          galleryGridDelegateFor(layout),
          kGalleryGridPadding,
        );
        _expectCellsMatch(tester, geometry, layout);
      }
    });

    testWidgets('library comfortable and compact grids', (
      WidgetTester tester,
    ) async {
      const LibraryGridGeometry geometry = LibraryGridGeometry();
      for (final GalleryLayout layout in <GalleryLayout>[
        GalleryLayout.comfortable,
        GalleryLayout.compact,
      ]) {
        await _pumpGrid(
          tester,
          LibraryGridGeometry.delegate(layout, _width),
          const EdgeInsets.fromLTRB(
            LibraryGridGeometry.horizontalPadding,
            LibraryGridGeometry.top,
            LibraryGridGeometry.horizontalPadding,
            24,
          ),
        );
        _expectCellsMatch(tester, geometry, layout);
      }
    });
  });

  group('carryScrollOffset', () {
    const ServiceGalleryGeometry service = ServiceGalleryGeometry();

    test('keeps the top of the page at the top', () {
      expect(
        carryScrollOffset(
          service,
          from: GalleryLayout.comfortable,
          to: GalleryLayout.list,
          width: _width,
          offset: 0,
        ),
        0,
      );
    });

    test('round trips through the list back to the same grid row', () {
      final double stride = service.rowStride(
        GalleryLayout.comfortable,
        _width,
      );
      final double offset = service.topPadding + stride * 7;
      final double there = carryScrollOffset(
        service,
        from: GalleryLayout.comfortable,
        to: GalleryLayout.list,
        width: _width,
        offset: offset,
      );
      final double back = carryScrollOffset(
        service,
        from: GalleryLayout.list,
        to: GalleryLayout.comfortable,
        width: _width,
        offset: there,
      );
      expect(back, closeTo(offset, 0.001));
    });

    test('compact grids fit more columns than comfortable ones', () {
      expect(
        service.columns(GalleryLayout.compact, _width),
        greaterThan(service.columns(GalleryLayout.comfortable, _width)),
      );
      const LibraryGridGeometry library = LibraryGridGeometry();
      expect(
        library.columns(GalleryLayout.compact, _width),
        greaterThan(library.columns(GalleryLayout.comfortable, _width)),
      );
    });
  });
}
