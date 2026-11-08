import 'dart:async';

import 'package:capyscript/api_clients/audio_api_client.dart';
import 'package:capyscript/modules/waka_models/models/audio/audio_marker.dart';
import 'package:capyscript/modules/waka_models/models/audio/audio_track_source.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wakaranai/blocs/audiobook_player/audiobook_player_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/shared_pref/audiobook_player_preferences.dart';
import 'package:wakaranai/services/audiobooks/audiobook_engine.dart';
import 'package:wakaranai/services/audiobooks/audiobook_media_session.dart';
import 'package:wakaranai/services/audiobooks/audiobook_progress_store.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';

class _FakeEngine implements AudiobookEngine {
  final StreamController<AudiobookEngineSnapshot> _snapshots =
      StreamController<AudiobookEngineSnapshot>.broadcast(sync: true);
  final StreamController<Object> _errors =
      StreamController<Object>.broadcast(sync: true);
  final List<AudiobookStream> loaded = <AudiobookStream>[];
  final List<Duration> loadedAt = <Duration>[];
  Duration trackLength = const Duration(minutes: 10);
  Object? loadError;
  double speed = 1;
  AudiobookEngineSnapshot _current = const AudiobookEngineSnapshot();

  @override
  Stream<AudiobookEngineSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<Object> get errors => _errors.stream;

  @override
  AudiobookEngineSnapshot get current => _current;

  void emit({
    Duration? position,
    bool? playing,
    bool completed = false,
  }) {
    _current = AudiobookEngineSnapshot(
      position: position ?? _current.position,
      duration: trackLength,
      playing: playing ?? _current.playing,
      completed: completed,
    );
    _snapshots.add(_current);
  }

  @override
  Future<Duration?> load(
    AudiobookStream stream, {
    Duration initialPosition = Duration.zero,
  }) async {
    final Object? error = loadError;
    if (error != null) {
      throw error;
    }
    loaded.add(stream);
    loadedAt.add(initialPosition);
    _current = AudiobookEngineSnapshot(
      position: initialPosition,
      duration: trackLength,
    );
    return trackLength;
  }

  @override
  Future<void> play() async {
    emit(playing: true);
  }

  @override
  Future<void> pause() async {
    _current = AudiobookEngineSnapshot(
      position: _current.position,
      duration: _current.duration,
    );
    _snapshots.add(_current);
  }

  @override
  Future<void> seek(Duration position) async {
    emit(position: position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed = speed;
  }

  @override
  Future<void> stop() async {
    _current = const AudiobookEngineSnapshot();
  }

  @override
  Future<void> dispose() async {
    await _snapshots.close();
    await _errors.close();
  }
}

class _RecordingMediaSession implements AudiobookMediaSession {
  AudiobookMediaControls? controls;
  final List<AudiobookMediaSnapshot> published = <AudiobookMediaSnapshot>[];
  int cleared = 0;

  @override
  Future<void> attach(AudiobookMediaControls controls) async {
    this.controls = controls;
  }

  @override
  void publish(AudiobookMediaSnapshot snapshot) {
    published.add(snapshot);
  }

