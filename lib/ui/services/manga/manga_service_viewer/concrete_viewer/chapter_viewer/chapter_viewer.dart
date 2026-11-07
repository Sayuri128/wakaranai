import 'dart:async';
import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/repositories/shared_pref/title_translation_languages_repository.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_service.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/utils/page_image.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_divider.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translated_page.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_languages_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_models_sheet.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/bottom_modal_settings.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_glossary_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/source_error_description.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_controls.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_horizontal_gestures.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_translation_overlays.dart';

part 'chapter_viewer_selection.dart';
part 'chapter_viewer_slider.dart';
part 'chapter_viewer_strip.dart';
part 'chapter_viewer_translation.dart';

class ChapterViewerData {
  final MangaApiClient apiClient;
  final ConfigInfo configInfo;
  final ConcreteView<ChaptersGroup> concreteView;
  final ChaptersGroup group;
  final Chapter chapter;
  final int initialPage;

  const ChapterViewerData({
    required this.apiClient,
    required this.configInfo,
    required this.group,
    required this.concreteView,
    required this.chapter,
    this.initialPage = 1,
  });
}

class ChapterViewer extends StatefulWidget {
  const ChapterViewer({super.key, required this.data});

  final ChapterViewerData data;

  @override
  State<ChapterViewer> createState() => _ChapterViewerState();
}

