import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/repositories/database/base_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

mixin ActivityHistoryCubitMixin<TDomain extends BaseActivityDomain> {
  List<OrderingTerm Function(dynamic)> getOrderingTerms() {
    return [
      (t) => OrderingTerm(
            expression: t.createdAt,
            mode: OrderingMode.desc,
          ),
      (t) => OrderingTerm(
            expression: t.updatedAt,
            mode: OrderingMode.desc,
          ),
    ];
  }

  Future<Map<int, ConcreteDataDomain>> fetchConcretes(
      {required Set<int> concreteIds,
      required ConcreteDataRepository concreteDataRepository}) async {
    final Map<int, ConcreteDataDomain> activities = {};

    for (final id in concreteIds) {
      final concreteData = await concreteDataRepository.get(id);
      if (concreteData != null) {
        activities[id] = concreteData;
      }
    }

    return activities;
  }

  List<ActivityListItem<TDomain>> createActivityListItems({
    required List<TDomain> data,
    required Map<int, ConcreteDataDomain> activities,
    required int Function(TDomain data) getConcreteId,
  }) {
    final List<ActivityListItem<TDomain>> items = [];

    DateTime? lastDay;

    for (final activity in data) {
      final concreteData = activities[getConcreteId(activity)];
      lastDay ??= activity.updatedAt ?? activity.createdAt;
      final lastDayDay = lastDay.day;
      final activityDay = (activity.updatedAt ?? activity.createdAt).day;
      if (lastDayDay != activityDay || items.isEmpty) {
        items.add(
          ActivityListItem(
            day: activity.updatedAt ?? activity.createdAt,
            listItems: [],
          ),
        );
        lastDay = activity.updatedAt ?? activity.createdAt;
      }

      items.last.listItems.add(
        DayActivityListItem<TDomain>(
          data: concreteData!,
          activity: activity,
        ),
      );
    }

    return items;
  }

  List<ActivityListItem<TDomain>> removeActivityListItem(
      List<ActivityListItem<TDomain>> items, String uid) {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final index = item.listItems.indexWhere((element) => element.activity.uid == uid);
      if (index != -1) {
        item.listItems.removeAt(index);
        if (item.listItems.isEmpty) {
          items.removeAt(i);
        }
        return items;
      }
    }
    return items;
  }
}
