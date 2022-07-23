import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/service_viewer/filters/switcher.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/multiple_of_any/multiple_of_any.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/one_of_any/one_of_any.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/one_of_multiple/one_of_multiple.dart';
import 'package:wakascript/models/gallery_view/filters/data/filters/switcher/switcher.dart';
import 'package:wakascript/models/gallery_view/filters/gallery_filter.dart';
import 'package:wakascript/models/gallery_view/filters/multiple_of_any/multiple_of_any.dart';
import 'package:wakascript/models/gallery_view/filters/multiple_of_multiple/multiple_of_multiple.dart';
import 'package:wakascript/models/gallery_view/filters/one_of_any/one_of_any.dart';
import 'package:wakascript/models/gallery_view/filters/one_of_multiple/one_of_multiple.dart';
import 'package:wakascript/models/gallery_view/filters/switcher/swircher.dart';

import '../../../utils/text_styles.dart';
import 'multiple_of_any.dart';
import 'multiple_of_multiple.dart';
import 'one_of_any.dart';
import 'one_of_multiple.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({Key? key, required this.state}) : super(key: key);

  final ServiceViewInitialized state;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage>
    with TickerProviderStateMixin {
  late final AnimationController _searchButtonShadowAnimationController;
  late final AnimationController _searchButtonColorAnimationController;

  late final Animation<double> _searchButtonShadowAnimation;
  late final Animation<Color?> _searchButtonColorAnimation;

  @override
  void initState() {
    super.initState();

    _searchButtonColorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _searchButtonColorAnimation =
        ColorTween(begin: AppColors.secondary, end: AppColors.mediumLight)
            .animate(CurveTween(curve: Curves.easeInOutCubic)
                .animate(_searchButtonColorAnimationController))
          ..addListener(_animationListener);

    _searchButtonShadowAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true)
          ..forward();

    _searchButtonShadowAnimation = Tween<double>(begin: 1, end: 4).animate(
        CurveTween(curve: Curves.easeInOutCubic)
            .animate(_searchButtonShadowAnimationController))
      ..addListener(_animationListener);
  }

  void _animationListener() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchButtonColorAnimationController
      ..stop()
      ..removeListener(_animationListener)
      ..dispose();
    _searchButtonShadowAnimationController
      ..stop()
      ..removeListener(_animationListener)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 24),
              Text(
                S.current.service_viewer_filters_title,
                style: semibold(size: 18),
              ),
              const SizedBox(
                height: 24,
              ),
              ...widget.state.configInfo.filters.map((e) {
                return _buildFilter(e, widget.state, context);
              }).toList(),
              const SizedBox(height: 96,)
            ]),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                context.read<ServiceViewCubit>().search(null);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: _searchButtonColorAnimation.value,
                    boxShadow: [
                      BoxShadow(
                          color: _searchButtonColorAnimation.value ??
                              AppColors.primary,
                          spreadRadius: _searchButtonShadowAnimation.value,
                          blurRadius: _searchButtonShadowAnimation.value * 3)
                    ],
                    shape: BoxShape.circle),
                child: const Icon(Icons.search, size: 32),
              ),
            ),
          ),
        )
      ],
    );
  }

  RenderObjectWidget _buildFilter(
      GalleryFilter e, ServiceViewInitialized state, BuildContext context) {
    if (e is GalleryFilterMultipleOfAny) {
      return Column(
        children: [
          MultipleOfAnyWidget(
            parameterName: e.paramName,
            initSelectedItems: state.selectedFilters.containsKey(e.param)
                ? (state.selectedFilters[e.param] as FilterDataMultipleOfAny)
                    .selected
                : [],
            onChanged: (List<String> selectedItems) {
              if (selectedItems.isEmpty) {
                context.read<ServiceViewCubit>().removeFilter(e.param);
              } else {
                context.read<ServiceViewCubit>().onFilterChanged(
                    e.param,
                    FilterDataMultipleOfAny(
                        selected: selectedItems, filter: e));
              }
            },
          ),
          ..._buildFiltersSeparator()
        ],
      );
    } else if (e is GalleryFilterOneOfMultiple) {
      return Column(
        children: [
          OneOfMultipleWidget(
            paramName: e.paramName,
            items: e.values,
            onChanged: (item) {
              if (item == null) {
                context.read<ServiceViewCubit>().removeFilter(e.param);
              } else {
                context.read<ServiceViewCubit>().onFilterChanged(e.param,
                    FilterDataOneOfMultiple(selected: item, filter: e));
              }
            },
            defaultSelected: state.selectedFilters.containsKey(e.param)
                ? e.values.indexOf(
                    (state.selectedFilters[e.param] as FilterDataOneOfMultiple)
                        .selected)
                : -1,
          ),
          ..._buildFiltersSeparator()
        ],
      );
    } else if (e is GalleryFilterMultipleOfMultiple) {
      return Column(
        children: [
          MultipleOfMultipleWidget(
              paramName: e.paramName,
              items: e.values,
              selected: state.selectedFilters.containsKey(e.param)
                  ? (state.selectedFilters[e.param]
                          as FilterDataMultipleOfMultiple)
                      .selected
                  : [],
              onChanged: (selected) {
                if (selected.isEmpty) {
                  context.read<ServiceViewCubit>().removeFilter(e.param);
                } else {
                  context.read<ServiceViewCubit>().onFilterChanged(
                      e.param,
                      FilterDataMultipleOfMultiple(
                          selected: selected, filter: e));
                }
              }),
          ..._buildFiltersSeparator()
        ],
      );
    } else if (e is GalleryFilterOneOfAny) {
      return Column(
        children: [
          OneOfAnyWidget(
            selected: state.selectedFilters.containsKey(e.param)
                ? (state.selectedFilters[e.param] as FilterDataOneOfAny)
                    .selected
                : null,
            onChanged: (selected) {
              if (selected == null) {
                context.read<ServiceViewCubit>().removeFilter(e.param);
              } else {
                context.read<ServiceViewCubit>().onFilterChanged(
                    e.param, FilterDataOneOfAny(selected: selected, filter: e));
              }
            },
            paramName: e.paramName,
          ),
          ..._buildFiltersSeparator()
        ],
      );
    } else if (e is GalleryFilterSwitcher) {
      return Column(
        children: [
          SwitcherWidget(
              on: state.selectedFilters.containsKey(e.param)
                  ? (state.selectedFilters[e.param] as FilterDataSwitcher).on
                  : false,
              paramName: e.paramName,
              onChanged: (on) {
                context.read<ServiceViewCubit>().onFilterChanged(
                    e.param, FilterDataSwitcher(on: on, filter: e));
              },
              onValue: e.onValue,
              offValue: e.offValue),
          ..._buildFiltersSeparator()
        ],
      );
    }

    return const SizedBox();
  }

  List<Widget> _buildFiltersSeparator() {
    return [
      const SizedBox(
        height: 12,
      ),
      const Divider(color: AppColors.primary),
      const SizedBox(
        height: 12,
      ),
    ];
  }
}
