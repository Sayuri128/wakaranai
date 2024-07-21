import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/activity_history_cubit_mixin.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/utils/snackbars.dart';

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
    required AnimeEpisodeActivityDomain activity,
  }) async {
    final extension = await extensionRepository.getByUid(concrete.extensionUid);

    if (extension == null) {
      showErrorSnackbar(
          context, S.current.activity_history_error_loading_history);
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
}
