import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef MultipleOfMultipleSelectedItemChanged = Function(List<List<String>>);

class MultipleOfMultipleWidget extends StatefulWidget {
  const MultipleOfMultipleWidget(
      {Key? key,
      required this.paramName,
      required this.items,
      required this.selected,
      required this.onChanged})
      : super(key: key);

  final String paramName;
  final List<List<String>> items;
  final List<List<String>> selected;
  final MultipleOfMultipleSelectedItemChanged onChanged;

  @override
  State<MultipleOfMultipleWidget> createState() =>
      _MultipleOfMultipleWidgetState();
}

class _MultipleOfMultipleWidgetState extends State<MultipleOfMultipleWidget> {
  final List<List<String>> _selectedItem = [];

  @override
  initState() {
    super.initState();

    _selectedItem.addAll(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.paramName,
          style: medium(size: 16),
        ),
        const SizedBox(
          height: 12,
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.items.map(_buildItem).toList(),
        )
      ],
    );
  }

  Widget _buildItem(List<String> item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: widget.selected.contains(item)
              ? AppColors.secondary
              : AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
                color: widget.selected.contains(item)
                    ? AppColors.secondary.withOpacity(0.5)
                    : AppColors.mainBlack.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 1)
          ]),
      child: InkWell(
        onTap: () {
          if (_selectedItem.contains(item)) {
            _selectedItem.remove(item);
          } else {
            _selectedItem.add(item);
          }

          widget.onChanged(_selectedItem);

          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item[1], style: medium()),
        ),
      ),
    );
  }
}
