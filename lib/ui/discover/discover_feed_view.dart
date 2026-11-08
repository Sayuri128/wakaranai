import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/discover/discover_feed_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/discover/discover_models.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/discover/discover_media_sheet.dart';
import 'package:wakaranai/ui/discover/discover_texts.dart';
import 'package:wakaranai/ui/widgets/cover_image.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class DiscoverFeedView extends StatefulWidget {
  const DiscoverFeedView({super.key, this.season});

  final DiscoverSeason? season;

  static const int columns = 3;
  static const double spacing = 10;
  static const double coverAspectRatio = 2 / 3;
  static const double cardAspectRatio = 0.5;

  @override
  State<DiscoverFeedView> createState() => _DiscoverFeedViewState();
}

class _DiscoverFeedViewState extends State<DiscoverFeedView> {
  static const double _loadMoreExtent = 800;
  static const int _skeletonCards = 12;
  static const int _footerSkeletonCards = 3;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < _loadMoreExtent) {
      unawaited(context.read<DiscoverFeedCubit>().loadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverFeedCubit, DiscoverFeedState>(
      builder: (BuildContext context, DiscoverFeedState state) {
        if (state.error != null && state.items.isEmpty) {
          return _buildError(context);
        }
        if (!state.started || state.loading) {
          return _buildScroll(<Widget>[
            _buildGrid(_skeletonCards, (int index) => _buildSkeletonCard()),
          ]);
        }
        if (state.items.isEmpty) {
          return ServiceViewerMessage(
            icon: Icons.explore_off_rounded,
            title: S.current.discover_empty_title,
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: _buildScroll(<Widget>[
            _buildGrid(
              state.items.length,
              (int index) => _buildCard(context, state.items[index]),
            ),
            if (state.loadingMore)
              _buildGrid(
                _footerSkeletonCards,
                (int index) => _buildSkeletonCard(),
              ),
            if (state.loadMoreFailed) _buildLoadMoreRetry(context),
          ]),
        );
      },
    );
  }

  Widget _buildScroll(List<Widget> slivers) {
    final DiscoverSeason? season = widget.season;
    return CustomScrollView(
      slivers: <Widget>[
        if (season != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                discoverSeasonLabel(season),
                style: semibold(size: 18),
              ),
            ),
          ),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildGrid(int count, Widget Function(int index) builder) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: DiscoverFeedView.columns,
          mainAxisSpacing: DiscoverFeedView.spacing,
          crossAxisSpacing: DiscoverFeedView.spacing,
          childAspectRatio: DiscoverFeedView.cardAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => builder(index),
          childCount: count,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, DiscoverMedia media) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
            onTap: () => unawaited(showDiscoverMediaSheet(context, media)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: DiscoverFeedView.coverAspectRatio,
                  child: _buildCover(media, constraints.maxWidth),
                ),
                const SizedBox(height: 6),
                Text(
                  media.displayTitle,
                  style: medium(size: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(DiscoverMedia media, double width) {
    final String? cover = media.cover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: cover == null
          ? _buildCoverPlaceholder(media)
          : CoverImage(
              url: cover,
              logicalWidth: width,
              placeholder: (BuildContext context) =>
                  _buildCoverPlaceholder(media),
            ),
    );
  }

  Widget _buildCoverPlaceholder(DiscoverMedia media) {
    return ColoredBox(
      color: _coverTint(media) ?? AppColors.shimmerBase,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 28),
      ),
    );
  }

  Color? _coverTint(DiscoverMedia media) {
    final String? hex = media.coverColor;
    if (hex == null || hex.length != 7 || !hex.startsWith('#')) {
      return null;
    }
    final int? value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) {
      return null;
    }
    return Color(0xFF000000 | value).withValues(alpha: 0.35);
  }

  Widget _buildSkeletonCard() {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: DiscoverFeedView.coverAspectRatio,
            child: ShimmerBox(borderRadius: 10),
          ),
          const SizedBox(height: 6),
          ShimmerBox(height: 12),
          const SizedBox(height: 4),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.6,
            child: ShimmerBox(height: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return ServiceViewerMessage(
      icon: Icons.cloud_off_rounded,
      title: S.current.discover_error_title,
      message: S.current.discover_error_message,
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
          onPressed: () => unawaited(context.read<DiscoverFeedCubit>().load()),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(S.current.discover_retry),
        ),
      ],
    );
  }

  Widget _buildLoadMoreRetry(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                S.current.discover_load_more_failed,
                style: regular(size: 14, color: AppColors.mainGrey),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: () =>
                  unawaited(context.read<DiscoverFeedCubit>().retryMore()),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(S.current.discover_retry),
            ),
          ],
        ),
      ),
    );
  }
}
