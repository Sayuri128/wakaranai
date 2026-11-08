import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';

class AudiobookProgressStore {
  AudiobookProgressStore({
    required this.chapterActivityRepository,
    required this.concreteDataRepository,
  });

  final ChapterActivityRepository chapterActivityRepository;
  final ConcreteDataRepository concreteDataRepository;
  final Map<String, int> _concreteIds = <String, int>{};

  Future<ChapterActivityDomain?> activityOf(String trackUid) {
    return chapterActivityRepository.getBy<$ChapterActivityTableTable>(
      trackUid,
      where: (tbl) => tbl.uid,
    );
  }

  Future<int?> _concreteIdOf(String concreteUid) async {
    final int? cached = _concreteIds[concreteUid];
    if (cached != null) {
      return cached;
    }
    final ConcreteDataDomain? concrete =
        await concreteDataRepository.getByUid(concreteUid);
    if (concrete == null) {
      return null;
    }
    _concreteIds[concreteUid] = concrete.id;
    return concrete.id;
  }

  Future<bool> save({
    required String concreteUid,
    required Chapter track,
    required Duration position,
    required Duration duration,
    bool finished = false,
  }) async {
    if (IncognitoMode.active) {
      return false;
    }
    final int? concreteId = await _concreteIdOf(concreteUid);
    if (concreteId == null) {
      return false;
    }
    final ChapterActivityDomain? activity = AudioProgress.activityFor(
      track: track,
      concreteId: concreteId,
      position: position,
      duration: duration,
      finished: finished,
    );
    if (activity == null) {
      return false;
    }
    await chapterActivityRepository
        .createUpdateBy<$ChapterActivityTableTable, String>(
      activity,
      by: (tbl) => tbl.uid,
      where: (tbl) => tbl.uid,
    );
    return true;
  }
}
