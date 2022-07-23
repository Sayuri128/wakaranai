import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef MultipleOfAnyWidgetSelectedItemChanged = Function(
    List<String> selectedItems);

class MultipleOfAnyWidget extends StatefulWidget {
  const MultipleOfAnyWidget(
      {Key? key,
      required this.parameterName,
      required this.initSelectedItems,
      required this.onChanged})
      : super(key: key);

  final String parameterName;
  final List<String> initSelectedItems;
  final MultipleOfAnyWidgetSelectedItemChanged onChanged;

  @override
  State<MultipleOfAnyWidget> createState() => _MultipleOfAnyWidgetState();
}

class _MultipleOfAnyWidgetState extends State<MultipleOfAnyWidget> {
  final List<String> _selectedItems = [];
  late final TextEditingController inputController;

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController();
    _selectedItems.addAll(widget.initSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.parameterName,
          style: medium(size: 16),
        ),
        const SizedBox(
          height: 12,
        ),
        Wrap(
          runSpacing: 12,
          spacing: 12,
          children: _selectedItems.map(_buildSelectedItem).toList(),
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          controller: inputController,
          onFieldSubmitted: (v) {
            if (_selectedItems.where((element) => element == v).isEmpty) {
              _selectedItems.add(v);
            }

            widget.onChanged(_selectedItems);

            inputController.clear();
          },
          decoration: InputDecoration(
              hintText: widget.parameterName,
              hintStyle:
                  medium(size: 14, color: AppColors.mainWhite.withOpacity(0.6)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide:
                      BorderSide(color: AppColors.mainWhite.withOpacity(0.75))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary))),
        )
      ],
    );
  }

  Widget _buildSelectedItem(String value) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
                color: AppColors.mainBlack.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 1)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: medium()),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: 1,
              height: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(
              width: 4,
            ),
            InkWell(
              child: const Icon(
                Icons.close,
                color: AppColors.red,
                size: 16,
              ),
              onTap: () {
                _selectedItems.remove(value);
                widget.onChanged(_selectedItems);
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
