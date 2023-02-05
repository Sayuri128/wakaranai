import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef OneOfMultipleSelectedItemChanged = Function(String?);

class OneOfMultipleWidget extends StatefulWidget {
  const OneOfMultipleWidget(
      {Key? key,
      required this.paramName,
      required this.items,
      required this.defaultSelected,
      required this.onChanged})
      : super(key: key);

  final String paramName;
  final List<String> items;
  final int defaultSelected;
  final OneOfMultipleSelectedItemChanged onChanged;

  @override
  State<OneOfMultipleWidget> createState() => _OneOfMultipleWidgetState();
}

class _OneOfMultipleWidgetState extends State<OneOfMultipleWidget> {
  int _indexOfSelected = -1;

  @override
  initState() {
    super.initState();

    _indexOfSelected = widget.defaultSelected;
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

  Widget _buildItem(String item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color:
              _indexOfSelected != -1 && widget.items[_indexOfSelected] == item
                  ? AppColors.secondary
                  : AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
                color: _indexOfSelected != -1 &&
                        widget.items[_indexOfSelected] == item
                    ? AppColors.secondary.withOpacity(0.5)
                    : AppColors.mainBlack.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 1)
          ]),
      child: InkWell(
        onTap: () {
          if (_indexOfSelected != -1 &&
              widget.items[_indexOfSelected] == item) {
            _indexOfSelected = -1;
          } else {
            _indexOfSelected = widget.items.indexOf(item);
          }
          if (_indexOfSelected == -1) {
            widget.onChanged(null);
          } else {
            widget.onChanged(widget.items[_indexOfSelected]);
          }
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item, style: medium()),
        ),
      ),
    );
  }
}
