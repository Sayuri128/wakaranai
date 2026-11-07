part of 'chapter_viewer.dart';

mixin _ReaderTranslationControl on State<ChapterViewer> {
  static const int _translateAhead = 2;

  ChapterViewCubit get _chapterViewCubit;

  PageTranslationCubit? _translationCubit;
  OnDeviceModel? _gemmaVariant;
  bool _usesDeepL = false;

  bool get _usesGemma => _gemmaVariant != null;
  bool _pendingWholeChapter = false;

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
}
