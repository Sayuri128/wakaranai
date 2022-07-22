import 'package:wakaranai/models/data/filters/filter_data.dart';

class FilterDataOneOfMultiple extends FilterData {
  final String selected;

  const FilterDataOneOfMultiple({
    required this.selected,
  });
}
