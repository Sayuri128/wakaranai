import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/discover/discover_models.dart';
import 'package:wakaranai/ui/discover/discover_texts.dart';
import 'package:wakaranai/ui/global_search/global_search_arguments.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/cover_image.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showDiscoverMediaSheet(BuildContext context, DiscoverMedia media) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
        ),
        child: DiscoverMediaSheet(
          media: media,
          onFind: (String query) {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).pushNamed(
              Routes.globalSearch,
              arguments: GlobalSearchArguments(
                query: query,
                alternativeQueries: media.searchTitles,
              ),
            );
          },
        ),
      );
    },
  );
}

class DiscoverMediaSheet extends StatefulWidget {
  const DiscoverMediaSheet({
    super.key,
    required this.media,
    required this.onFind,
  });

  final DiscoverMedia media;
  final ValueChanged<String> onFind;

  @override
  State<DiscoverMediaSheet> createState() => _DiscoverMediaSheetState();
}

class _DiscoverMediaSheetState extends State<DiscoverMediaSheet> {
  static const double _coverWidth = 96;
  static const double _coverHeight = 144;

  late String _query = widget.media.bestSearchTitle;

  DiscoverMedia get _media => widget.media;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(),
                  if (_media.genres.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    _buildGenres(),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    _media.description ?? S.current.discover_no_synopsis,
                    style: regular(size: 14, color: AppColors.mainGrey),
                  ),
                ],
              ),
            ),
          ),
          if (_media.searchTitles.length > 1) _buildTitleChoice(),
          _buildFindButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final List<String> otherTitles = <String?>[
      _media.romajiTitle,
      _media.nativeTitle,
    ]
        .whereType<String>()
        .where((String title) => title != _media.displayTitle)
        .toList(growable: false);
    final List<String> meta = discoverMetaParts(_media);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCover(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_media.displayTitle, style: semibold(size: 18)),
              for (final String title in otherTitles) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  title,
                  style: regular(size: 13, color: AppColors.mainGrey),
                ),
              ],
              if (meta.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  meta.join(' · '),
                  style: medium(size: 12, color: AppColors.mainGrey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCover() {
    final String? cover = _media.cover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: _coverWidth,
        height: _coverHeight,
        child: cover == null
            ? _buildCoverPlaceholder()
            : CoverImage(
                url: cover,
                logicalWidth: _coverWidth,
                placeholder: (BuildContext context) => _buildCoverPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return ColoredBox(
      color: AppColors.shimmerBase,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 28),
      ),
    );
  }

  Widget _buildGenres() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (final String genre in _media.genres)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.overlay(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(genre, style: medium(size: 12)),
          ),
      ],
    );
  }

  Widget _buildTitleChoice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.current.discover_search_as,
            style: medium(size: 13, color: AppColors.mainGrey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String title in _media.searchTitles)
                _buildTitlePill(title),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitlePill(String title) {
    final bool selected = title == _query;
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => setState(() => _query = title),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) ...<Widget>[
                Icon(Icons.check_rounded, size: 16, color: AppColors.mainBlack),
                const SizedBox(width: 6),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(
                  title,
                  style: medium(
                    size: 13,
                    color: selected ? AppColors.mainBlack : AppColors.mainWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _query.isEmpty ? null : () => widget.onFind(_query),
          icon: const Icon(Icons.travel_explore_rounded),
          label: Text(
            S.current.discover_find_on_sources,
            style: semibold(size: 16, color: AppColors.mainBlack),
          ),
        ),
      ),
    );
  }
}
