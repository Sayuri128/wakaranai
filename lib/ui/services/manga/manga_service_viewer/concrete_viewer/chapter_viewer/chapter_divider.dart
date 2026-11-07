import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ChapterDivider extends StatelessWidget {
  const ChapterDivider({
    super.key,
    required this.divider,
    required this.onRetry,
    required this.onBack,
  });

  final ReaderStripDivider divider;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final double bottom = divider.isEnd
        ? MediaQuery.of(context).padding.bottom + 96
        : 40;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 40, 24, bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _DividerLabel(text: S.current.chapter_divider_finished),
          const SizedBox(height: 6),
          _DividerTitle(text: divider.finished.chapter.title),
          const SizedBox(height: 20),
          _buildConnector(),
          const SizedBox(height: 20),
          if (divider.isEnd) _buildEnd() else _buildNext(divider.next!),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Row(
      children: <Widget>[
        Expanded(child: _buildLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              divider.isEnd
                  ? Icons.done_all_rounded
                  : Icons.keyboard_double_arrow_down_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(child: _buildLine()),
      ],
    );
  }

  Widget _buildLine() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.12));
  }

  Widget _buildNext(Chapter next) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _DividerLabel(text: S.current.chapter_divider_next),
        const SizedBox(height: 6),
        _DividerTitle(text: next.title),
        const SizedBox(height: 12),
        _buildNextStatus(),
      ],
    );
  }

  Widget _buildNextStatus() {
    final LoadedChapter? loaded = divider.nextLoaded;
    if (loaded != null) {
      return _buildMeta(loaded);
    }
    switch (divider.load) {
      case ChapterLoad.failed:
        return _buildFailed();
      case ChapterLoad.loading:
      case ChapterLoad.idle:
        return _buildLoading();
    }
  }

  Widget _buildMeta(LoadedChapter loaded) {
    final List<String> parts = <String>[
      S.current.chapter_divider_pages(loaded.pageCount),
      if (loaded.isDownloaded) S.current.chapter_divider_downloaded,
    ];
    return Text(
      parts.join(' · '),
      style: regular(size: 13, color: Colors.white.withValues(alpha: 0.6)),
    );
  }

  Widget _buildLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          S.current.chapter_divider_loading,
          style: regular(size: 13, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          S.current.chapter_divider_failed,
          style: regular(size: 13, color: Colors.white.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 12),
        _DividerButton(
          icon: Icons.refresh_rounded,
          label: S.current.concrete_viewer_retry_button,
          onTap: onRetry,
        ),
      ],
    );
  }

  Widget _buildEnd() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          S.current.chapter_divider_end_title,
          textAlign: TextAlign.center,
          style: semibold(size: 18, color: AppColors.onMedia),
        ),
        const SizedBox(height: 6),
        Text(
          S.current.chapter_divider_end_message,
          textAlign: TextAlign.center,
          style: regular(size: 13, color: Colors.white.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 20),
        _DividerButton(
          icon: Icons.arrow_back_rounded,
          label: S.current.chapter_divider_back,
          onTap: onBack,
          primary: true,
        ),
      ],
    );
  }
}

class PreviousChapterCard extends StatelessWidget {
  const PreviousChapterCard({
    super.key,
    required this.item,
    required this.onLoad,
  });

  final ReaderStripPrevious item;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final bool loading = item.load == ChapterLoad.loading;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 32,
        24,
        32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _DividerLabel(text: S.current.chapter_divider_previous),
          const SizedBox(height: 6),
          _DividerTitle(text: item.previous.title),
          if (item.load == ChapterLoad.failed) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              S.current.chapter_divider_failed,
              style: regular(
                size: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _DividerButton(
            icon: Icons.keyboard_double_arrow_up_rounded,
            label: S.current.chapter_divider_load_previous,
            onTap: loading ? null : onLoad,
            loading: loading,
          ),
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: medium(
        size: 11,
        color: Colors.white.withValues(alpha: 0.5),
      ).copyWith(letterSpacing: 1.2),
    );
  }
}

class _DividerTitle extends StatelessWidget {
  const _DividerTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: semibold(size: 16, color: AppColors.onMedia),
    );
  }
}

class _DividerButton extends StatelessWidget {
  const _DividerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color foreground = primary ? AppColors.mainBlack : AppColors.onMedia;
    return Material(
      color: primary ? AppColors.primary : Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              else
                Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(label, style: medium(size: 14, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
