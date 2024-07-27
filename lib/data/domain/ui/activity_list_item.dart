import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';

class ActivityListItem<T extends BaseActivityDomain> {
  final DateTime day;
  final List<DayActivityListItem<T>> listItems;

  const ActivityListItem({
    required this.day,
    required this.listItems,
  });

  void removeItem(String uid) {
    listItems.removeWhere((element) => element.activity.uid == uid);
  }

  ActivityListItem copyWith({
    DateTime? day,
    List<DayActivityListItem<T>>? listItems,
  }) {
    return ActivityListItem(
      day: day ?? this.day,
      listItems: listItems ?? this.listItems,
    );
  }
}

class DayActivityListItem<T> {
  final ConcreteDataDomain data;
  final T activity;

  const DayActivityListItem({
    required this.data,
    required this.activity,
  });
}
