import 'package:video_player/video_player.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/parked_episode.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

class EpisodeProgressKeeper {
  EpisodeProgressKeeper(EpisodeProgressStore store) : _store = store;

  EpisodeProgressStore _store;
  EpisodeProgress? _saved;
  EpisodeProgress? _lastPersisted;
  Future<void> _pendingSave = Future<void>.value();

  EpisodeProgressStore get store => _store;

  EpisodeProgress? get saved => _saved;

  EpisodeProgress? get lastPersisted => _lastPersisted;

  void startEpisode(EpisodeProgressStore store) {
    _store = store;
    _saved = null;
    _lastPersisted = null;
  }

  void restore(ParkedEpisode parked) {
    _store = parked.progressStore;
    _saved = parked.savedProgress;
    _lastPersisted = parked.lastPersistedProgress;
  }

  Future<void> loadSaved() async {
    try {
      _saved = await _store.start();
    } catch (error, stackTrace) {
      logger.e('Failed to load episode progress: $error');
      logger.e(stackTrace);
      _saved = null;
    }
  }

  Future<void> save(EpisodeProgress? Function() readProgress) {
    _pendingSave = _pendingSave.then((_) => _persist(readProgress()));
    return _pendingSave;
  }

  Future<void> saveParked(ParkedEpisode parked) {
    _pendingSave = _pendingSave.then((_) => _persistParked(parked));
    return _pendingSave;
  }

  Future<void> _persist(EpisodeProgress? progress) async {
    if (progress == null || progress == _lastPersisted) {
      return;
    }
    try {
      await _store.save(progress);
      _lastPersisted = progress;
    } catch (error, stackTrace) {
      logger.e('Failed to save episode progress: $error');
      logger.e(stackTrace);
    }
  }

  Future<void> _persistParked(ParkedEpisode parked) async {
    final EpisodeProgress? progress = parked.progress;
    if (progress == null || progress == parked.lastPersistedProgress) {
      return;
    }
    try {
      await parked.progressStore.save(progress);
      parked.lastPersistedProgress = progress;
    } catch (error, stackTrace) {
      logger.e('Failed to save episode progress: $error');
      logger.e(stackTrace);
    }
  }
}

EpisodeProgress? episodeProgressOf(VideoPlayerValue value) {
  if (!value.isInitialized || value.duration <= Duration.zero) {
    return null;
  }
  final Duration watched = value.isCompleted ? value.duration : value.position;
  if (watched <= Duration.zero) {
    return null;
  }
  return EpisodeProgress(
    watchedSeconds: watched.inSeconds,
    totalSeconds: value.duration.inSeconds,
  );
}
