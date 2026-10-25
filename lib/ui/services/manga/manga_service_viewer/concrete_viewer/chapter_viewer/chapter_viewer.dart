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
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translated_page.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_languages_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_models_sheet.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/bottom_modal_settings.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_glossary_sheet.dart';
import 'package:wakaranai/ui/widgets/download_estimate_text.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

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
    with TickerProviderStateMixin {
  final GlobalKey _scaffoldKey = GlobalKey();

  final Map<String, Size> _pageSizes = <String, Size>{};

  late final ChapterViewCubit _chapterViewCubit;
  PageTranslationCubit? _translationCubit;
  OnDeviceModel? _gemmaVariant;
  bool _usesDeepL = false;

  bool get _usesGemma => _gemmaVariant != null;
  bool _pendingWholeChapter = false;
  final Map<String, GlobalKey<TranslatedPageState>> _translatedPageKeys =
      <String, GlobalKey<TranslatedPageState>>{};

  GlobalKey<TranslatedPageState> _translatedPageKey(String path) {
    return _translatedPageKeys.putIfAbsent(
      path,
      GlobalKey<TranslatedPageState>.new,
    );
  }

  final GlobalKey _readerStackKey = GlobalKey();
  Offset? _selectionStart;
  Rect? _selection;
  TranslatedPageState? _selectionPage;

  TranslatedPageState? _pageForRegionAt(Offset globalPosition) {
    for (final GlobalKey<TranslatedPageState> key
        in _translatedPageKeys.values) {
      final TranslatedPageState? page = key.currentState;
      if (page != null && page.canSelectRegionAt(globalPosition)) {
        return page;
      }
    }
    return null;
  }

  bool _startSelection(Offset globalPosition) {
    final TranslatedPageState? page = _pageForRegionAt(globalPosition);
    if (page == null) {
      return false;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectionPage = page;
      _selectionStart = globalPosition;
      _selection = Rect.fromPoints(globalPosition, globalPosition);
    });
    return true;
  }

  void _updateSelection(Offset globalPosition) {
    final Offset? start = _selectionStart;
    if (start == null) {
      return;
    }
    setState(() => _selection = Rect.fromPoints(start, globalPosition));
  }

  Future<bool> _finishSelection() async {
    final Rect? selection = _selection;
    final TranslatedPageState? page = _selectionPage;
    setState(() {
      _selectionStart = null;
      _selection = null;
      _selectionPage = null;
    });
    if (selection == null ||
        page == null ||
        !page.mounted ||
        selection.shortestSide < _minSelectionSide) {
      return false;
    }
    final bool translated = await page.translateScreenRegion(selection);
    if (!translated && mounted) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.page_translation_region_empty,
      );
    }
    return true;
  }

  Widget _buildSelectionOverlay() {
    final Rect? selection = _selection;
    final RenderObject? stack = _readerStackKey.currentContext
        ?.findRenderObject();
    if (selection == null || stack is! RenderBox) {
      return const SizedBox.shrink();
    }
    final Rect local = Rect.fromPoints(
      stack.globalToLocal(selection.topLeft),
      stack.globalToLocal(selection.bottomRight),
    );
    return Positioned.fromRect(
      rect: local,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  bool _openBubbleAt(Offset globalPosition, {bool longPress = false}) {
    for (final GlobalKey<TranslatedPageState> key
        in _translatedPageKeys.values) {
      final TranslatedPageState? page = key.currentState;
      if (page != null &&
          page.openBubbleAt(globalPosition, longPress: longPress)) {
        return true;
      }
    }
    return false;
  }

  late final PageController _pageController;
  late final ItemScrollController _itemScrollController;

  final bool _showGestureOverlay = false;

  bool _canLoadNext = false;
  bool _canLoadPrevious = false;
  bool _autoAdvancing = false;

  bool _initialized = false;

  late final AnimationController _sliderController;
  double _sliderFrom = 1;
  double _sliderTarget = 1;
  double? _seekOverride;
  ChapterViewMode? _lastMode;
  int _lastPage = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _itemScrollController = ItemScrollController();
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
        )..init(
          widget.data,
          pagesLoaded: (int current, int total) {
            _canLoadNext = current == total;
            _canLoadPrevious = current == 1;
            final ChapterViewState state = _chapterViewCubit.state;
            if (state is ChapterViewInitialized) {
              _prefetchAround(state, current - 1);
            }
            if (mounted) {
              setState(() {});
            }
          },
        );
  }

  void _setUpTranslation() {
    final OnDeviceModelCubit gemma = context.read<OnDeviceModelCubit>();
    final PageTranslationSettings settings = effectiveTranslationSettings(
      context.read<PageTranslationSettingsCubit>().state,
      gemma.state,
    );
    _gemmaVariant = onDeviceModelOf(settings);
    _usesDeepL = usesDeepL(settings);
    if (!settings.enabled) {
      return;
    }

    final PageTranslationRepository translationRepository = context
        .read<PageTranslationRepository>();
    final LanguagePacksCubit languagePacks = context.read<LanguagePacksCubit>();
    final TitleTranslationLanguagesRepository languagesRepository =
        TitleTranslationLanguagesRepository();
    final String extensionUid = widget.data.configInfo.uid;
    final String concreteUid = widget.data.concreteView.uid;

    final PageTranslationCubit cubit = PageTranslationCubit(
      backendFactory: (TitleLanguages languages) => PageTranslationService(
        repository: translationRepository,
        settings: settings,
        languages: languages,
      ),
      ensurePacks: (TitleLanguages languages) => ensureTranslationReady(
        settings: settings,
        packs: languagePacks,
        gemma: gemma,
        languages: languages,
      ),
      onLanguagesChanged: (TitleLanguages languages) =>
          languagesRepository.set(extensionUid, concreteUid, languages),
    );
    _translationCubit = cubit;
    unawaited(_restoreSavedLanguages(languagesRepository, cubit));
  }

  Future<void> _restoreSavedLanguages(
    TitleTranslationLanguagesRepository repository,
    PageTranslationCubit cubit,
  ) async {
    final TitleLanguages? saved = await repository.get(
      widget.data.configInfo.uid,
      widget.data.concreteView.uid,
    );
    if (saved != null) {
      cubit.restoreLanguages(saved);
    }
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
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

  bool _translationPhaseChanged(
    PageTranslationState previous,
    PageTranslationState current,
  ) {
    return previous.phase != current.phase ||
        previous.downloadFailed != current.downloadFailed;
  }

  Future<void> _onTranslationPhase(
    BuildContext context,
    PageTranslationState translation,
  ) async {
    final PageTranslationCubit cubit = _translationCubit!;
    if (translation.downloadFailed) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.page_translation_models_failed,
      );
    }
    switch (translation.phase) {
      case PageTranslationPhase.active:
        _onTranslationActive();
        break;
      case PageTranslationPhase.choosingLanguages:
        await _askForLanguages(context, cubit);
        break;
      case PageTranslationPhase.needsModels:
        await _askToDownloadModels(context, cubit, translation.languages!);
        break;
      case PageTranslationPhase.off:
        _pendingWholeChapter = false;
        break;
      case PageTranslationPhase.preparing:
      case PageTranslationPhase.downloading:
        break;
    }
  }

  void _onTranslationActive() {
    final ChapterViewState state = _chapterViewCubit.state;
    if (state is ChapterViewInitialized) {
      _requestTranslations(state, state.currentPage - 1);
    }
    if (_pendingWholeChapter) {
      _pendingWholeChapter = false;
      _translateWholeChapter();
    }
  }

  Future<void> _askForLanguages(
    BuildContext context,
    PageTranslationCubit cubit,
  ) async {
    final TitleLanguages? chosen = await showTranslationLanguagesSheet(
      context,
      initial: _defaultTranslationLanguages(),
      confirmLabel: S.current.page_translation_languages_start,
    );
    if (chosen != null) {
      await cubit.setLanguages(chosen);
    } else {
      cubit.dismissPrompt();
    }
  }

  Future<void> _askToDownloadModels(
    BuildContext context,
    PageTranslationCubit cubit,
    TitleLanguages languages,
  ) async {
    if (_usesDeepL) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.deepl_key_needed,
      );
      cubit.dismissPrompt();
      return;
    }
    final bool confirmed = await showTranslationModelsSheet(
      context,
      languages: languages,
      wifiOnly: context.read<PageTranslationSettingsCubit>().state.wifiOnly,
      gemma: _gemmaVariant,
    );
    if (confirmed) {
      await cubit.downloadModels();
    } else {
      cubit.dismissPrompt();
    }
  }

  TitleLanguages _defaultTranslationLanguages() {
    return TitleLanguages(
      source:
          PageLanguage.sourceForExtension(widget.data.configInfo.language) ??
          PageLanguage.japanese,
      target: context.read<PageTranslationSettingsCubit>().state.target,
    );
  }

  Future<void> _editTranslationLanguages() async {
    final PageTranslationCubit? cubit = _translationCubit;
    if (cubit == null) {
      return;
    }
    final TitleLanguages? chosen = await showTranslationLanguagesSheet(
      context,
      initial: cubit.state.languages ?? _defaultTranslationLanguages(),
      confirmLabel: S.current.page_translation_languages_save,
    );
    if (chosen != null) {
      await cubit.setLanguages(chosen);
    }
  }

  Future<void> _editGlossary() async {
    final PageTranslationCubit? cubit = _translationCubit;
    if (cubit == null) {
      return;
    }
    final TitleLanguages languages =
        cubit.state.languages ?? _defaultTranslationLanguages();
    final GlossaryEdit? edit = await showTranslationGlossarySheet(
      context,
      languages: languages,
      engineSupportsGlossary: _usesGemma || _usesDeepL,
    );
    if (edit == null) {
      return;
    }
    await cubit.setLanguages(languages.copyWith(glossary: edit.glossary));
    final ChapterViewState state = _chapterViewCubit.state;
    if (!edit.retranslate || state is! ChapterViewInitialized) {
      return;
    }
    if (!cubit.state.active) {
      await cubit.toggle();
    }
    cubit.retranslatePages(state.currentPages.value, state.headers);
  }

  void _translateWholeChapter() {
    final PageTranslationCubit? cubit = _translationCubit;
    final ChapterViewState state = _chapterViewCubit.state;
    if (cubit == null || state is! ChapterViewInitialized) {
      return;
    }
    if (!cubit.state.active) {
      _pendingWholeChapter = true;
      if (cubit.state.phase == PageTranslationPhase.off) {
        unawaited(cubit.toggle());
      }
      return;
    }
    cubit.requestAll(state.currentPages.value, state.headers);
  }

  void _requestTranslations(ChapterViewInitialized state, int index) {
    final PageTranslationCubit? cubit = _translationCubit;
    final List<String> pages = state.currentPages.value;
    if (cubit == null || !cubit.state.active || pages.isEmpty) {
      return;
    }

    final int first = index.clamp(0, pages.length - 1);
    final int last = min(pages.length - 1, first + _translateAhead);
    cubit.request(pages.sublist(first, last + 1), state.headers);
  }

  String? _currentPagePath(ChapterViewInitialized state) {
    final List<String> pages = state.currentPages.value;
    if (pages.isEmpty) {
      return null;
    }
    final int index = (state.currentPage - 1).clamp(0, pages.length - 1);
    return pages[index];
  }

  Widget _buildTranslationStatus(
    BuildContext context,
    ChapterViewInitialized state,
  ) {
    final PageTranslationCubit? cubit = _translationCubit;
    final String? path = _currentPagePath(state);
    if (cubit == null || path == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: cubit,
      builder: (BuildContext context, PageTranslationState translation) {
        final _StatusPillContent? content = _statusPillContent(
          context,
          cubit,
          translation,
          path,
          state,
        );
        final bool visible = content != null;
        final VoidCallback? onTap = content?.onTap;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: 16,
          bottom:
              MediaQuery.of(context).padding.bottom +
              (state.controlsVisible ? 136 : 56),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visible ? 1 : 0,
            child: IgnorePointer(
              ignoring: onTap == null,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildStatusIcon(content?.icon),
                      const SizedBox(width: 8),
                      Text(
                        content?.label ?? '',
                        style: medium(size: 12, color: AppColors.onMedia),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(IconData? icon) {
    if (icon != null) {
      return Icon(icon, size: 16, color: AppColors.onMedia);
    }
    return SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary,
      ),
    );
  }

  _StatusPillContent? _statusPillContent(
    BuildContext context,
    PageTranslationCubit cubit,
    PageTranslationState translation,
    String path,
    ChapterViewInitialized state,
  ) {
    if (translation.phase == PageTranslationPhase.downloading) {
      return _StatusPillContent(label: _modelDownloadLabel(context));
    }
    if (translation.phase == PageTranslationPhase.preparing) {
      return _StatusPillContent(
        label: S.current.page_translation_status_preparing,
      );
    }
    if (!translation.active) {
      return null;
    }

    final PageTranslationStatus? status = translation.entry(path)?.status;
    if (status == PageTranslationStatus.failed) {
      return _StatusPillContent(
        label: S.current.page_translation_status_failed,
        icon: Icons.refresh_rounded,
        onTap: () => cubit.retry(path),
      );
    }
    if (status == PageTranslationStatus.modelPending) {
      return _StatusPillContent(
        label: S.current.page_translation_status_model_pending,
      );
    }
    final bool pageBusy =
        status == PageTranslationStatus.queued ||
        status == PageTranslationStatus.running;
    if (translation.translatingChapter && !pageBusy) {
      return _StatusPillContent(
        label: S.current.page_translation_status_chapter(
          translation.pinnedDone,
          translation.pinned.length,
        ),
      );
    }
    if (pageBusy || translation.anyPageBusy) {
      return _StatusPillContent(
        label: S.current.page_translation_status_translating,
      );
    }
    if (translation.hasOutdatedPages) {
      return _StatusPillContent(
        label: S.current.page_translation_status_outdated,
        icon: Icons.update_rounded,
        onTap: () =>
            cubit.updateOutdated(state.currentPages.value, state.headers),
      );
    }
    return null;
  }

  String _modelDownloadLabel(BuildContext context) {
    if (_usesGemma) {
      final OnDeviceModelState gemma = context
          .watch<OnDeviceModelCubit>()
          .state;
      return withDownloadEstimate(
        S.current.page_translation_ai_model_downloading(gemma.progress),
        gemma.estimate,
      );
    }
    final LanguagePacksState packs = context.watch<LanguagePacksCubit>().state;
    if (packs.batchTotal <= 0) {
      return S.current.page_translation_models_downloading;
    }
    final int currentPack = (packs.batchDone + 1).clamp(1, packs.batchTotal);
    return S.current.page_translation_models_downloading_progress(
      currentPack,
      packs.batchTotal,
    );
  }

  Widget _buildTranslateButton() {
    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: _translationCubit,
      builder: (BuildContext context, PageTranslationState translation) {
        final bool translationOn =
            translation.phase != PageTranslationPhase.off &&
            translation.phase != PageTranslationPhase.needsModels;
        return Material(
          color: translationOn
              ? AppColors.primary
              : Colors.black.withValues(alpha: 0.55),
          shape: CircleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: translation.busy ? null : _translationCubit!.toggle,
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: SizedBox(
                width: 22,
                height: 22,
                child: translation.busy
                    ? Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.mainBlack,
                        ),
                      )
                    : Icon(
                        Icons.translate_rounded,
                        color: translationOn
                            ? AppColors.mainBlack
                            : AppColors.onMedia,
                        size: 22,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage() {
    return BlocConsumer<ChapterViewCubit, ChapterViewState>(
      listenWhen: (ChapterViewState previous, ChapterViewState current) =>
          current is ChapterViewInitialized &&
          (!_initialized ||
              (previous is ChapterViewInitialized &&
                  (current.mode != previous.mode ||
                      current.currentPage != previous.currentPage))),
      listener: (BuildContext context, ChapterViewState state) {
        if (state is ChapterViewInitialized) {
          final bool isInit = !_initialized;
          final bool modeChanged = _lastMode != null && state.mode != _lastMode;
          _initialized = true;

          if (isInit || modeChanged) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state.mode == ChapterViewMode.webtoon) {
                _itemScrollController.jumpTo(
                  index: max(0, state.currentPage - 1),
                );
              } else {
                _pageController.jumpToPage(max(0, state.currentPage - 1));
              }
            });
            _animateSliderTo(state, animate: false);
          } else if (state.currentPage != _lastPage) {
            _animateSliderTo(state, animate: _seekOverride == null);
          }

          _lastMode = state.mode;
          _lastPage = state.currentPage;
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
                _buildHorizontalGestures(state, context),
              _buildControls(context, state),
              _buildLoaders(context, state),
              _buildPageCounter(context, state),
              _buildTranslationStatus(context, state),
            ],
          );
        } else if (state is ChapterViewError) {
          return Stack(
            children: <Widget>[
              ServiceViewerMessage(
                icon: Icons.error_outline_rounded,
                title: S.current.concrete_viewer_error_title,
                message: state.message,
              ),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildRoundButton(
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

  Widget _buildPageCounter(BuildContext context, ChapterViewInitialized state) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      right: 0,
      left: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state.controlsVisible ? 0.0 : 1.0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.currentPage}/${state.totalPages}',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalGestures(
    ChapterViewInitialized state,
    BuildContext context,
  ) {
    if (!state.controlsEnabled) {
      return const SizedBox();
    }

    return TransparentPointer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    max(0, state.currentPage - 2),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                },
                // behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                    color: _showGestureOverlay
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : Colors.transparent,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showGestureOverlay
                        ? Center(
                            child: Text(
                              state.mode == ChapterViewMode.leftToRight
                                  ? "Prev"
                                  : "Next",
                              style: semibold(size: 24).apply(
                                shadows: <Shadow>[
                                  BoxShadow(
                                    color: AppColors.mainBlack,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
              GestureDetector(
                // behavior: HitTestBehavior.translucent,
                onTap: () {
                  _pageController.animateToPage(
                    min(state.currentPages.value.length - 1, state.currentPage),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * .80,
                  width: MediaQuery.of(context).size.width * .2,
                  decoration: BoxDecoration(
                    color: _showGestureOverlay
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : Colors.transparent,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showGestureOverlay
                        ? Center(
                            child: Text(
                              state.mode == ChapterViewMode.leftToRight
                                  ? "Next"
                                  : "Prev",
                              style: semibold(size: 24).apply(
                                shadows: <Shadow>[
                                  BoxShadow(
                                    color: AppColors.mainBlack,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        _buildTopBar(context, title),
        const Spacer(),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: Text(
        title,
        style: semibold(size: 16, color: AppColors.onMedia),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ChapterViewInitialized state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        40,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.currentPage}/${state.totalPages}',
                style: medium(size: 13, color: AppColors.onMedia),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _buildRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildSlider(context, state)),
              const SizedBox(width: 12),
              if (_translationCubit != null) ...<Widget>[
                _buildTranslateButton(),
                const SizedBox(width: 8),
              ],
              _buildRoundButton(
                icon: Icons.settings_rounded,
                onTap: () => _showBottomSheetSettings(context, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: AppColors.onMedia, size: 22),
        ),
      ),
    );
  }

  double _currentSliderValue() {
    return _sliderFrom +
        (_sliderTarget - _sliderFrom) *
            Curves.easeOut.transform(_sliderController.value);
  }

  void _animateSliderTo(ChapterViewInitialized state, {required bool animate}) {
    final double maxValue = max(2, state.totalPages).toDouble();
    final double target = state.currentPage.toDouble().clamp(1.0, maxValue);
    _sliderFrom = _currentSliderValue();
    _sliderTarget = target;
    if (animate) {
      _sliderController
        ..reset()
        ..forward();
    } else {
      _sliderController.value = 1.0;
    }
  }

  Widget _buildSlider(BuildContext context, ChapterViewInitialized state) {
    final double maxValue = max(2, state.totalPages).toDouble();

    return AnimatedBuilder(
      animation: _sliderController,
      builder: (BuildContext context, Widget? child) {
        final double value = (_seekOverride ?? _currentSliderValue()).clamp(
          1.0,
          maxValue,
        );
        return FlutterSlider(
          values: <double>[value],
          min: 1,
          max: maxValue,
          jump: true,
          handlerHeight: 20,
          handlerWidth: 20,
          onDragStarted: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
            _sliderController.stop();
          },
          onDragging: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
          },
          onDragCompleted: (_, index, __) {
            final double dragged = (index as num).toDouble();
            _seekOverride = dragged;
            _sliderFrom = dragged;
            _sliderTarget = dragged;
            _sliderController.value = 1.0;
            switch (state.mode) {
              case ChapterViewMode.rightToLeft:
              case ChapterViewMode.leftToRight:
                _pageController.jumpToPage(
                  min(dragged.toInt() - 1, state.currentPages.value.length - 1),
                );
                break;
              case ChapterViewMode.webtoon:
                _itemScrollController.jumpTo(
                  index: min(
                    dragged.toInt(),
                    state.currentPages.value.length - 1,
                  ),
                  alignment: dragged == state.totalPages.toDouble() - 1 ? 1 : 0,
                );
                break;
            }

            _canLoadNext =
                dragged.toInt() - 1 == state.currentPages.value.length - 1;
            _canLoadPrevious = dragged.toInt() - 1 == 0;
            if (mounted) {
              setState(() {});
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _seekOverride = null;
              if (mounted) {
                setState(() {});
              }
            });
          },
          tooltip: FlutterSliderTooltip(
            custom: (v) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: pageImageProvider(
                  state.currentPages.value[min(
                    (v as double).toInt(),
                    state.currentPages.value.length - 1,
                  )],
                  state.headers,
                ),
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? progress,
                    ) {
                      if (progress == null) return child;
                      return CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : 0.01,
                        color: AppColors.onMedia,
                      );
                    },
              ),
            ),
            textStyle: regular(color: AppColors.onMedia),
          ),
          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 5,
            inactiveTrackBarHeight: 5,
            inactiveTrackBar: BoxDecoration(
              color: AppColors.overlay(0.25),
              borderRadius: BorderRadius.circular(16.0),
            ),
            activeTrackBar: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          handler: FlutterSliderHandler(
            child: const SizedBox(),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
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

  static const int _prefetchRadius = 2;
  static const double _minSelectionSide = 24;
  static const int _translateAhead = 2;
  static const double _autoAdvanceOverscroll = 96;

  bool _maybeAutoAdvance(
    ScrollUpdateNotification notification,
    ChapterViewInitialized state,
  ) {
    if (_autoAdvancing ||
        notification.dragDetails == null ||
        !state.canGetNextPages ||
        notification.metrics.pixels <
            notification.metrics.maxScrollExtent + _autoAdvanceOverscroll) {
      return false;
    }
    _autoAdvancing = true;
    context.read<ChapterViewCubit>().onPagesChanged(
      next: true,
      onDone: () {
        _canLoadNext = false;
        _canLoadPrevious = true;
        if (mounted) setState(() {});
      },
    );
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      _autoAdvancing = false;
    });
    return false;
  }

  double _webtoonCacheExtent(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 2;

  void _prefetchAround(ChapterViewInitialized state, int index) {
    final List<String> pages = state.currentPages.value;
    if (pages.isEmpty) return;

    final int start = max(0, index - _prefetchRadius);
    final int end = min(pages.length - 1, index + _prefetchRadius);
    prefetchPages(pages.sublist(start, end + 1), state.headers);
    _requestTranslations(state, index);
  }

  Widget _buildPageViewerPage(
    ChapterViewInitialized state,
    BuildContext context,
  ) {
    switch (state.mode) {
      case ChapterViewMode.rightToLeft:
      case ChapterViewMode.leftToRight:
        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (ScrollUpdateNotification notification) =>
              _maybeAutoAdvance(notification, state),
          child: PhotoViewGallery.builder(
            allowImplicitScrolling: true,
            loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
              return Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    value: event != null && event.expectedTotalBytes != null
                        ? event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                        : 0,
                  ),
                ),
              );
            },
            pageController: _pageController,
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: state.currentPages.value.length,
            reverse: state.mode == ChapterViewMode.rightToLeft,
            onPageChanged: (int index) {
              _prefetchAround(state, index);
              context.read<ChapterViewCubit>().onPageChanged(
                index + 1,
                state.currentPages,
                onDone: (Pages currentPages) {
                  if (index == 0) {
                    _canLoadPrevious = true;
                  } else if (index == currentPages.value.length - 1) {
                    _canLoadNext = true;
                  } else {
                    _canLoadPrevious = false;
                    _canLoadNext = false;
                  }
                },
              );
              setState(() {});
            },
            builder: (BuildContext context, int index) {
              final String page = state.currentPages.value[index];
              return PhotoViewGalleryPageOptions.customChild(
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                basePosition: Alignment.center,
                // photo_view only applies zoom through its Transform when
                // filterQuality is none; otherwise it scales the Image widget
                // it builds, which a custom child never receives. PageImage
                // does its own filtering.
                filterQuality: FilterQuality.none,
                childSize: _pageSizes[page],
                child: TranslatedPage(
                  key: _translatedPageKey(page),
                  cubit: _translationCubit,
                  path: page,
                  child: PageImage(
                    path: page,
                    headers: state.headers,
                    intrinsic: true,
                    onSizeResolved: (Size size) {
                      if (_pageSizes[page] != size && mounted) {
                        setState(() => _pageSizes[page] = size);
                      }
                    },
                    loadingBuilder: (BuildContext context) =>
                        SizedBox.fromSize(size: MediaQuery.of(context).size),
                    errorBuilder: (BuildContext context, VoidCallback retry) =>
                        SizedBox.fromSize(
                          size: MediaQuery.of(context).size,
                          child: _buildPageError(retry),
                        ),
                  ),
                ),
              );
            },
          ),
        );
      case ChapterViewMode.webtoon:
        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (ScrollUpdateNotification notification) {
            _maybeAutoAdvance(notification, state);
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 500) {
              _canLoadNext = true;
              setState(() {});
            } else if (_canLoadNext) {
              _canLoadNext = false;
              setState(() {});
            }

            if ((notification.metrics.pixels <=
                notification.metrics.minScrollExtent + 500)) {
              _canLoadPrevious = true;
              setState(() {});
            } else if (_canLoadPrevious) {
              _canLoadPrevious = false;
              setState(() {});
            }

            return false;
          },
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            initialScrollIndex: max(0, state.currentPage - 1),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: state.currentPages.value.length,
            minCacheExtent: _webtoonCacheExtent(context),
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) =>
                VisibilityDetector(
                  key: ValueKey(state.currentPages.value[index]),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction > 0) {
                      _prefetchAround(state, index);
                      context.read<ChapterViewCubit>().onPageChanged(
                        index + 1,
                        state.currentPages,
                      );
                    }
                  },
                  child: TranslatedPage(
                    key: _translatedPageKey(state.currentPages.value[index]),
                    cubit: _translationCubit,
                    path: state.currentPages.value[index],
                    child: PageImage(
                      path: state.currentPages.value[index],
                      headers: state.headers,
                      errorBuilder:
                          (BuildContext context, VoidCallback retry) =>
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: _buildPageError(retry),
                              ),
                      loadingBuilder: (BuildContext context) => SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        );
    }
  }

  Widget _buildPageError(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: AppColors.onMedia.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: AppColors.onMedia,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              S.current.concrete_viewer_retry_button,
              style: medium(size: 14, color: AppColors.onMedia),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildBackground(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
    );
  }

  Widget _buildLoaders(BuildContext context, ChapterViewInitialized state) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildControlButtons(context, state),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    ChapterViewInitialized state,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child:
          (_canLoadPrevious && state.canGetPreviousPages) ||
              (_canLoadNext && state.canGetNextPages)
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.mainBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (_canLoadNext && state.canGetNextPages) {
                  context.read<ChapterViewCubit>().onPagesChanged(
                    next: true,
                    onDone: () {
                      _canLoadNext = false;
                      _canLoadPrevious = true;
                      setState(() {});
                    },
                  );
                } else if (_canLoadPrevious && state.canGetPreviousPages) {
                  context.read<ChapterViewCubit>().onPagesChanged(
                    next: false,
                    onDone: () {
                      _canLoadPrevious = false;
                      _canLoadNext = true;
                      setState(() {});
                    },
                  );
                }
              },
              icon: Icon(
                _canLoadNext && state.canGetNextPages
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                size: 20,
              ),
              label: Text(
                _canLoadNext && state.canGetNextPages
                    ? S.current.chapter_viewer_next_chapter_button_title
                    : _canLoadPrevious && state.canGetPreviousPages
                    ? S.current.chapter_viewer_previous_chapter_button_title
                    : "",
                style: semibold(size: 15, color: AppColors.mainBlack),
              ),
            )
          : const SizedBox(),
    );
  }
}

class _StatusPillContent {
  const _StatusPillContent({required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
}