class _ChapterViewerState extends State<ChapterViewer>
    with
        TickerProviderStateMixin,
        _ReaderRegionSelection,
        _ReaderTranslationControl,
        _ReaderStripNavigation,
        _ReaderSliderControl {
  final GlobalKey _scaffoldKey = GlobalKey();

  @override
  late final ChapterViewCubit _chapterViewCubit;

  @override
  late final PageController _pageController;

  @override
  late final ItemScrollController _itemScrollController;

  @override
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _initialized = false;

  ChapterViewMode? _lastMode;
  int _lastPage = -1;
  String? _lastChapterUid;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener.itemPositions.addListener(
      _onWebtoonPositionsChanged,
    );
    _sliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(WakelockPlus.enable());

    _setUpTranslation();

    _chapterViewCubit =
        ChapterViewCubit(
          apiClient: widget.data.apiClient,
          initialPage: widget.data.initialPage,
          settingsCubit: context.read<SettingsCubit>(),
          pageController: _pageController,
          itemScrollController: _itemScrollController,
          chapterActivityRepository: context.read<ChapterActivityRepository>(),
          concreteDataRepository: context.read<ConcreteDataRepository>(),
          downloadRepository: context.read<DownloadRepository>(),
        );
    _openChapter();
  }

  void _openChapter() {
    if (!mounted || _chapterViewCubit.isClosed) {
      return;
    }
    unawaited(_chapterViewCubit.init(
      widget.data,
      pagesLoaded: (int current, int total) {
        final ChapterViewState state = _chapterViewCubit.state;
        if (state is ChapterViewInitialized) {
          _prefetchAround(state, current - 1);
        }
        if (mounted) {
          setState(() {});
        }
      },
    ));
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    _itemPositionsListener.itemPositions.removeListener(
      _onWebtoonPositionsChanged,
    );
    _chapterViewCubit.close();
    _translationCubit?.close();
    _sliderController.dispose();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chapterViewCubit,
      child: Scaffold(
        key: _scaffoldKey,
        body: _translationCubit == null
            ? _buildPage()
            : BlocListener<PageTranslationCubit, PageTranslationState>(
                bloc: _translationCubit,
                listenWhen: _translationPhaseChanged,
                listener: _onTranslationPhase,
                child: _buildPage(),
              ),
        backgroundColor: AppColors.mainBlack,
      ),
    );
  }

  Widget _buildPage() {
    return BlocConsumer<ChapterViewCubit, ChapterViewState>(
      listenWhen: (ChapterViewState previous, ChapterViewState current) {
        if (_chapterPrepended(previous, current)) {
          _keepPositionAfterPrepend(current as ChapterViewInitialized);
        }
        return current is ChapterViewInitialized &&
            (!_initialized ||
                (previous is ChapterViewInitialized &&
                    (current.mode != previous.mode ||
                        current.currentPage != previous.currentPage ||
                        current.currentPages.chapterUid !=
                            previous.currentPages.chapterUid)));
      },
      listener: (BuildContext context, ChapterViewState state) {
        if (state is ChapterViewInitialized) {
          final bool isInit = !_initialized;
          final bool modeChanged = _lastMode != null && state.mode != _lastMode;
          final bool chapterChanged =
              _lastChapterUid != null &&
              state.currentPages.chapterUid != _lastChapterUid;
          _initialized = true;

          if (isInit || modeChanged) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state.mode == ChapterViewMode.webtoon) {
                _itemScrollController.jumpTo(
                  index: _stripIndexOfCurrentPage(state, state.currentPage),
                );
              } else {
                final int index = _stripIndexOfCurrentPage(
                  state,
                  state.currentPage,
                );
                _pageController.jumpToPage(index);
                _onPagedIndexChanged(index);
              }
            });
            _animateSliderTo(state, animate: false);
          } else if (chapterChanged) {
            _animateSliderTo(state, animate: false);
          } else if (state.currentPage != _lastPage) {
            _animateSliderTo(state, animate: _seekOverride == null);
          }

          if (state.currentPages.chapterUid != _lastChapterUid) {
            unawaited(
              context.read<LibraryUpdatesCubit>().markSeenIfNew(
                state.currentPages.chapterUid,
              ),
            );
          }
          _lastMode = state.mode;
          _lastPage = state.currentPage;
          _lastChapterUid = state.currentPages.chapterUid;
        }
      },
      builder: (BuildContext context, ChapterViewState state) {
        if (state is ChapterViewInitialized) {
          return Stack(
            key: _readerStackKey,
            children: <Widget>[
              _buildBackground(context),
              _buildViewer(context, state),
              _buildSelectionOverlay(),
              if (state.mode != ChapterViewMode.webtoon)
                ReaderHorizontalGestures(
                  mode: state.mode,
                  controlsEnabled: state.controlsEnabled,
                  pageController: _pageController,
                ),
              _buildControls(context, state),
              ReaderPageCounter(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                controlsVisible: state.controlsVisible,
              ),
              ReaderTranslationStatus(
                cubit: _translationCubit,
                state: state,
                usesGemma: _usesGemma,
              ),
              ReaderPeekButton(cubit: _translationCubit, state: state),
            ],
          );
        } else if (state is ChapterViewError) {
          return Stack(
            children: <Widget>[
              _buildErrorMessage(context, state),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ReaderRoundButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
      },
    );
  }

  Widget _buildErrorMessage(BuildContext context, ChapterViewError state) {
    final SourceErrorDescription? description = describeSourceErrorFor(
      state.error,
      widget.data.configInfo,
    );
    if (description == null) {
      return ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.concrete_viewer_error_title,
        message: state.message,
      );
    }
    return SourceErrorView(
      description: description,
      onRetry: _openChapter,
      onSignIn: () => unawaited(
        signInToSource(
          context,
          apiClient: widget.data.apiClient,
          configInfo: widget.data.configInfo,
          onSignedIn: _openChapter,
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, ChapterViewInitialized state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: state.controlsVisible
          ? _buildControlsView(context, state)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildControlsView(
    BuildContext context,
    ChapterViewInitialized state,
  ) {
    final String title = state.group.elements
        .firstWhere(
          (Chapter element) => element.uid == state.currentPages.chapterUid,
        )
        .title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ReaderTopBar(title: title),
        const Spacer(),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ChapterViewInitialized state) {
    final PageTranslationCubit? translationCubit = _translationCubit;
    return ReaderBottomBar(
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      slider: _buildSlider(context, state),
      translateButton: translationCubit == null
          ? null
          : ReaderTranslateButton(cubit: translationCubit),
      onSettings: () => _showBottomSheetSettings(context, state),
    );
  }

  void _showBottomSheetSettings(
    BuildContext context,
    ChapterViewInitialized state,
  ) {
    final PageTranslationCubit? translation = _translationCubit;
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BottomModalSettings(
        chapterViewCubit: context.read<ChapterViewCubit>(),
        state: state,
        translationLanguages: translation == null
            ? null
            : translation.state.languages ?? _defaultTranslationLanguages(),
        onEditTranslationLanguages: translation == null
            ? null
            : _editTranslationLanguages,
        onTranslateWholeChapter: translation == null
            ? null
            : _translateWholeChapter,
        onEditGlossary: translation == null ? null : _editGlossary,
      ),
    );
  }

  Widget _buildViewer(BuildContext context, ChapterViewInitialized state) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        if (_openBubbleAt(details.globalPosition)) {
          return;
        }
        context.read<ChapterViewCubit>().onChangeVisibility();
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_openBubbleAt(details.globalPosition, longPress: true)) {
          return;
        }
        if (_startSelection(details.globalPosition)) {
          return;
        }
        _showSaveImageSheet(state);
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        _updateSelection(details.globalPosition);
      },
      onLongPressEnd: (LongPressEndDetails details) async {
        if (_selectionStart == null) {
          return;
        }
        final bool handled = await _finishSelection();
        if (!handled) {
          _showSaveImageSheet(state);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: _buildPageViewerPage(state, context),
    );
  }

  void _showSaveImageSheet(ChapterViewInitialized state) {
    if (state.currentPages.value.isEmpty) {
      return;
    }
    final int index = (state.currentPage - 1).clamp(
      0,
      state.currentPages.value.length - 1,
    );
    showSaveImageSheet(
      context,
      url: state.currentPages.value[index],
      headers: state.headers,
    );
  }

  Container _buildBackground(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
    );
  }
}
