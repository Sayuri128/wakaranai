part of 'chapter_viewer.dart';

mixin _ReaderStripNavigation on State<ChapterViewer> {
  static const int _prefetchRadius = 2;
  static const int _preloadNextWithin = 6;
  static const double _readingLine = 0.5;
  static const double _edgeTolerance = 0.01;

  ChapterViewCubit get _chapterViewCubit;

  PageController get _pageController;

  ItemScrollController get _itemScrollController;

  ItemPositionsListener get _itemPositionsListener;

  PageTranslationCubit? get _translationCubit;

  void _requestTranslations(ChapterViewInitialized state, int index);

  final Map<String, Size> _pageSizes = <String, Size>{};

  final Map<String, GlobalKey<TranslatedPageState>> _translatedPageKeys =
      <String, GlobalKey<TranslatedPageState>>{};

  GlobalKey<TranslatedPageState> _translatedPageKey(String path) {
    return _translatedPageKeys.putIfAbsent(
      path,
      GlobalKey<TranslatedPageState>.new,
    );
  }

  ReaderStrip? _strip;
  List<LoadedChapter>? _stripChapters;
  ChapterLoad? _stripNextLoad;
  ChapterLoad? _stripPreviousLoad;
  bool _restoringAnchor = false;

  ReaderStrip _stripFor(ChapterViewInitialized state) {
    final ReaderStrip? cached = _strip;
    if (cached != null &&
        identical(_stripChapters, state.chapters) &&
        _stripNextLoad == state.nextLoad &&
        _stripPreviousLoad == state.previousLoad) {
      return cached;
    }
    final ReaderStrip strip = ReaderStrip.build(
      chapters: state.chapters,
      order: state.group.elements,
      nextLoad: state.nextLoad,
      previousLoad: state.previousLoad,
    );
    _strip = strip;
    _stripChapters = state.chapters;
    _stripNextLoad = state.nextLoad;
    _stripPreviousLoad = state.previousLoad;
    return strip;
  }

  int _stripIndexOfCurrentPage(ChapterViewInitialized state, int page) {
    final ReaderStrip strip = _stripFor(state);
    final int pageIndex = (page - 1).clamp(0, max(0, state.totalPages - 1));
    return strip.indexOfPage(state.currentPages.chapterUid, pageIndex) ?? 0;
  }

  void _onWebtoonPositionsChanged() {
    final ChapterViewState state = _chapterViewCubit.state;
    if (_restoringAnchor ||
        state is! ChapterViewInitialized ||
        state.mode != ChapterViewMode.webtoon) {
      return;
    }
    final ReaderStrip strip = _stripFor(state);
    final Iterable<ItemPosition> positions =
        _itemPositionsListener.itemPositions.value;
    _maybeLoadNextChapter(state, strip, positions);

    final ReaderStripPage? page = _readingPage(strip, positions);
    if (page == null) {
      return;
    }
    final bool samePage =
        page.chapter.uid == state.currentPages.chapterUid &&
        page.pageIndex + 1 == state.currentPage;
    if (samePage) {
      return;
    }
    _chapterViewCubit.onStripPosition(page.chapter.uid, page.pageIndex + 1);
    final ChapterViewState updated = _chapterViewCubit.state;
    if (updated is ChapterViewInitialized) {
      _prefetchAround(updated, page.pageIndex);
    }
  }

  void _maybeLoadNextChapter(
    ChapterViewInitialized state,
    ReaderStrip strip,
    Iterable<ItemPosition> positions,
  ) {
    if (state.nextLoad != ChapterLoad.idle || strip.length == 0) {
      return;
    }
    final ReaderStripItem last = strip.items.last;
    if (last is! ReaderStripDivider || last.isEnd) {
      return;
    }
    final int threshold = strip.length - 1 - _preloadNextWithin;
    final bool nearEnd = positions.any(
      (ItemPosition position) => position.index >= threshold,
    );
    if (nearEnd) {
      _maybeLoadNextChapterNear(state, strip);
    }
  }

  void _maybeLoadNextChapterNear(
    ChapterViewInitialized state,
    ReaderStrip strip,
  ) {
    if (state.nextLoad != ChapterLoad.idle || strip.length == 0) {
      return;
    }
    final ReaderStripItem last = strip.items.last;
    if (last is! ReaderStripDivider || last.isEnd) {
      return;
    }
    unawaited(_chapterViewCubit.loadNextInStrip());
  }

  ReaderStripPage? _readingPage(
    ReaderStrip strip,
    Iterable<ItemPosition> positions,
  ) {
    ReaderStripPage? atReadingLine;
    ReaderStripPage? lastAbove;
    int lastAboveIndex = -1;
    ReaderStripPage? firstBelow;
    int firstBelowIndex = strip.length;
    for (final ItemPosition position in positions) {
      if (position.index >= strip.length ||
          position.itemTrailingEdge <= 0 ||
          position.itemLeadingEdge >= 1) {
        continue;
      }
      final ReaderStripItem item = strip.items[position.index];
      if (item is! ReaderStripPage) {
        continue;
      }
      if (position.itemLeadingEdge <= _readingLine &&
          position.itemTrailingEdge > _readingLine) {
        atReadingLine = item;
      } else if (position.itemTrailingEdge <= _readingLine + _edgeTolerance) {
        if (position.index > lastAboveIndex) {
          lastAboveIndex = position.index;
          lastAbove = item;
        }
      } else if (position.index < firstBelowIndex) {
        firstBelowIndex = position.index;
        firstBelow = item;
      }
    }
    return atReadingLine ?? lastAbove ?? firstBelow;
  }

  void _keepPagedPositionAfterPrepend(
    ChapterViewInitialized state,
    ReaderStrip oldStrip,
  ) {
    if (!_pageController.hasClients) {
      return;
    }
    final int oldIndex = (_pageController.page ?? 0).round();
    if (oldIndex < 0 || oldIndex >= oldStrip.length) {
      return;
    }
    final ReaderStrip strip = _stripFor(state);
    final ReaderStripItem anchor = oldStrip.items[oldIndex];
    final int? index = anchor is ReaderStripPrevious
        ? _lastPageIndexOf(state, strip, anchor.previous.uid)
        : strip.indexOfKey(anchor.key);
    if (index == null) {
      return;
    }
    _restoringAnchor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoringAnchor = false;
        _onPagedIndexChanged(index);
      });
    });
  }

  int? _lastPageIndexOf(
    ChapterViewInitialized state,
    ReaderStrip strip,
    String chapterUid,
  ) {
    final LoadedChapter? chapter = state.loadedChapter(chapterUid);
    if (chapter == null || chapter.pageCount == 0) {
      return null;
    }
    return strip.indexOfPage(chapterUid, chapter.pageCount - 1);
  }

  bool _chapterPrepended(ChapterViewState previous, ChapterViewState current) {
    return previous is ChapterViewInitialized &&
        current is ChapterViewInitialized &&
        current.chapters.length > previous.chapters.length &&
        current.chapters.first.uid != previous.chapters.first.uid;
  }

  ({String key, double leadingEdge})? _currentAnchor(ReaderStrip strip) {
    ItemPosition? anchor;
    for (final ItemPosition position
        in _itemPositionsListener.itemPositions.value) {
      if (position.index >= strip.length ||
          strip.items[position.index] is! ReaderStripPage) {
        continue;
      }
      if (anchor == null || position.index < anchor.index) {
        anchor = position;
      }
    }
    if (anchor == null) {
      return null;
    }
    return (
      key: strip.items[anchor.index].key,
      leadingEdge: anchor.itemLeadingEdge,
    );
  }

  void _keepPositionAfterPrepend(ChapterViewInitialized state) {
    final ReaderStrip? oldStrip = _strip;
    if (oldStrip == null) {
      return;
    }
    if (state.mode != ChapterViewMode.webtoon) {
      _keepPagedPositionAfterPrepend(state, oldStrip);
      return;
    }
    final ({String key, double leadingEdge})? anchor = _currentAnchor(oldStrip);
    if (anchor == null) {
      return;
    }
    final int? index = _stripFor(state).indexOfKey(anchor.key);
    if (index == null) {
      return;
    }
    _restoringAnchor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _itemScrollController.isAttached) {
        _itemScrollController.jumpTo(
          index: index,
          alignment: anchor.leadingEdge,
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoringAnchor = false;
      });
    });
  }

  double _webtoonCacheExtent(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 2;

  void _prefetchAround(ChapterViewInitialized state, int index) {
    final List<String> pages = state.currentPages.value;
    if (pages.isEmpty) {
      return;
    }

    final int start = max(0, index - _prefetchRadius);
    final int end = min(pages.length - 1, index + _prefetchRadius);
    prefetchPages(pages.sublist(start, end + 1), state.headers);
    _requestTranslations(state, index);
  }

  Widget _buildPageViewerPage(
    ChapterViewInitialized state,
    BuildContext context,
  ) {
    switch (state.mode) {
      case ChapterViewMode.rightToLeft:
      case ChapterViewMode.leftToRight:
        return _buildPagedStrip(state, context);
      case ChapterViewMode.webtoon:
        return _buildWebtoonStrip(state, context);
    }
  }

  Widget _buildPagedStrip(ChapterViewInitialized state, BuildContext context) {
    final ReaderStrip strip = _stripFor(state);
    return PhotoViewGallery.builder(
      allowImplicitScrolling: true,
      loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
        return Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              value: event != null && event.expectedTotalBytes != null
                  ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
                  : 0,
            ),
          ),
        );
      },
      pageController: _pageController,
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: strip.length,
      reverse: state.mode == ChapterViewMode.rightToLeft,
      onPageChanged: _onPagedIndexChanged,
      builder: (BuildContext context, int index) =>
          _buildPagedItem(context, strip.items[index]),
    );
  }

  void _onPagedIndexChanged(int index) {
    final ChapterViewState state = _chapterViewCubit.state;
    if (_restoringAnchor || state is! ChapterViewInitialized) {
      return;
    }
    final ReaderStrip strip = _stripFor(state);
    if (index < 0 || index >= strip.length) {
      return;
    }
    if (index >= strip.length - 1 - _preloadNextWithin) {
      _maybeLoadNextChapterNear(state, strip);
    }
    final ReaderStripItem item = strip.items[index];
    switch (item) {
      case ReaderStripPage():
        _chapterViewCubit.onStripPosition(item.chapter.uid, item.pageIndex + 1);
        final ChapterViewState updated = _chapterViewCubit.state;
        if (updated is ChapterViewInitialized) {
          _prefetchAround(updated, item.pageIndex);
        }
      case ReaderStripDivider():
        _chapterViewCubit.onStripPosition(
          item.finished.uid,
          item.finished.pageCount,
        );
      case ReaderStripPrevious():
        break;
    }
  }

  PhotoViewGalleryPageOptions _buildPagedItem(
    BuildContext context,
    ReaderStripItem item,
  ) {
    switch (item) {
      case ReaderStripPage():
        return _buildPagedPage(context, item);
      case ReaderStripDivider():
        return _buildPagedCard(
          context,
          ChapterDivider(
            divider: item,
            onRetry: () => unawaited(_chapterViewCubit.loadNextInStrip()),
            onBack: () => Navigator.of(context).pop(),
          ),
        );
      case ReaderStripPrevious():
        return _buildPagedCard(
          context,
          PreviousChapterCard(
            item: item,
            onLoad: () => unawaited(_chapterViewCubit.loadPreviousInStrip()),
          ),
        );
    }
  }

  PhotoViewGalleryPageOptions _buildPagedCard(
    BuildContext context,
    Widget card,
  ) {
    final Size screen = MediaQuery.sizeOf(context);
    return PhotoViewGalleryPageOptions.customChild(
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.contained,
      disableGestures: true,
      childSize: screen,
      child: SizedBox.fromSize(
        size: screen,
        child: Center(child: SingleChildScrollView(child: card)),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildPagedPage(
    BuildContext context,
    ReaderStripPage item,
  ) {
    final String page = item.path;
    return PhotoViewGalleryPageOptions.customChild(
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      basePosition: Alignment.center,
      // photo_view only applies zoom through its Transform when
      // filterQuality is none; otherwise it scales the Image widget
      // it builds, which a custom child never receives. PageImage
      // does its own filtering.
      filterQuality: FilterQuality.none,
      childSize: _pageSizes[page],
      child: TranslatedPage(
        key: _translatedPageKey(page),
        cubit: _translationCubit,
        path: page,
        child: PageImage(
          path: page,
          headers: item.chapter.headers,
          intrinsic: true,
          onSizeResolved: (Size size) {
            if (_pageSizes[page] != size && mounted) {
              setState(() => _pageSizes[page] = size);
            }
          },
          loadingBuilder: (BuildContext context) =>
              SizedBox.fromSize(size: MediaQuery.of(context).size),
          errorBuilder: (BuildContext context, VoidCallback retry) =>
              SizedBox.fromSize(
                size: MediaQuery.of(context).size,
                child: ReaderPageError(onRetry: retry),
              ),
        ),
      ),
    );
  }

  Widget _buildWebtoonStrip(
    ChapterViewInitialized state,
    BuildContext context,
  ) {
    final ReaderStrip strip = _stripFor(state);
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      initialScrollIndex: _stripIndexOfCurrentPage(state, state.currentPage),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: strip.length,
      minCacheExtent: _webtoonCacheExtent(context),
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) =>
          _buildStripItem(context, strip.items[index]),
    );
  }

  Widget _buildStripItem(BuildContext context, ReaderStripItem item) {
    switch (item) {
      case ReaderStripPage():
        return _buildWebtoonPage(context, item);
      case ReaderStripDivider():
        return ChapterDivider(
          divider: item,
          onRetry: () => unawaited(_chapterViewCubit.loadNextInStrip()),
          onBack: () => Navigator.of(context).pop(),
        );
      case ReaderStripPrevious():
        return PreviousChapterCard(
          item: item,
          onLoad: () => unawaited(_chapterViewCubit.loadPreviousInStrip()),
        );
    }
  }

  Widget _buildWebtoonPage(BuildContext context, ReaderStripPage item) {
    final String path = item.path;
    return TranslatedPage(
      key: _translatedPageKey(path),
      cubit: _translationCubit,
      path: path,
      child: PageImage(
        path: path,
        headers: item.chapter.headers,
        errorBuilder: (BuildContext context, VoidCallback retry) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ReaderPageError(onRetry: retry),
        ),
        loadingBuilder: (BuildContext context) => SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
