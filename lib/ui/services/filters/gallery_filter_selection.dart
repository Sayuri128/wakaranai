import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_any/multiple_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_any/one_of_any.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/gallery_filter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/range/range.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/switcher/swircher.dart';

class GalleryFilterOption {
  const GalleryFilterOption({
    required this.group,
    required this.index,
    required this.value,
    required this.label,
  });

  final int group;
  final int index;
  final String value;
  final String label;
}

class GalleryFilterSelection {
  GalleryFilterSelection({
    required this.filters,
    Map<String, FilterData> current = const <String, FilterData>{},
  }) {
    _seed(current);
  }

  final List<GalleryFilter> filters;

  final Map<String, bool> _switches = <String, bool>{};
  final Map<String, String> _singles = <String, String>{};
  final Map<String, String> _texts = <String, String>{};
  final Map<String, List<String>> _multis = <String, List<String>>{};
  final Map<String, List<List<String>>> _groupMultis =
      <String, List<List<String>>>{};
  final Map<String, String> _rangeFrom = <String, String>{};
  final Map<String, String> _rangeTo = <String, String>{};

  void _seed(Map<String, FilterData> current) {
    for (final GalleryFilter filter in filters) {
      final FilterData? data = current[filter.param];
      if (data is FilterDataSwitcher) {
        _switches[filter.param] = data.on;
      } else if (data is FilterDataOneOfMultiple) {
        _singles[filter.param] = data.selected;
      } else if (data is FilterDataOneOfAny) {
        _texts[filter.param] = data.selected;
      } else if (data is FilterDataMultipleOfAny) {
        _multis[filter.param] = List<String>.of(data.selected);
      } else if (data is FilterDataMultipleOfMultiple) {
        _groupMultis[filter.param] = data.selected
            .map((List<String> group) => List<String>.of(group))
            .toList();
      } else if (data is FilterDataRange) {
        _rangeFrom[filter.param] = data.from ?? '';
        _rangeTo[filter.param] = data.to ?? '';
      }
    }
  }

  bool switchValue(GalleryFilter filter) => _switches[filter.param] ?? false;

  void setSwitch(GalleryFilter filter, bool value) {
    _switches[filter.param] = value;
  }

  String? singleValue(GalleryFilter filter) => _singles[filter.param];

  void toggleSingle(GalleryFilter filter, String value) {
    if (_singles[filter.param] == value) {
      _singles.remove(filter.param);
      return;
    }
    _singles[filter.param] = value;
  }

  void clearSingle(GalleryFilter filter) {
    _singles.remove(filter.param);
  }

  bool isOptionSelected(GalleryFilter filter, GalleryFilterOption option) {
    if (filter is GalleryFilterOneOfMultiple) {
      return _singles[filter.param] == option.value;
    }
    final List<List<String>>? groups = _groupMultis[filter.param];
    if (groups == null || option.group >= groups.length) {
      return false;
    }
    return groups[option.group].contains(option.value);
  }

  void toggleOption(GalleryFilter filter, GalleryFilterOption option) {
    if (filter is GalleryFilterOneOfMultiple) {
      toggleSingle(filter, option.value);
      return;
    }
    if (filter is! GalleryFilterMultipleOfMultiple) {
      return;
    }
    final List<List<String>> groups = _groupsFor(filter, option.group + 1);
    final List<String> group = groups[option.group];
    if (group.contains(option.value)) {
      group.remove(option.value);
    } else {
      group.add(option.value);
    }
  }

  List<List<String>> _groupsFor(
    GalleryFilterMultipleOfMultiple filter,
    int minimumLength,
  ) {
    final List<List<String>> groups =
        _groupMultis.putIfAbsent(filter.param, () => <List<String>>[]);
    final int targetLength = filter.values.length > minimumLength
        ? filter.values.length
        : minimumLength;
    while (groups.length < targetLength) {
      groups.add(<String>[]);
    }
    return groups;
  }

  String textValue(GalleryFilter filter) => _texts[filter.param] ?? '';

  void setText(GalleryFilter filter, String value) {
    _texts[filter.param] = value;
  }

  List<String> multiValues(GalleryFilter filter) =>
      List<String>.unmodifiable(_multis[filter.param] ?? const <String>[]);

  bool addMultiValue(GalleryFilter filter, String rawValue) {
    final String value = rawValue.trim();
    if (value.isEmpty) {
      return false;
    }
    final List<String> values =
        _multis.putIfAbsent(filter.param, () => <String>[]);
    if (values.contains(value)) {
      return false;
    }
    values.add(value);
    return true;
  }

  void removeMultiValue(GalleryFilter filter, String value) {
    _multis[filter.param]?.remove(value);
  }

  String rangeFrom(GalleryFilter filter) => _rangeFrom[filter.param] ?? '';

  String rangeTo(GalleryFilter filter) => _rangeTo[filter.param] ?? '';

  void setRangeFrom(GalleryFilter filter, String value) {
    _rangeFrom[filter.param] = value;
  }

  void setRangeTo(GalleryFilter filter, String value) {
    _rangeTo[filter.param] = value;
  }

  int selectedCount(GalleryFilter filter) {
    if (filter is GalleryFilterOneOfMultiple) {
      final String? selected = _singles[filter.param];
      if (selected == null || selected.isEmpty) {
        return 0;
      }
      return 1;
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      final List<List<String>>? groups = _groupMultis[filter.param];
      if (groups == null) {
        return 0;
      }
      return groups.fold<int>(
        0,
        (int total, List<String> group) => total + group.length,
      );
    }
    if (filter.type == GalleryFilterType.MULTIPLE_OF_ANY &&
        filter is! GalleryFilterSwitcher &&
        filter is! GalleryFilterRange) {
      return _multis[filter.param]?.length ?? 0;
    }
    if (dataFor(filter) != null) {
      return 1;
    }
    return 0;
  }

