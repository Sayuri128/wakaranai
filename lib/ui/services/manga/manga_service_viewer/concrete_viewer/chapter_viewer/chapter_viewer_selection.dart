part of 'chapter_viewer.dart';

mixin _ReaderRegionSelection on State<ChapterViewer> {
  static const double _minSelectionSide = 24;

  Map<String, GlobalKey<TranslatedPageState>> get _translatedPageKeys;

  final GlobalKey _readerStackKey = GlobalKey();
  Offset? _selectionStart;
  Rect? _selection;
  TranslatedPageState? _selectionPage;

  TranslatedPageState? _pageForRegionAt(Offset globalPosition) {
    for (final GlobalKey<TranslatedPageState> key
        in _translatedPageKeys.values) {
      final TranslatedPageState? page = key.currentState;
      if (page != null && page.canSelectRegionAt(globalPosition)) {
        return page;
      }
    }
    return null;
  }

  bool _startSelection(Offset globalPosition) {
    final TranslatedPageState? page = _pageForRegionAt(globalPosition);
    if (page == null) {
      return false;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectionPage = page;
      _selectionStart = globalPosition;
      _selection = Rect.fromPoints(globalPosition, globalPosition);
    });
    return true;
  }

  void _updateSelection(Offset globalPosition) {
    final Offset? start = _selectionStart;
    if (start == null) {
      return;
    }
    setState(() => _selection = Rect.fromPoints(start, globalPosition));
  }

  Future<bool> _finishSelection() async {
    final Rect? selection = _selection;
    final TranslatedPageState? page = _selectionPage;
    setState(() {
      _selectionStart = null;
      _selection = null;
      _selectionPage = null;
    });
    if (selection == null ||
        page == null ||
        !page.mounted ||
        selection.shortestSide < _minSelectionSide) {
      return false;
    }
    final bool translated = await page.translateScreenRegion(selection);
    if (!translated && mounted) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.page_translation_region_empty,
      );
    }
    return true;
  }

  Widget _buildSelectionOverlay() {
    final Rect? selection = _selection;
    final RenderObject? stack = _readerStackKey.currentContext
        ?.findRenderObject();
    if (selection == null || stack is! RenderBox) {
      return const SizedBox.shrink();
    }
    final Rect local = Rect.fromPoints(
      stack.globalToLocal(selection.topLeft),
      stack.globalToLocal(selection.bottomRight),
    );
    return Positioned.fromRect(
      rect: local,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  bool _openBubbleAt(Offset globalPosition, {bool longPress = false}) {
    for (final GlobalKey<TranslatedPageState> key
        in _translatedPageKeys.values) {
      final TranslatedPageState? page = key.currentState;
      if (page != null &&
          page.openBubbleAt(globalPosition, longPress: longPress)) {
        return true;
      }
    }
    return false;
  }
}
