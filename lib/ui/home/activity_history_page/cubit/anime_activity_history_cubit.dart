import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/activity_history_cubit_mixin.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

part 'anime_activity_history_state.dart';

class AnimeActivityHistoryCubit extends Cubit<AnimeActivityHistoryState>
    with ActivityHistoryCubitMixin<AnimeEpisodeActivityDomain> {
  AnimeActivityHistoryCubit({
    required this.extensionRepository,
    required this.concreteDataRepository,
    required this.animeEpisodeActivityRepository,
  }) : super(AnimeActivityHistoryInitial());

  final ExtensionRepository extensionRepository;
  final ConcreteDataRepository concreteDataRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;

  void init() async {
    emit(AnimeActivityHistoryLoading());

    try {
      final data = await animeEpisodeActivityRepository.getAll(
        orderBy: getOrderingTerms(),
      );

      final Map<int, ConcreteDataDomain> animeEpisodeActivities =
          await fetchConcretes(
        concreteIds: data.map((e) => e.concreteId).toSet(),
        concreteDataRepository: concreteDataRepository,
      );
      emit(
        AnimeActivityHistoryLoaded(
            animeActivities: createActivityListItems(
          data: data,
          activities: animeEpisodeActivities,
          getConcreteId: (activity) => activity.concreteId,
        )),
      );
    } catch (e) {
      emit(AnimeActivityHistoryError(
        S.current.activity_history_error_loading_history,
      ));
    }
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

    final apiClient = AnimeApiClient(code: extension.sourceCode);

    final coverHeaders = await apiClient.getImageHeaders(
      uid: concrete.uid,
      data: concrete.dataJson,
    );

    Navigator.of(context).pushNamed(
      Routes.animeServiceViewer,
      arguments: AnimeServiceViewerData(
        remoteConfig: extension,
        nextViewerData: AnimeConcreteViewerData(
          uid: concrete.uid,
          configInfo: extension.config,
          client: apiClient,
          galleryData: concrete.dataJson,
          galleryCover: null,
        ),
      ),
    );
  }

  Future<void> onDelete(
      {required BuildContext context, required BaseActivityDomain activity}) {
    return animeEpisodeActivityRepository
        .deleteBy<$AnimeEpisodeActivityTableTable>(activity.id,
            where: (tbl) => tbl.id)
        .then((_) {
      if (state is AnimeActivityHistoryLoaded) {
        final loadedState = state as AnimeActivityHistoryLoaded;
        final List<ActivityListItem<AnimeEpisodeActivityDomain>> copy =
            List.from(loadedState.animeActivities);
        emit(AnimeActivityHistoryLoaded(
            animeActivities: removeActivityListItem(copy, activity.uid)));
      }

      SnackBars.showSnackBar(
          context: context,
          message: S.current.activity_history_deleted_activity);
    });
  }
}
