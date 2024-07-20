import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain/concrete_data_domain.dart';

class ActivityListItem {
  final DateTime day;
  final List<DayActivityListItem> listItems;

  const ActivityListItem({
    required this.day,
    required this.listItems,
  });
}

class DayActivityListItem implements Comparable<DayActivityListItem> {
  final ConcreteDataDomain data;
  final ChapterActivityDomain activity;

  const DayActivityListItem({
    required this.data,
    required this.activity,
  });

  bool operator >(DayActivityListItem other) {
    return (data.updatedAt ?? data.createdAt)
        .isAfter(other.data.updatedAt ?? other.data.createdAt);
  }

  bool operator <(DayActivityListItem other) {
    return (data.updatedAt ?? data.createdAt)
        .isBefore(other.data.updatedAt ?? other.data.createdAt);
  }

  @override
  int compareTo(other) {
    if (this > other) {
      return 1;
    } else if (this < other) {
      return -1;
    } else {
      return 0;
    }
  }


}
