import 'dart:async';

import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/blocs/novel_reader_preferences/novel_reader_preferences_cubit.dart';
import 'package:wakaranai/blocs/reader_preferences/reader_preferences_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/shared_pref/novel_reader_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/services/device/volume_key_events.dart';
import 'package:wakaranai/services/novels/novel_progress.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_controls.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_controls.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_cubit.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_settings_sheet.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader_theme.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/source_error_description.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NovelReaderData {
  final NovelApiClient apiClient;
  final ConfigInfo configInfo;
  final String concreteUid;
  final List<Chapter> chapters;
  final Chapter chapter;
  final double initialFraction;

  const NovelReaderData({
    required this.apiClient,
    required this.configInfo,
    required this.concreteUid,
    required this.chapters,
    required this.chapter,
    this.initialFraction = 0,
  });
}

class NovelReader extends StatefulWidget {
  const NovelReader({super.key, required this.data});

  final NovelReaderData data;

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  static const double _volumeKeyViewportShare = 0.9;
  static const Duration _volumeKeyScrollDuration = Duration(milliseconds: 250);

  late final NovelReaderCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<ReaderPreferences>? _readerPreferencesSubscription;
  StreamSubscription<NovelReaderPreferences>? _novelPreferencesSubscription;
  StreamSubscription<VolumeKey>? _volumeKeySubscription;