  bool isActive(GalleryFilter filter) => dataFor(filter) != null;

  int get activeCount {
    int count = 0;
    for (final GalleryFilter filter in filters) {
      if (isActive(filter)) {
        count++;
      }
    }
    return count;
  }

  void clearFilter(GalleryFilter filter) {
    final String param = filter.param;
    _switches.remove(param);
    _singles.remove(param);
    _texts.remove(param);
    _multis.remove(param);
    _groupMultis.remove(param);
    _rangeFrom.remove(param);
    _rangeTo.remove(param);
  }

  void clearAll() {
    _switches.clear();
    _singles.clear();
    _texts.clear();
    _multis.clear();
    _groupMultis.clear();
    _rangeFrom.clear();
    _rangeTo.clear();
  }

  FilterData? dataFor(GalleryFilter filter) {
    if (filter is GalleryFilterSwitcher) {
      return _switcherData(filter);
    }
    if (filter is GalleryFilterOneOfMultiple) {
      return _oneOfMultipleData(filter);
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      return _multipleOfMultipleData(filter);
    }
    if (filter is GalleryFilterRange) {
      return _rangeData(filter);
    }
    switch (filter.type) {
      case GalleryFilterType.ONE_OF_ANY:
        return _oneOfAnyData(filter);
      case GalleryFilterType.MULTIPLE_OF_ANY:
        return _multipleOfAnyData(filter);
      default:
        return null;
    }
  }

  FilterData? _switcherData(GalleryFilterSwitcher filter) {
    if (!(_switches[filter.param] ?? false)) {
      return null;
    }
    return FilterDataSwitcher(on: true, filter: filter);
  }

  FilterData? _oneOfMultipleData(GalleryFilterOneOfMultiple filter) {
    final String? selected = _singles[filter.param];
    if (selected == null || selected.isEmpty) {
      return null;
    }
    return FilterDataOneOfMultiple(selected: selected, filter: filter);
  }

  FilterData? _multipleOfMultipleData(GalleryFilterMultipleOfMultiple filter) {
    final List<List<String>>? selected = _groupMultis[filter.param];
    if (selected == null || selected.every((List<String> g) => g.isEmpty)) {
      return null;
    }
    return FilterDataMultipleOfMultiple(
      selected: selected.map((List<String> g) => List<String>.of(g)).toList(),
      filter: filter,
    );
  }

  FilterData? _rangeData(GalleryFilterRange filter) {
    final String from = rangeFrom(filter).trim();
    final String to = rangeTo(filter).trim();
    if (from.isEmpty && to.isEmpty) {
      return null;
    }
    return FilterDataRange(
      from: from.isEmpty ? null : from,
      to: to.isEmpty ? null : to,
      filter: filter,
    );
  }

  FilterData? _oneOfAnyData(GalleryFilter filter) {
    final String value = textValue(filter).trim();
    if (value.isEmpty) {
      return null;
    }
    return FilterDataOneOfAny(selected: value, filter: filter);
  }

  FilterData? _multipleOfAnyData(GalleryFilter filter) {
    final List<String> values = _multis[filter.param] ?? <String>[];
    if (values.isEmpty) {
      return null;
    }
    return FilterDataMultipleOfAny(
      selected: List<String>.of(values),
      filter: filter,
    );
  }

  Map<String, FilterData> build() {
    final Map<String, FilterData> result = <String, FilterData>{};
    for (final GalleryFilter filter in filters) {
      final FilterData? data = dataFor(filter);
      if (data != null) {
        result[filter.param] = data;
      }
    }
    return result;
  }

  static List<GalleryFilterOption> optionsOf(GalleryFilter filter) {
    if (filter is GalleryFilterOneOfMultiple) {
      return List<GalleryFilterOption>.generate(filter.values.length,
          (int index) {
        return GalleryFilterOption(
          group: 0,
          index: index,
          value: filter.values[index],
          label: _labelAt(filter.labels, index, filter.values[index]),
        );
      });
    }
    if (filter is GalleryFilterMultipleOfMultiple) {
      return _groupedOptions(filter);
    }
    return const <GalleryFilterOption>[];
  }

  static List<GalleryFilterOption> _groupedOptions(
    GalleryFilterMultipleOfMultiple filter,
  ) {
    final List<GalleryFilterOption> options = <GalleryFilterOption>[];
    int position = 0;
    for (int group = 0; group < filter.values.length; group++) {
      final List<String> values = filter.values[group];
      for (int index = 0; index < values.length; index++) {
        options.add(GalleryFilterOption(
          group: group,
          index: position,
          value: values[index],
          label: _groupLabelAt(filter.labels, group, index, values[index]),
        ));
        position++;
      }
    }
    return options;
  }

  static String _labelAt(List<String>? labels, int index, String fallback) {
    if (labels != null && index < labels.length) {
      return labels[index];
    }
    return fallback;
  }

  static String _groupLabelAt(
    List<List<String>>? labels,
    int group,
    int index,
    String fallback,
  ) {
    if (labels != null &&
        group < labels.length &&
        index < labels[group].length) {
      return labels[group][index];
    }
    return fallback;
  }
}
