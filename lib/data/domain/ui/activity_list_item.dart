import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';

class ActivityListItem<T> {
  final DateTime day;
  final List<DayActivityListItem<T>> listItems;

  const ActivityListItem({
    required this.day,
    required this.listItems,
  });
}

class DayActivityListItem<T> {
  final ConcreteDataDomain data;
  final T activity;

  const DayActivityListItem({
    required this.data,
    required this.activity,
  });


}
