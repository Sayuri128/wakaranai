import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translated_page.dart';

const Size _pageSize = Size(1100, 1600);

TranslatedBubble _bubble(String source, Rect layoutBox) {
  return TranslatedBubble(
    textBox: layoutBox.deflate(10),
    layoutBox: layoutBox,
    fillColor: 0xFFFFFFFF,
    erase: true,
    source: source,
    translation: '$source translated',
  );
}

const Rect _corner = Rect.fromLTRB(820, 1020, 1030, 1180);
const Rect _big = Rect.fromLTRB(60, 60, 700, 900);
const Rect _small = Rect.fromLTRB(300, 400, 380, 460);

final PageTranslationResult _page = PageTranslationResult(
  width: _pageSize.width.toInt(),
  height: _pageSize.height.toInt(),
  bubbles: <TranslatedBubble>[
    _bubble('CORNER', _corner),
    _bubble('BIG', _big),
    _bubble('SMALL', _small),
  ],
);

class _Backend implements PageTranslationBackend {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<PageTranslationResult?> cached(String path) async => _page;

  @override
  Future<PageTranslationResult?> olderVersion(String path) async => null;

  @override
  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  ) async => _page;

  @override
  Future<String> translateText(String text) async => text;

  @override
  Future<void> save(String path, PageTranslationResult result) async {}

  @override
  Future<void> dispose() async {}
}

class _ReaderHarness {
  final GlobalKey<TranslatedPageState> pageKey =
      GlobalKey<TranslatedPageState>();
  late final PageTranslationCubit cubit;
  int readerTaps = 0;

  Future<void> setUp(WidgetTester tester) async {
    cubit = PageTranslationCubit(
      languages: const TitleLanguages(
        source: PageLanguage.english,
        target: PageLanguage('uk', 'Ukrainian'),
      ),
      backendFactory: (TitleLanguages languages) => _Backend(),
      ensurePacks: (TitleLanguages languages) async => true,
    );
    await cubit.toggle();
    cubit.request(<String>['page'], const <String, String>{});
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }

  Widget translatedPage() {
    return TranslatedPage(
      key: pageKey,
      cubit: cubit,
      path: 'page',
      child: SizedBox.fromSize(size: _pageSize),
    );
  }

  Widget reader(Widget pages) {
    return MaterialApp(
      home: BlocProvider<PageTranslationSettingsCubit>(
        create: (BuildContext context) => PageTranslationSettingsCubit(),
        child: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (TapUpDetails details) {
              final bool opened =
                  pageKey.currentState?.openBubbleAt(details.globalPosition) ??
                  false;
              if (!opened) {
                readerTaps++;
              }
            },
            child: pages,
          ),
        ),
      ),
    );
  }

  Offset onScreen(WidgetTester tester, Offset pagePoint) {
    final Rect page = tester.getRect(find.byType(TranslatedPage));
    final double scale = page.width / _pageSize.width;
    return page.topLeft + pagePoint * scale;
  }
}

Future<void> _tap(WidgetTester tester, Offset position) async {
  await tester.tapAt(position);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => S.load(const Locale('en')));

  testWidgets('bubbles anywhere on a page shrunk by the zoom viewer open', (
    WidgetTester tester,
  ) async {
    final _ReaderHarness harness = _ReaderHarness();
    await harness.setUp(tester);
    addTearDown(harness.cubit.close);

    await tester.pumpWidget(
      harness.reader(
        PhotoViewGallery.builder(
          itemCount: 1,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions.customChild(
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              filterQuality: FilterQuality.none,
              childSize: _pageSize,
              child: harness.translatedPage(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tap(tester, harness.onScreen(tester, _corner.center));

    expect(find.text('CORNER'), findsOneWidget);
    expect(harness.readerTaps, 0);
  });

  testWidgets('bubbles open in the webtoon reader', (
    WidgetTester tester,
  ) async {
    final _ReaderHarness harness = _ReaderHarness();
    await harness.setUp(tester);
    addTearDown(harness.cubit.close);

    await tester.pumpWidget(
      harness.reader(
        ScrollablePositionedList.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) =>
              FittedBox(child: harness.translatedPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tap(
      tester,
      harness.onScreen(tester, _big.topLeft + const Offset(40, 40)),
    );

    expect(find.text('BIG'), findsOneWidget);
    expect(harness.readerTaps, 0);
  });

  testWidgets('a small bubble inside a big one wins, edges count', (
    WidgetTester tester,
  ) async {
    final _ReaderHarness harness = _ReaderHarness();
    await harness.setUp(tester);
    addTearDown(harness.cubit.close);

    await tester.pumpWidget(
      harness.reader(FittedBox(child: harness.translatedPage())),
    );
    await tester.pumpAndSettle();

    await _tap(
      tester,
      harness.onScreen(tester, _small.centerRight + const Offset(4, 0)),
    );

    expect(find.text('SMALL'), findsOneWidget);
    expect(find.text('BIG'), findsNothing);
  });

  testWidgets('taps away from bubbles still reach the reader', (
    WidgetTester tester,
  ) async {
    final _ReaderHarness harness = _ReaderHarness();
    await harness.setUp(tester);
    addTearDown(harness.cubit.close);

    await tester.pumpWidget(
      harness.reader(FittedBox(child: harness.translatedPage())),
    );
    await tester.pumpAndSettle();

    await _tap(tester, harness.onScreen(tester, const Offset(900, 300)));

    expect(harness.readerTaps, 1);
    expect(find.textContaining('translated'), findsNothing);
  });
}