  late ReaderPreferences _readerPreferences;
  bool _controlsVisible = true;
  bool _restoring = false;
  String? _shownChapterUid;
  bool? _wakelockEnabled;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _cubit = NovelReaderCubit.forClient(
      client: widget.data.apiClient,
      concreteUid: widget.data.concreteUid,
      chapters: widget.data.chapters,
      chapterActivityRepository: context.read<ChapterActivityRepository>(),
      concreteDataRepository: context.read<ConcreteDataRepository>(),
      downloadRepository: context.read<DownloadRepository>(),
    );
    _listenToPreferences();
    unawaited(_cubit.open(
      widget.data.chapter,
      initialFraction: widget.data.initialFraction,
    ));
  }

  void _listenToPreferences() {
    final ReaderPreferencesCubit readerPreferences =
        context.read<ReaderPreferencesCubit>();
    _readerPreferences = readerPreferences.state;
    _readerPreferencesSubscription =
        readerPreferences.stream.listen((ReaderPreferences updated) {
      _readerPreferences = updated;
      unawaited(VolumeKeyEvents.setIntercepting(updated.volumeKeys));
    });
    unawaited(VolumeKeyEvents.setIntercepting(_readerPreferences.volumeKeys));
    _volumeKeySubscription = VolumeKeyEvents.keys.listen(_onVolumeKey);

    final NovelReaderPreferencesCubit novelPreferences =
        context.read<NovelReaderPreferencesCubit>();
    _applyWakelock(novelPreferences.state.keepScreenOn);
    _novelPreferencesSubscription = novelPreferences.stream.listen(
      (NovelReaderPreferences updated) =>
          _applyWakelock(updated.keepScreenOn),
    );
  }

  void _applyWakelock(bool keepScreenOn) {
    if (_wakelockEnabled == keepScreenOn) {
      return;
    }
    _wakelockEnabled = keepScreenOn;
    if (keepScreenOn) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  void _onVolumeKey(VolumeKey key) {
    final bool down = key == VolumeKey.down;
    final bool forward = down != _readerPreferences.invertVolumeKeys;
    _scrollByViewport(forward: forward);
  }

  void _scrollByViewport({required bool forward}) {
    if (!_scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    final double distance =
        position.viewportDimension * _volumeKeyViewportShare;
    final double target = forward
        ? position.pixels + distance
        : position.pixels - distance;
    unawaited(_scrollController.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: _volumeKeyScrollDuration,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    unawaited(VolumeKeyEvents.setIntercepting(false));
    unawaited(_readerPreferencesSubscription?.cancel());
    unawaited(_novelPreferencesSubscription?.cancel());
    unawaited(_volumeKeySubscription?.cancel());
    unawaited(_cubit.close());
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  void _onStateChanged(BuildContext context, NovelReaderState state) {
    if (state is! NovelReaderLoaded) {
      return;
    }
    if (state.chapter.uid == _shownChapterUid) {
      return;
    }
    _shownChapterUid = state.chapter.uid;
    unawaited(
      context.read<LibraryUpdatesCubit>().markSeenIfNew(state.chapter.uid),
    );
    _restoreScroll(state);
  }

  void _restoreScroll(NovelReaderLoaded state) {
    _restoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToFraction(state.initialFraction);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToFraction(state.initialFraction);
        _restoring = false;
        _recordFittingChapter(state);
      });
    });
  }

  void _jumpToFraction(double fraction) {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    _scrollController.jumpTo(
      (position.maxScrollExtent * NovelProgress.clampFraction(fraction))
          .clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  void _recordFittingChapter(NovelReaderLoaded state) {
    if (!mounted || !_scrollController.hasClients || state.isEmpty) {
      return;
    }
    if (_scrollController.position.maxScrollExtent <= 0) {
      _cubit.recordProgress(1);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_restoring || notification.depth != 0) {
      return false;
    }
    if (notification is UserScrollNotification && _controlsVisible) {
      setState(() => _controlsVisible = false);
    }
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      final ScrollMetrics metrics = notification.metrics;
      _cubit.recordProgress(NovelProgress.scrollFraction(
        offset: metrics.pixels,
        maxExtent: metrics.maxScrollExtent,
      ));
    }
    return false;
  }

  void _seekTo(double fraction) {
    _jumpToFraction(fraction);
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NovelReaderCubit>.value(
      value: _cubit,
      child: BlocBuilder<NovelReaderPreferencesCubit, NovelReaderPreferences>(
        builder: (BuildContext context, NovelReaderPreferences preferences) {
          final NovelReaderColors colors =
              NovelReaderColors.of(preferences.background);
          return Scaffold(
            backgroundColor: colors.background,
            body: BlocConsumer<NovelReaderCubit, NovelReaderState>(
              listener: _onStateChanged,
              builder: (BuildContext context, NovelReaderState state) =>
                  _buildState(context, state, preferences, colors),
            ),
          );
        },
      ),
    );
  }

  Widget _buildState(
    BuildContext context,
    NovelReaderState state,
    NovelReaderPreferences preferences,
    NovelReaderColors colors,
  ) {
    switch (state) {
      case NovelReaderLoaded():
        return _buildLoaded(context, state, preferences, colors);
      case NovelReaderError():
        return _buildError(context, state);
      case NovelReaderLoading():
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
    }
  }

  Widget _buildLoaded(
    BuildContext context,
    NovelReaderLoaded state,
    NovelReaderPreferences preferences,
    NovelReaderColors colors,
  ) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleControls,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: _buildText(context, state, preferences, colors),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _controlsVisible
                ? _buildControls(context, state)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildText(
    BuildContext context,
    NovelReaderLoaded state,
    NovelReaderPreferences preferences,
    NovelReaderColors colors,
  ) {
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final TextStyle textStyle = novelReaderTextStyle(preferences);
    return SingleChildScrollView(
      key: ValueKey<String>(state.chapter.uid),
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        preferences.horizontalMargin,
        safePadding.top + 24,
        preferences.horizontalMargin,
        safePadding.bottom + 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            state.chapter.title.trim(),
            style: textStyle.copyWith(
              fontSize: preferences.fontSize + 4,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          if (state.isEmpty)
            Text(
              S.current.novel_reader_empty_chapter,
              style: textStyle.copyWith(color: colors.text.withValues(alpha: 0.6)),
            )
          else
            HtmlWidget(
              state.html,
              textStyle: textStyle,
              buildAsync: false,
              rebuildTriggers: <Object>[preferences.justify],
              customStylesBuilder: (element) => novelReaderElementStyles(
                element.localName ?? '',
                justify: preferences.justify,
              ),
              onTapUrl: (String url) => true,
            ),
          if (state.next != null) ...<Widget>[
            const SizedBox(height: 32),
            NovelNextChapterButton(
              title: state.next!.title,
              onTap: () => unawaited(_cubit.openNext()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, NovelReaderLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          onTap: _toggleControls,
          child: ReaderTopBar(title: state.chapter.title),
        ),
        const Spacer(),
        NovelReaderBottomBar(
          fraction: state.fraction,
          hasPrevious: state.previous != null,
          hasNext: state.next != null,
          onSeek: _seekTo,
          onPrevious: () => unawaited(_cubit.openPrevious()),
          onNext: () => unawaited(_cubit.openNext()),
          onSettings: () => unawaited(showNovelReaderSettings(context)),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, NovelReaderError state) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: _buildErrorMessage(context, state)),
        Positioned(
          left: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ReaderRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, NovelReaderError state) {
    final SourceErrorDescription? description = describeSourceErrorFor(
      state.error,
      widget.data.configInfo,
    );
    if (description == null) {
      return ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.concrete_viewer_error_title,
        message: state.error.toString(),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => unawaited(_cubit.retry()),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              S.current.concrete_viewer_retry_button,
              style: semibold(size: 15, color: AppColors.mainBlack),
            ),
          ),
        ],
      );
    }
    return SourceErrorView(
      description: description,
      onRetry: () => unawaited(_cubit.retry()),
      onSignIn: () => unawaited(
        signInToSource(
          context,
          apiClient: widget.data.apiClient,
          configInfo: widget.data.configInfo,
          onSignedIn: () => unawaited(_cubit.retry()),
        ),
      ),
    );
  }
}
