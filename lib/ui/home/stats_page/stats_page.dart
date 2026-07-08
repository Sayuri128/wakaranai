import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/data/domain/ui/reading_stats.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/stats_page/cubit/stats_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (BuildContext context, StatsState state) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _Header(),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    if (state is StatsLoading || state is StatsInitial) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is StatsDisabled) {
      return ServiceViewerMessage(
        icon: Icons.bar_chart_rounded,
        title: S.current.stats_disabled_title,
        message: S.current.stats_disabled_message,
        actions: <Widget>[
          _PrimaryButton(
            label: S.current.stats_enable_button,
            onTap: () => context.read<StatsCubit>().enable(),
          ),
        ],
      );
    }

    if (state is StatsError) {
      return ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.stats_error_title,
      );
    }

    final ReadingStats stats = (state as StatsLoaded).stats;

    if (stats.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.insights_rounded,
        title: S.current.stats_empty_title,
        message: S.current.stats_empty_message,
      );
    }

    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24 + bottomInset),
      children: <Widget>[
        _SectionTitle(title: S.current.stats_overview_section_title),
        _OverviewGrid(stats: stats),
        _SectionTitle(title: S.current.stats_activity_section_title),
        _ActivityCard(stats: stats),
        if (stats.topSources.isNotEmpty) ...<Widget>[
          _SectionTitle(title: S.current.stats_sources_section_title),
          _SourcesCard(stats: stats),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: <Widget>[
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(S.current.stats_title, style: semibold(size: 24)),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: AppColors.mainWhite),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Text(title, style: semibold(size: 18)),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final List<_Metric> metrics = <_Metric>[
      _Metric(
        icon: Icons.menu_book_rounded,
        value: _formatCount(stats.chaptersRead),
        label: S.current.stats_kpi_chapters_read,
      ),
      _Metric(
        icon: Icons.description_rounded,
        value: _formatCount(stats.pagesRead),
        label: S.current.stats_kpi_pages_read,
      ),
      _Metric(
        icon: Icons.play_circle_outline_rounded,
        value: _formatCount(stats.episodesWatched),
        label: S.current.stats_kpi_episodes_watched,
      ),
      _Metric(
        icon: Icons.schedule_rounded,
        value: _formatDuration(stats.watchSeconds),
        label: S.current.stats_kpi_time_watched,
      ),
      _Metric(
        icon: Icons.local_fire_department_rounded,
        value: _formatCount(stats.currentStreak),
        label: S.current.stats_kpi_day_streak,
      ),
      _Metric(
        icon: Icons.event_available_rounded,
        value: _formatCount(stats.activeDays),
        label: S.current.stats_kpi_active_days,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double gap = 12;
          final double tileWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final _Metric metric in metrics)
                SizedBox(
                  width: tileWidth,
                  child: _StatCard(metric: metric),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(metric.value, style: semibold(size: 22)),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: regular(size: 12, color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Heatmap(dailyCounts: stats.dailyCounts),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Icon(Icons.local_fire_department_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    S.current.stats_streak_summary(
                      stats.currentStreak,
                      stats.longestStreak,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: medium(size: 13, color: AppColors.mainGrey),
                  ),
                ),
                const SizedBox(width: 12),
                _HeatmapLegend(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatefulWidget {
  const _Heatmap({required this.dailyCounts});

  final Map<DateTime, int> dailyCounts;

  @override
  State<_Heatmap> createState() => _HeatmapState();
}

class _HeatmapState extends State<_Heatmap> {
  int? _selectedWeek;

  @override
  Widget build(BuildContext context) {
    final int maxCount = widget.dailyCounts.values
        .fold<int>(0, (int m, int v) => v > m ? v : m);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 4;
        const int rows = 7;
        int weeks = ((constraints.maxWidth + gap) / (14 + gap)).floor();
        weeks = weeks.clamp(10, 26);
        final double cell =
            (constraints.maxWidth - gap * (weeks - 1) - 0.5) / weeks;

        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime thisMonday =
            today.subtract(Duration(days: today.weekday - 1));
        final DateTime start =
            thisMonday.subtract(Duration(days: (weeks - 1) * 7));

        final int? selected =
            (_selectedWeek != null && _selectedWeek! < weeks)
                ? _selectedWeek
                : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildReadout(selected, start, today),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int col = 0; col < weeks; col++) ...<Widget>[
                  if (col > 0) const SizedBox(width: gap),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(
                        () => _selectedWeek = selected == col ? null : col),
                    child: Opacity(
                      opacity: selected == null || selected == col ? 1.0 : 0.3,
                      child: Column(
                        children: <Widget>[
                          for (int row = 0; row < rows; row++) ...<Widget>[
                            if (row > 0) const SizedBox(height: gap),
                            _buildCell(
                              start.add(Duration(days: col * 7 + row)),
                              today,
                              maxCount,
                              cell,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadout(int? selected, DateTime start, DateTime today) {
    String text;
    String? countText;
    Color textColor;
    if (selected == null) {
      text = S.current.stats_heatmap_hint;
      countText = null;
      textColor = AppColors.mainGrey;
    } else {
      final DateTime weekStart = start.add(Duration(days: selected * 7));
      final DateTime weekEndFull = weekStart.add(const Duration(days: 6));
      final DateTime weekEnd =
          weekEndFull.isAfter(today) ? today : weekEndFull;
      int count = 0;
      for (int i = 0; i < 7; i++) {
        final DateTime day = weekStart.add(Duration(days: i));
        if (!day.isAfter(today)) count += widget.dailyCounts[day] ?? 0;
      }
      final DateFormat fmt = DateFormat.MMMd();
      text = '${fmt.format(weekStart)} – ${fmt.format(weekEnd)}';
      countText = S.current.stats_heatmap_week_count(count);
      textColor = AppColors.mainWhite;
    }

    return SizedBox(
      height: 20,
      child: Row(
        children: <Widget>[
          Icon(Icons.date_range_rounded, size: 15, color: AppColors.mainGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: medium(size: 13, color: textColor),
            ),
          ),
          if (countText != null) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              countText,
              style: semibold(size: 13, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCell(
    DateTime date,
    DateTime today,
    int maxCount,
    double size,
  ) {
    final bool future = date.isAfter(today);
    final int count = widget.dailyCounts[date] ?? 0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: future
            ? Colors.transparent
            : _intensityColor(count, maxCount),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

Color _intensityColor(int count, int maxCount) {
  if (count <= 0 || maxCount <= 0) return AppColors.overlay(0.05);
  final double ratio = count / maxCount;
  if (ratio <= 0.25) return AppColors.primary.withValues(alpha: 0.3);
  if (ratio <= 0.5) return AppColors.primary.withValues(alpha: 0.5);
  if (ratio <= 0.75) return AppColors.primary.withValues(alpha: 0.72);
  return AppColors.primary;
}

class _HeatmapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(S.current.stats_heatmap_less,
            style: regular(size: 11, color: AppColors.mainGrey)),
        const SizedBox(width: 4),
        for (final double alpha in <double>[0.0, 0.3, 0.5, 0.72, 1.0]) ...<Widget>[
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: alpha == 0.0
                  ? AppColors.overlay(0.05)
                  : AppColors.primary.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text(S.current.stats_heatmap_more,
            style: regular(size: 11, color: AppColors.mainGrey)),
      ],
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final int maxTotal = stats.topSources
        .fold<int>(0, (int m, SourceStat s) => s.total > m ? s.total : m);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            for (final SourceStat source in stats.topSources)
              _SourceBar(source: source, maxTotal: maxTotal),
          ],
        ),
      ),
    );
  }
}

class _SourceBar extends StatelessWidget {
  const _SourceBar({required this.source, required this.maxTotal});

  final SourceStat source;
  final int maxTotal;

  @override
  Widget build(BuildContext context) {
    final double fraction = maxTotal <= 0 ? 0 : source.total / maxTotal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: medium(size: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCount(source.total),
                style: semibold(size: 14, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: <Widget>[
                Container(height: 6, color: AppColors.overlay(0.06)),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0.02, 1.0),
                  child: Container(height: 6, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            label,
            style: semibold(size: 15, color: AppColors.mainBlack),
          ),
        ),
      ),
    );
  }
}

String _formatCount(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return (value < 0 ? '-' : '') + buffer.toString();
}

String _formatDuration(int seconds) {
  final int totalMinutes = seconds ~/ 60;
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}
