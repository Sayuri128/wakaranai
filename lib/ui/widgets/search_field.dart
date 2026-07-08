import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();

  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus == _focused) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.overlay(_focused ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.overlay(0.08),
        ),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            color: _focused ? AppColors.primary : AppColors.mainGrey,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: medium(size: 16),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: medium(size: 16, color: AppColors.mainGrey),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 14);
              }
              return IconButton(
                splashRadius: 20,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.mainGrey,
                  size: 20,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
