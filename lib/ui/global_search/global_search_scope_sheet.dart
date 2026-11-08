import 'dart:async';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/ui/widgets/extension_logo.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showGlobalSearchScopeSheet(
  BuildContext context,
  GlobalSearchCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return BlocProvider<GlobalSearchCubit>.value(
        value: cubit,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: GlobalSearchScopeSheet(),
        ),
      );
    },
  );
}

class GlobalSearchScopeSheet extends StatelessWidget {
  const GlobalSearchScopeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
      builder: (BuildContext context, GlobalSearchState state) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildHandle(),
              _buildTitle(state),
              _buildActions(context, state),
              Flexible(child: _buildList(context, state)),
            ],
          ),
        );
      },
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

  Widget _buildTitle(GlobalSearchState state) {
    final String hint = state.customScope
        ? S.current.global_search_scope_custom_hint
        : S.current.global_search_scope_default_hint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.current.global_search_scope_title, style: semibold(size: 18)),
          const SizedBox(height: 4),
          Text(
            '${S.current.global_search_scope_summary(state.scope.length)} · '
            '$hint',
            style: regular(size: 13, color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, GlobalSearchState state) {
    final GlobalSearchCubit cubit = context.read<GlobalSearchCubit>();
    final Set<String> everything =
        state.catalog.map((GlobalSearchSource source) => source.uid).toSet();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: <Widget>[
          _buildPill(
            label: S.current.global_search_scope_select_all,
            onTap: () => unawaited(cubit.setScopeSelection(everything)),
          ),
          const SizedBox(width: 8),
          _buildPill(
            label: S.current.global_search_scope_select_none,
            onTap: () => unawaited(cubit.setScopeSelection(<String>{})),
          ),
          if (state.customScope) ...<Widget>[
            const SizedBox(width: 8),
            _buildPill(
              label: S.current.global_search_scope_reset,
              icon: Icons.restart_alt_rounded,
              onTap: () => unawaited(cubit.resetScope()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Material(
      color: AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: AppColors.mainWhite),
                const SizedBox(width: 6),
              ],
              Text(label, style: medium(size: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, GlobalSearchState state) {
    final List<Widget> children = <Widget>[];
    final Set<String> selected = state.scopeUids;
    for (final ConfigInfoType type in ConfigInfoType.values) {
      final List<GlobalSearchSource> sources = _sorted(state.catalog
          .where((GlobalSearchSource source) => source.config.type == type));
      if (sources.isEmpty) {
        continue;
      }
      children.add(_buildSectionLabel(_typeLabel(type)));
      for (final GlobalSearchSource source in sources) {
        children.add(_buildRow(context, source, selected));
      }
    }
    if (state.loadingRepositories) {
      children.add(_buildLoadingRow());
    }
    if (children.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          S.current.global_search_scope_empty,
          textAlign: TextAlign.center,
          style: regular(size: 14, color: AppColors.mainGrey),
        ),
      ));
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12),
      children: children,
    );
  }

  List<GlobalSearchSource> _sorted(Iterable<GlobalSearchSource> sources) {
    final List<GlobalSearchSource> result = sources.toList();
    result.sort((GlobalSearchSource a, GlobalSearchSource b) {
      if (a.isLocal != b.isLocal) {
        return a.isLocal ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  String _typeLabel(ConfigInfoType type) {
    switch (type) {
      case ConfigInfoType.MANGA:
        return S.current.home_manga_group_title;
      case ConfigInfoType.ANIME:
        return S.current.home_anime_group_title;
      case ConfigInfoType.NOVEL:
        return S.current.home_novel_group_title;
      case ConfigInfoType.AUDIO:
        return S.current.home_audio_group_title;
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(label, style: medium(size: 13, color: AppColors.mainGrey)),
    );
  }

  Widget _buildRow(
    BuildContext context,
    GlobalSearchSource source,
    Set<String> selected,
  ) {
    final bool isSelected = selected.contains(source.uid);
    final String language = source.config.language.trim();
    return InkWell(
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      onTap: () {
        final Set<String> next = Set<String>.of(selected);
        if (isSelected) {
          next.remove(source.uid);
        } else {
          next.add(source.uid);
        }
        unawaited(context.read<GlobalSearchCubit>().setScopeSelection(next));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: <Widget>[
            ExtensionLogo(configInfo: source.config, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    source.name,
                    style: medium(size: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (language.isNotEmpty)
                    Text(
                      language.toUpperCase(),
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : AppColors.mainGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Shimmer(child: ShimmerBox(width: 32, height: 32, borderRadius: 10)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Shimmer(child: ShimmerBox(width: 140, height: 14)),
                const SizedBox(height: 6),
                Text(
                  S.current.global_search_scope_loading,
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
