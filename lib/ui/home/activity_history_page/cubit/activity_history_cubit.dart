import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/utils/snackbars.dart';

part 'activity_history_state.dart';

class ActivityHistoryCubit extends Cubit<ActivityHistoryState> {
  ActivityHistoryCubit({
    required this.extensionRepository,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
  }) : super(ActivityHistoryInitial());

  final ExtensionRepository extensionRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;

  void init() async {
    emit(ActivityHistoryLoading());

    try {
      final data = await chapterActivityRepository.getAll(orderBy: [
        (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
      ]);

      final Map<int, ConcreteDataDomain> chapterActivities = {};

      for (final id in data.map((e) => e.concreteId).toSet()) {
        final concreteData = await concreteDataRepository.get(id);
        if (concreteData != null) {
          chapterActivities[id] = concreteData;
        }
      }

      final List<ActivityListItem> items = [];

      DateTime? lastDay;
      for (final activity in data) {
        final concreteData = chapterActivities[activity.concreteId];
        lastDay ??= activity.updatedAt ?? activity.createdAt;
        final lastDayDay = lastDay.day;
        final activityDay = (activity.updatedAt ?? activity.createdAt).day;
        if (lastDayDay != activityDay ||
            items.isEmpty) {
          items.add(
            ActivityListItem(
              day: activity.updatedAt ?? activity.createdAt,
              listItems: [
                DayActivityListItem(
                  data: concreteData!,
                  activity: activity,
                ),
              ],
            ),
          );
          lastDay = activity.updatedAt ?? activity.createdAt;
        } else {
          items.last.listItems.add(
            DayActivityListItem(
              data: concreteData!,
              activity: activity,
            ),
          );
        }
      }

      for (final item in items) {
        item.listItems.sort();
        final reversed = item.listItems.reversed.toList();
        item.listItems
          ..clear()
          ..addAll(reversed);
      }

      emit(
        ActivityHistoryLoaded(
          activities: items,
        ),
      );
    } catch (e) {
      emit(
        ActivityHistoryError(S.current.activity_history_error_loading_history),
      );
    }
  }

  void onActivityTap(
    BuildContext context, {
    required ConcreteDataDomain concrete,
    required ChapterActivityDomain activity,
  }) async {
    final extension = await extensionRepository.getByUid(concrete.extensionUid);
    if (extension == null) {
      showErrorSnackbar(
          context, S.current.activity_history_error_loading_history);
      return;
    }

    final apiClient = MangaApiClient(code: extension.sourceCode);

    final coverHeaders = await apiClient.getImageHeaders(
      uid: concrete.uid,
      data: concrete.dataJson,
    );

    Navigator.of(context).pushNamed(
      Routes.mangaServiceViewer,
      arguments: MangaServiceViewData(
        remoteConfig: extension,
        nextViewerData: MangaConcreteViewerData(
          uid: concrete.uid,
          galleryData: concrete.dataJson,
          coverHeaders: coverHeaders,
          client: apiClient,
          configInfo: extension.config,
          galleryCover: null,
        ),
      ),
    );
  }
}
