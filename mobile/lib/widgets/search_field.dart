import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Arama alanı — surfaceAlt, radius 12, sol arama ikonu, dolduğunda temizle.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Etkinlik veya mekan ara',
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        style: AppTypography.body,
        cursorColor: AppColors.primary,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          hintText: hintText,
          hintStyle: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            AppIcons.search,
            size: AppIconSize.inline,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppSize.minTouch,
            minHeight: AppSize.minTouch,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    AppIcons.close,
                    size: AppIconSize.chip,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Temizle',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.listCardPadding,
            vertical: AppSpace.listCardPadding,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.cellR,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.cellR,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.cellR,
            borderSide: const BorderSide(
              color: AppColors.border,
              width: AppSize.borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
