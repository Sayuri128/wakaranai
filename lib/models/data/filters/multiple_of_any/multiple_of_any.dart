import 'package:wakaranai/models/data/filters/filter_data.dart';

class FilterDataMultipleOfAny extends FilterData {
  final List<String> selected;

  const FilterDataMultipleOfAny({
    required this.selected,
  });
}
