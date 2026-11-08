import 'dart:async';

import 'package:capyscript/api_clients/source_error.dart';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/runtime/download_network_policy.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';
import 'package:wakaranai/services/downloads/runtime/network_monitor.dart';
import 'package:wakaranai/services/downloads/storage/local_playback_fallback.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/native_player_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/picture_in_picture.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_device_controls.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_overlay.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pip_scope.dart';

const Duration _episodeLength = Duration(minutes: 24);
const Size _videoSize = Size(1920, 1080);
const String _wakelockChannel =
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';

class _FakeEngine extends ValueNotifier<VideoPlayerValue>
    implements NativePlayerEngine {
  _FakeEngine({this.initializeGate, this.failInitialize = false})
      : super(const VideoPlayerValue.uninitialized());

  final Completer<void>? initializeGate;
  final bool failInitialize;

  @override
  Future<void> initialize() async {
    final Completer<void>? gate = initializeGate;
    if (gate != null) {
      await gate.future;
    }
    if (failInitialize) {
      throw StateError('local file could not be decoded');
    }
    value = value.copyWith(
      isInitialized: true,
      duration: _episodeLength,
      size: _videoSize,
    );
  }

  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true, isCompleted: false);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    value = value.copyWith(position: position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
  }

  @override
  Future<void> setClosedCaptionFile(ClosedCaptionFile? captionFile) async {}

  @override
  bool get supportsVideoTracks => false;

  @override
  Future<List<VideoTrack>> getVideoTracks() async {
    return const <VideoTrack>[];
  }

  @override
  Future<void> selectVideoTrack(VideoTrack? track) async {}

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget buildView() {
    return const SizedBox.shrink();
  }
}

class _FakeProgressStore implements EpisodeProgressStore {
  @override
  Future<EpisodeProgress?> start() async {
    return null;
  }

  @override
  Future<void> save(EpisodeProgress progress) async {}
}

class _FakeSubtitleLoader implements SubtitleLoader {
  @override
  Future<ClosedCaptionFile> load(PlayableSubtitle subtitle) async {
    return WebVTTCaptionFile('WEBVTT\n');
  }
}

class _FakeDeviceControls implements PlayerDeviceControls {
  @override
  Future<double?> readBrightness() async {
    return null;
  }

  @override
  Future<void> setBrightness(double brightness) async {}

  @override
  Future<void> restoreBrightness() async {}

  @override
  Future<double?> readVolume() async {
    return null;
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> rememberOpeningVolume() async {}

  @override
  Future<void> restoreVolume() async {}
}

class _FakePictureInPicture implements PictureInPicture {
  _FakePictureInPicture({this.supported = true});

  final bool supported;
  final List<PictureInPictureConfig> configs = <PictureInPictureConfig>[];
  final ValueNotifier<bool> mode = ValueNotifier<bool>(false);
  final StreamController<PictureInPictureAction> actionController =
      StreamController<PictureInPictureAction>.broadcast();
  int enterCalls = 0;
  int disableCalls = 0;

  @override
  ValueListenable<bool> get inPictureInPicture => mode;

  @override
  Stream<PictureInPictureAction> get actions => actionController.stream;

  @override
  Future<bool> isSupported() async {
    return supported;
  }

  @override
  Future<void> configure(PictureInPictureConfig config) async {
    configs.add(config);
  }

  @override
  Future<bool> enter() async {
    enterCalls++;
    return true;
  }

  @override
  Future<void> disable() async {
    disableCalls++;
  }

  @override
  void dispose() {
    unawaited(actionController.close());
    mode.dispose();
  }
}

AnimeVideo _episode(String uid, String title) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/$uid',
    title: title,
    timestamp: null,
    data: <String, dynamic>{'uid': uid},
  );
}

final List<AnimeVideoGroup> _groups = <AnimeVideoGroup>[
  AnimeVideoGroup(
    title: 'Dub',
    elements: <AnimeVideo>[
      _episode('e1', 'Episode 1'),
      _episode('e2', 'Episode 2'),
    ],
  ),
];

const AnimeConcreteView _anime = AnimeConcreteView(
  uid: 'anime-1',
  cover: '',
  title: 'Frieren',
  alternativeTitles: <String>[],
  description: '',
  tags: <String>[],
  groups: <AnimeVideoGroup>[],
  status: AnimeStatus.ONGOING,
);

