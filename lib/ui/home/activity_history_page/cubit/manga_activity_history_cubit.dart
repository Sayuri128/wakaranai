import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/activity_history_cubit_mixin.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

part 'manga_activity_history_state.dart';

class MangaActivityHistoryCubit extends Cubit<ActivityHistoryState>
    with ActivityHistoryCubitMixin<ChapterActivityDomain> {
  MangaActivityHistoryCubit({
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
      final data =
          await chapterActivityRepository.getAll(orderBy: getOrderingTerms());

      final Map<int, ConcreteDataDomain> chapterActivities =
          await fetchConcretes(
              concreteIds: data.map((e) => e.concreteId).toSet(),
              concreteDataRepository: concreteDataRepository);

      emit(
        ActivityHistoryLoaded(
          mangaActivities: createActivityListItems(
            data: data,
            activities: chapterActivities,
            getConcreteId: (activity) => activity.concreteId,
          ),
        ),
      );
    } catch (e) {
      emit(
        ActivityHistoryError(
          S.current.activity_history_error_loading_history,
        ),
      );
    }
  }

  void onDelete({
    required BuildContext context,
    required BaseActivityDomain activity,
  }) async {
    await chapterActivityRepository.deleteBy<$ChapterActivityTableTable>(
        activity.id,
        where: (tbl) => tbl.id);

    if (state is ActivityHistoryLoaded) {
      final loadedState = state as ActivityHistoryLoaded;
      final List<ActivityListItem<ChapterActivityDomain>> copy =
          List.from(loadedState.mangaActivities);
      emit(
        ActivityHistoryLoaded(
          mangaActivities: removeActivityListItem(copy, activity.uid),
        ),
      );
    }

    SnackBars.showSnackBar(
        context: context, message: S.current.activity_history_deleted_activity);
  }

  void onActivityTap(
    BuildContext context, {
    required ConcreteDataDomain concrete,
    required BaseActivityDomain activity,
  }) async {
    final extension = await extensionRepository.getByUid(concrete.extensionUid);
    if (extension == null) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.activity_history_error_loading_history,
      );
      return;
    }

    final apiClient = MangaApiClient(code: extension.sourceCode);

    final coverHeaders = await apiClient.getImageHeaders(
      uid: concrete.uid,
      data: concrete.dataJson,
    );

    Navigator.of(context)
        .pushNamed(
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
    )
        .then((_) {
      init();
    });
  }
}
