import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/widgets/download_estimate_text.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ReaderTranslationStatus extends StatelessWidget {
  const ReaderTranslationStatus({
    super.key,
    required this.cubit,
    required this.state,
    required this.usesGemma,
  });

  final PageTranslationCubit? cubit;
  final ChapterViewInitialized state;
  final bool usesGemma;

  @override
  Widget build(BuildContext context) {
    final PageTranslationCubit? cubit = this.cubit;
    final String? path = _currentPagePath();
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

  String? _currentPagePath() {
    final List<String> pages = state.currentPages.value;
    if (pages.isEmpty) {
      return null;
    }
    final int index = (state.currentPage - 1).clamp(0, pages.length - 1);
    return pages[index];
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
    if (usesGemma) {
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
}

class ReaderPeekButton extends StatelessWidget {
  const ReaderPeekButton({super.key, required this.cubit, required this.state});

  final PageTranslationCubit? cubit;
  final ChapterViewInitialized state;

  @override
  Widget build(BuildContext context) {
    final PageTranslationCubit? cubit = this.cubit;
    if (cubit == null) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: cubit,
      buildWhen:
          (PageTranslationState previous, PageTranslationState current) =>
              previous.active != current.active ||
              previous.peeking != current.peeking,
      builder: (BuildContext context, PageTranslationState translation) {
        final bool visible = translation.active;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16,
          bottom:
              MediaQuery.of(context).padding.bottom +
              (state.controlsVisible ? 136 : 56),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !visible,
              child: _PeekButton(
                peeking: translation.peeking,
                onPeekChanged: cubit.setPeeking,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReaderTranslateButton extends StatelessWidget {
  const ReaderTranslateButton({super.key, required this.cubit});

  final PageTranslationCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: cubit,
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
            onTap: translation.busy ? null : cubit.toggle,
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
}

class _StatusPillContent {
  const _StatusPillContent({required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
}

class _PeekButton extends StatelessWidget {
  const _PeekButton({required this.peeking, required this.onPeekChanged});

  final bool peeking;
  final ValueChanged<bool> onPeekChanged;

  void _startPeeking() {
    HapticFeedback.selectionClick();
    onPeekChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S.current.page_translation_peek_hint,
      child: Listener(
        onPointerDown: (_) => _startPeeking(),
        onPointerUp: (_) => onPeekChanged(false),
        onPointerCancel: (_) => onPeekChanged(false),
        child: GestureDetector(
          onTap: () {},
          onLongPress: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: peeking
                  ? AppColors.primary
                  : Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(
              peeking ? Icons.visibility_rounded : Icons.visibility_outlined,
              size: 22,
              color: peeking ? AppColors.mainBlack : AppColors.onMedia,
            ),
          ),
        ),
      ),
    );
  }
}