PlayableVideo _videoFor(
  String uid, {
  List<PlayableSkipMarker> skipMarkers = const <PlayableSkipMarker>[],
  bool local = false,
}) {
  return PlayableVideo(
    streams: <PlayableStream>[
      PlayableStream(
        url: local ? 'file:///downloads/$uid.mp4' : 'https://cdn.test/$uid.mp4',
        quality: '1080p',
        skipMarkers: skipMarkers,
      ),
    ],
  );
}

class _Harness {
  _Harness({
    this.holdInitialize = false,
    this.webOnlyUids = const <String>{},
    this.sourceErrors = const <String, SourceError>{},
    this.skipMarkers = const <PlayableSkipMarker>[],
    this.brokenLocalFile = false,
  });

  final bool holdInitialize;
  final bool brokenLocalFile;
  final Set<String> webOnlyUids;
  final Map<String, SourceError> sourceErrors;
  final List<PlayableSkipMarker> skipMarkers;
  final List<_FakeEngine> engines = <_FakeEngine>[];
  final List<String> resolvedUids = <String>[];
  final Completer<void> initializeGate = Completer<void>();
  NativePlayerCubit? cubit;

  EpisodePlaylist get playlist => EpisodePlaylist(
        groups: _groups,
        groupIndex: 0,
        current: _groups.first.elements.first,
      );

  NativePlayerCubit build(BuildContext context) {
    final NativePlayerCubit created = NativePlayerCubit(
      video: _videoFor(
        'e1',
        skipMarkers: skipMarkers,
        local: brokenLocalFile,
      ),
      playlist: playlist,
      engineFactory: _createEngine,
      progressStoreFor: (AnimeVideo episode) => _FakeProgressStore(),
      subtitleLoader: _FakeSubtitleLoader(),
      resolveEpisode: _resolve,
      preferences: PlayerPreferences(),
      progressSaveInterval: const Duration(hours: 1),
      autoNextTick: const Duration(hours: 1),
    );
    cubit = created;
    return created;
  }

  Future<EpisodePlaybackPlan> _resolve(EpisodePlaylist target) async {
    resolvedUids.add(target.current.uid);
    final SourceError? sourceError = sourceErrors[target.current.uid];
    if (sourceError != null) {
      return SourceErrorPlaybackPlan(sourceError);
    }
    if (webOnlyUids.contains(target.current.uid)) {
      return const WebPlaybackPlan(WebPlaybackReason.unsupported);
    }
    return NativePlaybackPlan(_videoFor(target.current.uid));
  }

  NativePlayerEngine _createEngine(PlayableStream stream) {
    final bool hold = holdInitialize && engines.isEmpty;
    final _FakeEngine engine = _FakeEngine(
      initializeGate: hold ? initializeGate : null,
      failInitialize: brokenLocalFile,
    );
    engines.add(engine);
    return engine;
  }
}

class _SystemUiLog {
  final List<String> calls = <String>[];

  int count(String method) {
    return calls.where((String call) => call == method).length;
  }
}

_SystemUiLog _recordSystemUi() {
  final _SystemUiLog log = _SystemUiLog();
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform,
      (MethodCall call) async {
    log.calls.add(call.method);
    return null;
  });
  messenger.setMockMessageHandler(_wakelockChannel, (ByteData? message) async {
    return const StandardMessageCodec().encodeMessage(<Object?>[null]);
  });
  addTearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMessageHandler(_wakelockChannel, null);
  });
  return log;
}

