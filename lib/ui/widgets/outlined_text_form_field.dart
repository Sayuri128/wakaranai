import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        cursorColor: AppColors.secondary,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
            color: AppColors.mainWhite,
          ),
          errorStyle: const TextStyle(
            color: AppColors.red,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.mainGrey,
          ),
          focusColor: AppColors.secondary,
          iconColor: AppColors.secondary,
          fillColor: AppColors.secondary,
          hoverColor: AppColors.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.secondary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.secondary,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.red,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.secondary.withOpacity(0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.secondary,
            ),
          ),
        ));
  }
}
