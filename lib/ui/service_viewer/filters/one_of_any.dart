import 'package:flutter/material.dart';

typedef OneOfAnyWidgetSelectedChanged = Function(String);

class OneOfAnyWidget extends StatefulWidget {
  const OneOfAnyWidget(
      {Key? key, required this.selected, required this.onChanged})
      : super(key: key);

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
      children: [
        TextFormField(
          controller: _editingController,
          enabled: _selected == null,
          decoration: InputDecoration(),
          onFieldSubmitted: (v) {
            _selected = v;
            setState(() {});
          },
        )
      ],
    );
  }
}