Future<void> _pumpPlayer(
  WidgetTester tester, {
  required _Harness harness,
  required _FakePictureInPicture pictureInPicture,
  SourceSignIn? signIn,
}) async {
  tester.view.physicalSize = const Size(1600, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: NativePlayer(
        data: NativePlayerData(
          video: _videoFor('e1'),
          anime: _anime,
          playlist: harness.playlist,
          resolveEpisode: harness._resolve,
          sourceName: 'AnimeSite',
          signIn: signIn,
        ),
        pictureInPicture: pictureInPicture,
        deviceControls: _FakeDeviceControls(),
        cubitFactory: harness.build,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

class _PlayerRouteOutcome {
  bool finished = false;
  Object? result;
}

class _DownloadScope {
  _DownloadScope() {
    repository = DownloadRepository(database: database);
    manager = DownloadManagerCubit(
      downloadRepository: repository,
      downloadRuntime: NoopDownloadRuntime(),
      networkPolicy: DownloadNetworkPolicy(
        monitor: UnrestrictedNetworkMonitor(),
        readWifiOnly: () async => false,
      ),
    );
  }

  final WakaranaiDatabase database =
      WakaranaiDatabase.forTesting(NativeDatabase.memory());
  late final DownloadRepository repository;
  late final DownloadManagerCubit manager;

  Widget wrap(Widget app) {
    return RepositoryProvider<DownloadRepository>.value(
      value: repository,
      child: BlocProvider<DownloadManagerCubit>.value(
        value: manager,
        child: app,
      ),
    );
  }
}

Future<_PlayerRouteOutcome> _pumpPlayerRoute(
  WidgetTester tester, {
  required _Harness harness,
  required _FakePictureInPicture pictureInPicture,
  _DownloadScope? downloads,
}) async {
  tester.view.physicalSize = const Size(1600, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final _PlayerRouteOutcome outcome = _PlayerRouteOutcome();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Widget app = MaterialApp(
    navigatorKey: navigatorKey,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: const Scaffold(body: SizedBox.shrink()),
  );
  final _DownloadScope? downloadScope = downloads;
  if (downloadScope == null) {
    await tester.pumpWidget(app);
  } else {
    await tester.pumpWidget(downloadScope.wrap(app));
  }
  final Future<Object?> pushed = navigatorKey.currentState!.push<Object?>(
    MaterialPageRoute<Object?>(
      builder: (BuildContext context) => NativePlayer(
        data: NativePlayerData(
          video: _videoFor('e1', local: harness.brokenLocalFile),
          anime: _anime,
          playlist: harness.playlist,
          resolveEpisode: harness._resolve,
        ),
        pictureInPicture: pictureInPicture,
        deviceControls: _FakeDeviceControls(),
        cubitFactory: harness.build,
      ),
    ),
  );
  unawaited(pushed.then((Object? result) {
    outcome.finished = true;
    outcome.result = result;
  }));
  await tester.pumpAndSettle();
  return outcome;
}

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (int frame = 0; frame < count; frame++) {
    await tester.pump();
  }
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

NativePlayerState _readyState({required bool playing}) {
  return NativePlayerState(
    playlist: EpisodePlaylist(
      groups: _groups,
      groupIndex: 0,
      current: _groups.first.elements.first,
    ),
    status: NativePlayerStatus.ready,
    engine: _FakeEngine(),
    isPlaying: playing,
  );
}

void main() {
  late S strings;

  setUpAll(() async {
    strings = await S.load(const Locale('en'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('nativePlayerPipConfig', () {
    test('arms auto-enter with the video aspect while playing', () {
      final PictureInPictureConfig config = nativePlayerPipConfig(
        state: _readyState(playing: true),
        hasNextEpisode: true,
        videoSize: _videoSize,
        strings: strings,
      );

      expect(config.autoEnter, isTrue);
      expect(config.aspectWidth, 1920);
      expect(config.aspectHeight, 1080);
      expect(config.playing, isTrue);
      expect(config.hasNext, isTrue);
      expect(config.toggleTitle, strings.native_player_pause);
      expect(config.nextTitle, strings.native_player_next_episode);
    });

    test('disarms when paused and offers play', () {
      final PictureInPictureConfig config = nativePlayerPipConfig(
        state: _readyState(playing: false),
        hasNextEpisode: false,
        videoSize: _videoSize,
        strings: strings,
      );

      expect(config.autoEnter, isFalse);
      expect(config.playing, isFalse);
      expect(config.hasNext, isFalse);
      expect(config.toggleTitle, strings.native_player_play);
    });

    test('ignores an unknown video size', () {
      final PictureInPictureConfig config = nativePlayerPipConfig(
        state: _readyState(playing: true),
        hasNextEpisode: false,
        videoSize: Size.zero,
        strings: strings,
      );

      expect(config.aspectWidth, 0);
      expect(config.aspectHeight, 0);
    });

    test('stays disarmed while loading', () {
      final PictureInPictureConfig config = nativePlayerPipConfig(
        state: NativePlayerState(
          playlist: _readyState(playing: true).playlist,
          isPlaying: true,
        ),
        hasNextEpisode: false,
        videoSize: _videoSize,
        strings: strings,
      );

      expect(config.autoEnter, isFalse);
    });
  });

  group('native player picture-in-picture', () {
    testWidgets('configures auto-enter while playing and disables on dispose',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness();
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );

      final PictureInPictureConfig armed = pictureInPicture.configs.last;
      expect(armed.autoEnter, isTrue);
      expect(armed.aspectWidth, 1920);
      expect(armed.aspectHeight, 1080);
      expect(armed.playing, isTrue);
      expect(armed.hasNext, isTrue);

      await harness.cubit!.togglePlayPause();
      await tester.pump();

      final PictureInPictureConfig paused = pictureInPicture.configs.last;
      expect(paused.autoEnter, isFalse);
      expect(paused.playing, isFalse);
      expect(paused.aspectWidth, 1920);
      expect(pictureInPicture.disableCalls, 0);

      await _unmount(tester);

      expect(pictureInPicture.disableCalls, 1);
    });

    testWidgets('hides the overlay in picture-in-picture and restores it',
        (WidgetTester tester) async {
      final _SystemUiLog systemUi = _recordSystemUi();
      final _Harness harness = _Harness();
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );
      expect(find.byType(NativePlayerOverlay), findsOneWidget);
      final int immersiveCalls =
          systemUi.count('SystemChrome.setEnabledSystemUIMode');
      final int orientationCalls =
          systemUi.count('SystemChrome.setPreferredOrientations');

      pictureInPicture.mode.value = true;
      await tester.pump();

      expect(find.byType(NativePlayerOverlay), findsNothing);
      expect(harness.cubit!.state.isPlaying, isTrue);

      pictureInPicture.mode.value = false;
      await tester.pump();

      expect(find.byType(NativePlayerOverlay), findsOneWidget);
      expect(
        systemUi.count('SystemChrome.setEnabledSystemUIMode'),
        immersiveCalls + 1,
      );
      expect(
        systemUi.count('SystemChrome.setPreferredOrientations'),
        orientationCalls + 1,
      );

      await _unmount(tester);
    });

    testWidgets('shows the marker skip button outside picture-in-picture only',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(
        skipMarkers: const <PlayableSkipMarker>[
          PlayableSkipMarker(
            type: PlayableSkipType.intro,
            start: Duration.zero,
            end: Duration(seconds: 90),
          ),
        ],
      );
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );

      expect(find.text(strings.player_skip_intro), findsOneWidget);
      expect(find.text(strings.native_player_skip_opening(85)), findsNothing);

      pictureInPicture.mode.value = true;
      await tester.pump();
      expect(find.text(strings.player_skip_intro), findsNothing);

      pictureInPicture.mode.value = false;
      await tester.pump();
      await tester.tap(find.text(strings.player_skip_intro));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(harness.engines.last.value.position, const Duration(seconds: 90));
      expect(find.text(strings.player_skip_intro), findsNothing);

      await _unmount(tester);
    });

    testWidgets('keeps the fixed skip button when the source has no markers',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: _FakePictureInPicture(),
      );

      expect(find.text(strings.native_player_skip_opening(85)), findsOneWidget);
      expect(find.text(strings.player_skip_intro), findsNothing);

      await _unmount(tester);
    });

    testWidgets('keeps the fixed skip button when only an outro is marked',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(
        skipMarkers: const <PlayableSkipMarker>[
          PlayableSkipMarker(
            type: PlayableSkipType.outro,
            start: Duration(minutes: 22),
            end: Duration(minutes: 24),
          ),
        ],
      );
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: _FakePictureInPicture(),
      );

      expect(find.text(strings.native_player_skip_opening(85)), findsOneWidget);

      await _unmount(tester);
    });

    testWidgets('loading in picture-in-picture shows only a black view',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(holdInitialize: true);
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pictureInPicture.mode.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

      harness.initializeGate.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(NativePlayerOverlay), findsNothing);

      await _unmount(tester);
    });

    testWidgets('the top bar button enters picture-in-picture',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: _Harness(),
        pictureInPicture: pictureInPicture,
      );

      await tester.tap(find.byIcon(Icons.picture_in_picture_alt_rounded));
      await tester.pump();

      expect(pictureInPicture.enterCalls, 1);

      await _unmount(tester);
    });

    testWidgets('hides the button and skips configuring when unsupported',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _FakePictureInPicture pictureInPicture =
          _FakePictureInPicture(supported: false);
      await _pumpPlayer(
        tester,
        harness: _Harness(),
        pictureInPicture: pictureInPicture,
      );

      expect(find.byIcon(Icons.picture_in_picture_alt_rounded), findsNothing);
      expect(pictureInPicture.configs, isEmpty);

      await _unmount(tester);
    });

    testWidgets('remote actions toggle playback and play the next episode',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness();
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );
      final NativePlayerCubit cubit = harness.cubit!;
      expect(cubit.state.isPlaying, isTrue);

      pictureInPicture.actionController
          .add(PictureInPictureAction.togglePlayback);
      await tester.pump();
      expect(cubit.state.isPlaying, isFalse);
      expect(pictureInPicture.configs.last.playing, isFalse);

      pictureInPicture.actionController
          .add(PictureInPictureAction.togglePlayback);
      await tester.pump();
      expect(cubit.state.isPlaying, isTrue);

      pictureInPicture.actionController
          .add(PictureInPictureAction.nextEpisode);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(harness.resolvedUids, <String>['e2']);
      expect(cubit.state.playlist.current.uid, 'e2');
      expect(pictureInPicture.configs.last.hasNext, isFalse);

      await _unmount(tester);
    });

    testWidgets('holds a web player request until picture-in-picture ends',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(webOnlyUids: <String>{'e2'});
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      final _PlayerRouteOutcome outcome = await _pumpPlayerRoute(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );
      final NativePlayerCubit cubit = harness.cubit!;
      final _FakeEngine firstEngine = harness.engines.single;

      pictureInPicture.mode.value = true;
      await tester.pump();
      pictureInPicture.actionController
          .add(PictureInPictureAction.nextEpisode);
      await _pumpFrames(tester, 4);

      expect(harness.resolvedUids, <String>['e2']);
      expect(cubit.state.webPlayerRequest, isNotNull);
      expect(cubit.state.isPlaying, isFalse);
      expect(firstEngine.value.isPlaying, isFalse);
      expect(find.byType(NativePlayer), findsOneWidget);
      expect(outcome.finished, isFalse);
      expect(pictureInPicture.disableCalls, 0);

      pictureInPicture.mode.value = false;
      await tester.pumpAndSettle();

      expect(outcome.finished, isTrue);
      final Object? result = outcome.result;
      expect(result, isA<OpenInWebPlayer>());
      expect((result! as OpenInWebPlayer).position.current.uid, 'e2');
      expect(find.byType(NativePlayer), findsNothing);
      expect(pictureInPicture.disableCalls, 1);

      await _unmount(tester);
    });

    testWidgets('a broken download in picture-in-picture streams once it ends',
        (WidgetTester tester) async {
      _recordSystemUi();
      addTearDown(() => LocalPlaybackFailures.shared.forget('e1'));
      final _Harness harness = _Harness(brokenLocalFile: true);
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      pictureInPicture.mode.value = true;
      final _DownloadScope downloads = _DownloadScope();
      final _PlayerRouteOutcome outcome = await _pumpPlayerRoute(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
        downloads: downloads,
      );

      expect(harness.cubit!.state.status, NativePlayerStatus.error);
      expect(outcome.finished, isFalse);
      expect(LocalPlaybackFailures.shared.hasFailed('e1'), isFalse);

      pictureInPicture.mode.value = false;
      await tester.pumpAndSettle();

      expect(outcome.finished, isTrue);
      expect(outcome.result, isA<PlayEpisodeRequested>());
      expect(LocalPlaybackFailures.shared.hasFailed('e1'), isTrue);

      await _unmount(tester);
    });

    testWidgets('a sign-in source error offers sign-in and retries after it',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(
        sourceErrors: const <String, SourceError>{
          'e2': SourceError(SourceErrorKind.loginRequired),
        },
      );
      int signIns = 0;
      await _pumpPlayer(
        tester,
        harness: harness,
        pictureInPicture: _FakePictureInPicture(),
        signIn: (BuildContext context, VoidCallback onSignedIn) async {
          signIns++;
          onSignedIn();
        },
      );

      unawaited(harness.cubit!.playNext());
      await _pumpFrames(tester, 4);

      expect(
        find.text(strings.source_error_login_required_title('AnimeSite')),
        findsOneWidget,
      );
      expect(find.text(strings.source_error_sign_in_button), findsOneWidget);
      expect(find.text(strings.common_go_back), findsOneWidget);

      await tester.tap(find.text(strings.source_error_sign_in_button));
      await _pumpFrames(tester, 4);

      expect(signIns, 1);
      expect(harness.resolvedUids, <String>['e2', 'e2']);

      await _unmount(tester);
    });

    testWidgets('outside picture-in-picture a web player request leaves at once',
        (WidgetTester tester) async {
      _recordSystemUi();
      final _Harness harness = _Harness(webOnlyUids: <String>{'e2'});
      final _FakePictureInPicture pictureInPicture = _FakePictureInPicture();
      final _PlayerRouteOutcome outcome = await _pumpPlayerRoute(
        tester,
        harness: harness,
        pictureInPicture: pictureInPicture,
      );

      unawaited(harness.cubit!.playNext());
      await tester.pumpAndSettle();

      expect(outcome.finished, isTrue);
      expect(outcome.result, isA<OpenInWebPlayer>());
      expect(find.byType(NativePlayer), findsNothing);

      await _unmount(tester);
    });
  });

  group('MethodChannelPictureInPicture', () {
    const MethodChannel channel = MethodChannel(kPictureInPictureChannel);

    test('sends the config and forwards mode changes and actions', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final List<MethodCall> sent = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        sent.add(call);
        if (call.method == 'isSupported' || call.method == 'enter') {
          return true;
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final MethodChannelPictureInPicture pictureInPicture =
          MethodChannelPictureInPicture();
      final List<PictureInPictureAction> actions = <PictureInPictureAction>[];
      final StreamSubscription<PictureInPictureAction> subscription =
          pictureInPicture.actions.listen(actions.add);

      expect(await pictureInPicture.isSupported(), isTrue);
      await pictureInPicture.configure(
        const PictureInPictureConfig(
          autoEnter: true,
          aspectWidth: 16,
          aspectHeight: 9,
          playing: true,
          hasNext: false,
          toggleTitle: 'Pause',
          nextTitle: 'Next episode',
        ),
      );
      expect(await pictureInPicture.enter(), isTrue);
      await pictureInPicture.disable();

      expect(
        sent.map((MethodCall call) => call.method),
        <String>['isSupported', 'configure', 'enter', 'disable'],
      );
      expect(sent[1].arguments, <String, Object>{
        'autoEnter': true,
        'aspectWidth': 16,
        'aspectHeight': 9,
        'playing': true,
        'hasNext': false,
        'toggleTitle': 'Pause',
        'nextTitle': 'Next episode',
      });

      await _deliver(messenger, const MethodCall('pipModeChanged', true));
      expect(pictureInPicture.inPictureInPicture.value, isTrue);
      await _deliver(messenger, const MethodCall('pipAction', 'toggle'));
      await _deliver(messenger, const MethodCall('pipAction', 'next'));
      await _deliver(messenger, const MethodCall('pipAction', 'unknown'));
      await _deliver(messenger, const MethodCall('pipModeChanged', false));
      await Future<void>.delayed(Duration.zero);

      expect(actions, <PictureInPictureAction>[
        PictureInPictureAction.togglePlayback,
        PictureInPictureAction.nextEpisode,
      ]);
      expect(pictureInPicture.inPictureInPicture.value, isFalse);

      await subscription.cancel();
      pictureInPicture.dispose();
    });
  });
}

Future<void> _deliver(
  TestDefaultBinaryMessenger messenger,
  MethodCall call,
) async {
  await messenger.handlePlatformMessage(
    kPictureInPictureChannel,
    const StandardMethodCodec().encodeMethodCall(call),
    (ByteData? reply) {},
  );
}
