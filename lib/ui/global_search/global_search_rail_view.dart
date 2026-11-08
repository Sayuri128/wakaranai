import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/global_search/global_search_backend.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/ui/global_search/global_search_navigation.dart';
import 'package:wakaranai/ui/widgets/extension_logo.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/source_error_description.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GlobalSearchRailView extends StatelessWidget {
  const GlobalSearchRailView({
    super.key,
    required this.rail,
    required this.onOpenItem,
    required this.onRetry,
    required this.onOpenSource,
  });

  static const double cardWidth = 112;
  static const double cardHeight = 168;
  static const int _skeletonCards = 5;

  final GlobalSearchRail rail;
  final ValueChanged<GalleryView> onOpenItem;
  final VoidCallback onRetry;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHeader(),
        _buildBody(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: <Widget>[
          ExtensionLogo(configInfo: rail.source.config, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rail.source.name,
              style: semibold(size: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rail.hasResults) _buildCountBadge(),
        ],
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        S.current.global_search_results_count(rail.items.length),
        style: medium(size: 12, color: AppColors.mainGrey),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (rail.status) {
      case GlobalSearchRailStatus.loading:
        return GlobalSearchRailSkeleton(cards: _skeletonCards);
      case GlobalSearchRailStatus.loaded:
        return _buildResults();
      case GlobalSearchRailStatus.needsSignIn:
        return _buildNotice(
          icon: Icons.lock_outline_rounded,
          title: _signInTitle(),
          actionLabel: S.current.global_search_rail_open,
          onAction: onOpenSource,
        );
      case GlobalSearchRailStatus.failed:
        return _buildNotice(
          icon: Icons.error_outline_rounded,
          title: _failureTitle(),
          actionLabel: S.current.global_search_rail_retry,
          onAction: onRetry,
        );
    }
  }

  String _signInTitle() {
    final Object? error = rail.error;
    if (error is SourceNeedsAttention &&
        error.reason == SourceAttentionReason.challengeRequired) {
      return S.current.global_search_rail_verify;
    }
    return S.current.global_search_rail_sign_in;
  }

  String _failureTitle() {
    final Object? error = rail.error;
    if (rail.timedOut) {
      return S.current.global_search_rail_timeout;
    }
    if (error is GlobalSearchSourceUnavailable) {
      return S.current.global_search_rail_unavailable;
    }
    final SourceErrorDescription? description = describeSourceError(
      error,
      sourceName: rail.source.name,
      canSignIn: false,
    );
    return description?.title ?? S.current.global_search_rail_failed;
  }

  Widget _buildResults() {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rail.items.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) =>
            _buildCard(rail.items[index]),
      ),
    );
  }

  Widget _buildCard(GalleryView item) {
    return SizedBox(
      width: cardWidth,
      child: GalleryViewCard(
        uid: 'global_search:${rail.source.uid}:${item.uid}',
        headers: rail.coverHeaders[item.uid] ?? const <String, String>{},
        cover: globalSearchCoverOf(item),
        title: globalSearchTitleOf(item),
        compact: true,
        onTap: () => onOpenItem(item),
      ),
    );
  }

  Widget _buildNotice({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.overlay(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.mainGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: medium(size: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildActionPill(actionLabel, onAction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill(String label, VoidCallback onTap) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label, style: medium(size: 13, color: AppColors.primary)),
        ),
      ),
    );
  }
}

class GlobalSearchRailSkeleton extends StatelessWidget {
  const GlobalSearchRailSkeleton({super.key, this.cards = 5});

  final int cards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GlobalSearchRailView.cardHeight,
      child: Shimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cards,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 10),
          itemBuilder: (BuildContext context, int index) => ShimmerBox(
            width: GlobalSearchRailView.cardWidth,
            height: GlobalSearchRailView.cardHeight,
            borderRadius: Heroes.galleryCardRadius,
          ),
        ),
      ),
    );
  }
}

class GlobalSearchRailsSkeleton extends StatelessWidget {
  const GlobalSearchRailsSkeleton({super.key, this.rails = 3});

  final int rails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < rails; index++) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Shimmer(
              child: Row(
                children: <Widget>[
                  ShimmerBox(width: 24, height: 24, borderRadius: 10),
                  const SizedBox(width: 10),
                  ShimmerBox(width: 140, height: 16),
                ],
              ),
            ),
          ),
          GlobalSearchRailSkeleton(),
        ],
      ],
    );
  }
}
