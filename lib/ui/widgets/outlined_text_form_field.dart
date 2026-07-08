import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class OutlinedTextFormField extends StatelessWidget {
  const OutlinedTextFormField({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String title;
  final String hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      cursorColor: AppColors.primary,
      style: medium(size: 15),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: regular(size: 14, color: AppColors.mainGrey),
        floatingLabelStyle: medium(size: 14, color: AppColors.primary),
        hintText: hint,
        hintStyle: regular(size: 14, color: AppColors.mainGrey),
        errorStyle: regular(size: 12, color: AppColors.red),
        filled: true,
        fillColor: AppColors.overlay(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: _border(AppColors.overlay(0.10)),
        focusedBorder: _border(AppColors.primary, width: 1.5),
        errorBorder: _border(AppColors.red),
        focusedErrorBorder: _border(AppColors.red, width: 1.5),
        disabledBorder: _border(AppColors.overlay(0.06)),
      ),
    );
  }
}