  @override
  Future<void> clear() async {
    cleared++;
  }
}

const List<Chapter> _tracks = <Chapter>[
  Chapter(uid: 't1', title: 'Part 1', data: <String, dynamic>{'n': 1}),
  Chapter(uid: 't2', title: 'Part 2', data: <String, dynamic>{'n': 2}),
  Chapter(uid: 't3', title: 'Part 3', data: <String, dynamic>{'n': 3}),
];

ConfigInfo _config() {
  return ConfigInfo.fromJson(<String, dynamic>{
    'name': 'LibriVox',
    'uid': 'librivox',
    'logoUrl': '',
    'type': 3,
    'nsfw': false,
    'language': 'English',
    'version': 1,
    'searchAvailable': true,
    'filters': <dynamic>[],
  });
}

AudiobookSession _session() {
  return AudiobookSession(
    client: AudioApiClient(code: ''),
    configInfo: _config(),
    concreteUid: 'book-1',
    title: 'Book',
    tracks: _tracks,
    cover: 'https://example.org/cover.jpg',
  );
}

void main() {
  late WakaranaiDatabase database;
  late ChapterActivityRepository activities;
  late ConcreteDataRepository concretes;
  late _FakeEngine engine;
  late _RecordingMediaSession media;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    IncognitoMode.active = false;
    database = WakaranaiDatabase.forTesting(
      NativeDatabase.opened(sqlite3.openInMemory()),
    );
    activities = ChapterActivityRepository(database: database);
    concretes = ConcreteDataRepository(database: database);
    await concretes.create(
      ConcreteDataDomain(
        id: 0,
        uid: 'book-1',
        extensionUid: 'librivox',
        title: 'Book',
        createdAt: DateTime(2025),
      ),
    );
    engine = _FakeEngine();
    media = _RecordingMediaSession();
  });

  tearDown(() async {
    IncognitoMode.active = false;
    await database.close();
  });

  AudiobookPlayerCubit cubit({AudiobookSourcesLoader? loader}) {
    return AudiobookPlayerCubit(
      progressStore: AudiobookProgressStore(
        chapterActivityRepository: activities,
        concreteDataRepository: concretes,
      ),
      engineFactory: () => engine,
      mediaSession: media,
      loadSources: loader ??
          (AudiobookSession session, Chapter track) async => <AudioTrackSource>[
                AudioTrackSource(
                  url: 'https://cdn.example/${track.uid}.mp3',
                  headers: const <String, String>{'Referer': 'r'},
                  markers: const <AudioMarker>[
                    AudioMarker(title: 'Intro', start: 0),
                    AudioMarker(title: 'Main', start: 60),
                  ],
                ),
                AudioTrackSource(
                  url: 'https://cdn.example/${track.uid}-low.mp3',
                  quality: '64kbps',
                ),
              ],
    );
  }

  Future<ChapterActivityDomain?> stored(String uid) {
    return activities.getBy<$ChapterActivityTableTable>(
      uid,
      where: (tbl) => tbl.uid,
    );
  }

  test('opening a track loads its first source and starts playing', () async {
    final AudiobookPlayerCubit player = cubit();

    await player.open(_session(), trackIndex: 1);

    expect(player.state.status, AudiobookStatus.ready);
    expect(player.state.track?.uid, 't2');
    expect(player.state.playing, isTrue);
    expect(player.state.duration, const Duration(minutes: 10));
    expect(engine.loaded.single.url, 'https://cdn.example/t2.mp3');
    expect(engine.loaded.single.headers, <String, String>{'Referer': 'r'});
    expect(media.controls, same(player));
    expect(media.published.last.title, 'Part 2');
    expect(media.published.last.album, 'Book');
    expect(media.published.last.hasNext, isTrue);
    expect(media.published.last.hasPrevious, isTrue);
    await player.close();
  });

  test('a track resumes from its saved position', () async {
    final ConcreteDataDomain? concrete = await concretes.getByUid('book-1');
    await activities.create(ChapterActivityDomain(
      id: 0,
      uid: 't1',
      title: 'Part 1',
      timestamp: null,
      data: '{}',
      concreteId: concrete!.id,
      readPages: 120,
      totalPages: 600,
      createdAt: DateTime(2025),
    ));
    final AudiobookPlayerCubit player = cubit();

    await player.open(_session(), trackIndex: 0);

    expect(engine.loadedAt.single, const Duration(seconds: 118));
    await player.close();
  });

  test('pausing saves the position in seconds', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    engine.emit(position: const Duration(minutes: 2, seconds: 5));
    await player.pause();

    final ChapterActivityDomain? activity = await stored('t1');
    expect(activity!.readPages, 125);
    expect(activity.totalPages, 600);
    expect(player.state.playing, isFalse);
    await player.close();
  });

  test('incognito mode keeps progress out of the history', () async {
    IncognitoMode.active = true;
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    engine.emit(position: const Duration(minutes: 2));
    await player.pause();

    expect(await stored('t1'), isNull);
    await player.close();
  });

  test('skips move by the configured intervals and stay in range', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    await player.skipForward();
    expect(player.state.position, const Duration(seconds: 30));
    await player.skipBackward();
    expect(player.state.position, const Duration(seconds: 15));
    await player.skipBackward();
    expect(player.state.position, Duration.zero);
    await player.seek(const Duration(hours: 2));
    expect(player.state.position, const Duration(minutes: 10));
    await player.close();
  });

  test('a finished track is marked listened and the next one starts', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    engine.emit(position: const Duration(minutes: 10), completed: true);
    await pumpEventQueue();

    final ChapterActivityDomain? finished = await stored('t1');
    expect(finished!.readPages, finished.totalPages);
    expect(player.state.track?.uid, 't2');
    expect(engine.loaded.last.url, 'https://cdn.example/t2.mp3');
    expect(engine.loadedAt.last, Duration.zero);
    await player.close();
  });

  test('the last track ends the book without wrapping around', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 2);

    engine.emit(position: const Duration(minutes: 10), completed: true);
    await pumpEventQueue();

    expect(player.state.track?.uid, 't3');
    expect(player.state.ended, isTrue);
    expect(player.state.playing, isFalse);
    expect(engine.loaded, hasLength(1));
    await player.close();
  });

  test('the end-of-track sleep timer stops before the next track', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);
    player.sleepAtEndOfTrack();

    engine.emit(position: const Duration(minutes: 10), completed: true);
    await pumpEventQueue();

    expect(player.state.track?.uid, 't1');
    expect(player.state.sleepTimer.isActive, isFalse);
    expect(engine.loaded, hasLength(1));
    await player.close();
  });

  test('a timed sleep timer pauses playback', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    player.setSleepTimer(const Duration(milliseconds: 10));
    expect(player.state.sleepTimer.mode, AudiobookSleepMode.timer);
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(player.state.sleepTimer.isActive, isFalse);
    expect(player.state.playing, isFalse);
    await player.close();
  });

  test('previous restarts the track after a few seconds in', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 1);

    engine.emit(position: const Duration(seconds: 40));
    await player.previous();
    expect(player.state.track?.uid, 't2');
    expect(player.state.position, Duration.zero);

    await player.previous();
    expect(player.state.track?.uid, 't1');
    await player.next();
    expect(player.state.track?.uid, 't2');
    await player.close();
  });

  test('reopening the playing track does not reload it', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    await player.open(_session(), trackIndex: 0);

    expect(engine.loaded, hasLength(1));
    await player.close();
  });

  test('speed changes reach the engine and are remembered', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    await player.setSpeed(1.5);

    expect(engine.speed, 1.5);
    expect(player.state.speed, 1.5);
    expect(await AudiobookPlayerPreferences().getSpeed(), 1.5);
    await player.setSpeed(9);
    expect(player.state.speed, AudiobookPlayerPreferences.maxSpeed);
    await player.close();
  });

  test('switching the source keeps the position', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);
    engine.emit(position: const Duration(seconds: 90));

    await player.selectSource(1);

    expect(engine.loaded.last.url, 'https://cdn.example/t1-low.mp3');
    expect(engine.loadedAt.last, const Duration(seconds: 90));
    expect(player.state.sourceIndex, 1);
    await player.close();
  });

  test('markers follow the position', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);

    engine.emit(position: const Duration(seconds: 75));
    expect(player.state.currentMarker?.title, 'Main');

    await player.jumpToMarker(player.state.markers.first);
    expect(player.state.currentMarker?.title, 'Intro');
    await player.close();
  });

  test('a track without sources is an error that can be retried', () async {
    int calls = 0;
    final AudiobookPlayerCubit player = cubit(
      loader: (AudiobookSession session, Chapter track) async {
        calls++;
        if (calls == 1) {
          return const <AudioTrackSource>[];
        }
        return const <AudioTrackSource>[AudioTrackSource(url: 'https://x/a.mp3')];
      },
    );

    await player.open(_session(), trackIndex: 0);
    expect(player.state.status, AudiobookStatus.error);
    expect(player.state.error, isA<AudiobookNoSourceException>());

    await player.play();
    expect(player.state.status, AudiobookStatus.ready);
    expect(engine.loaded.single.url, 'https://x/a.mp3');
    await player.close();
  });

  test('stopping ends the session and clears the notification', () async {
    final AudiobookPlayerCubit player = cubit();
    await player.open(_session(), trackIndex: 0);
    engine.emit(position: const Duration(seconds: 50));

    await player.stop();

    expect(player.state.hasSession, isFalse);
    expect(media.cleared, 1);
    expect((await stored('t1'))!.readPages, 50);
    await player.close();
  });
}
