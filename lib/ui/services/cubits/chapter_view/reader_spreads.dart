import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';

class ReaderSpreads {
  ReaderSpreads._(this.spreads, this._spreadOfItem);

  factory ReaderSpreads.single(int itemCount) {
    return ReaderSpreads._(
      List<List<int>>.generate(itemCount, (int index) => <int>[index]),
      List<int>.generate(itemCount, (int index) => index),
    );
  }

  factory ReaderSpreads.pair(
    List<ReaderStripItem> items, {
    required bool Function(ReaderStripPage page) isWide,
  }) {
    final List<List<int>> spreads = <List<int>>[];
    final List<int> spreadOfItem = List<int>.filled(items.length, 0);
    int index = 0;
    while (index < items.length) {
      final int spread = spreads.length;
      if (_canPair(items, index, isWide)) {
        spreads.add(<int>[index, index + 1]);
        spreadOfItem[index] = spread;
        spreadOfItem[index + 1] = spread;
        index += 2;
        continue;
      }
      spreads.add(<int>[index]);
      spreadOfItem[index] = spread;
      index++;
    }
    return ReaderSpreads._(spreads, spreadOfItem);
  }

  final List<List<int>> spreads;
  final List<int> _spreadOfItem;

  int get length => spreads.length;

  int spreadOfItem(int itemIndex) {
    if (_spreadOfItem.isEmpty) {
      return 0;
    }
    return _spreadOfItem[itemIndex.clamp(0, _spreadOfItem.length - 1)];
  }

  int firstItemOf(int spreadIndex) {
    return spreads[spreadIndex.clamp(0, spreads.length - 1)].first;
  }

  int lastItemOf(int spreadIndex) {
    return spreads[spreadIndex.clamp(0, spreads.length - 1)].last;
  }

  static bool _canPair(
    List<ReaderStripItem> items,
    int index,
    bool Function(ReaderStripPage page) isWide,
  ) {
    if (index + 1 >= items.length) {
      return false;
    }
    final ReaderStripItem first = items[index];
    final ReaderStripItem second = items[index + 1];
    if (first is! ReaderStripPage || second is! ReaderStripPage) {
      return false;
    }
    if (first.pageIndex == 0 || first.chapter.uid != second.chapter.uid) {
      return false;
    }
    return !isWide(first) && !isWide(second);
  }
}
