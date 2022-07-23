import 'package:wakaranai/models/data/filters/filter_data.dart';

class FilterDataMultipleOfMultiple extends FilterData {
  final List<List<String>> selected;

  const FilterDataMultipleOfMultiple({
    required this.selected,
  });
}
