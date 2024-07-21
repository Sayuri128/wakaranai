import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

part 'anime_iframe_player_state.dart';

class AnimeIframePlayerCubit extends Cubit<AnimeIframePlayerState> {
  AnimeIframePlayerCubit({
    required this.concreteDataRepository,
    required this.animeEpisodeActivityRepository,
  }) : super(AnimeIframePlayerInitial());

  final ConcreteDataRepository concreteDataRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;

  void init({
    required AnimeConcreteView anime,
    required AnimeVideo video,
  }) async {
    final concreteData = await concreteDataRepository.getByUid(anime.uid);

    if (concreteData != null) {
      animeEpisodeActivityRepository
          .createUpdateBy<$AnimeEpisodeActivityTableTable, String>(
        AnimeEpisodeActivityDomain(
          id: 0,
          title: video.title,
          uid: video.uid,
          concreteId: concreteData.id,
          data: jsonEncode(video.data),
          watchedTime: null,
          totalTime: null,
          timestamp: video.timestamp,
          createdAt: DateTime.now(),
        ),
        by: (tbl) => tbl.uid,
        where: (tbl) => tbl.uid,
      );
    }
  }
}
