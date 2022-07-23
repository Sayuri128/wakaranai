import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef OneOfAnyWidgetSelectedChanged = Function(String?);

class OneOfAnyWidget extends StatefulWidget {
  const OneOfAnyWidget(
      {Key? key,
      required this.paramName,
      required this.selected,
      required this.onChanged})
      : super(key: key);

  final String paramName;
  final String? selected;
  final OneOfAnyWidgetSelectedChanged onChanged;

  @override
  State<OneOfAnyWidget> createState() => _OneOfAnyWidgetState();
}

class _OneOfAnyWidgetState extends State<OneOfAnyWidget> {
  late final TextEditingController _editingController;

  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _editingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.paramName,
          style: medium(size: 16),
        ),
        const SizedBox(
          height: 12,
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: _editingController,
              enabled: _selected == null,
              decoration: InputDecoration(
                  hintText: widget.paramName,
                  hintStyle: medium(
                      size: 14, color: AppColors.mainWhite.withOpacity(0.6)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: AppColors.primary)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                          color: AppColors.mainWhite.withOpacity(0.75))),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: AppColors.mainWhite)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: AppColors.primary))),
              onFieldSubmitted: (v) {
                _selected = v;
                widget.onChanged(_selected);
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _selected != null
                    ? InkWell(
                        onTap: () {
                          _selected = null;
                          _editingController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.close))
                    : null,
              ),
            )
          ],
        )
      ],
    );
  }
}
