import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class PrimaryInputWidget extends StatelessWidget {
  const PrimaryInputWidget(
      {super.key,
      required this.controller,
      required this.label,
      this.validator});

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        cursorColor: AppColors.primary,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
            labelStyle: regular(size: 16, color: AppColors.mainWhite),
            labelText: label,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 1)),
            errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.red, width: 1)),
            focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.red, width: 1)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1))));
  }
}
