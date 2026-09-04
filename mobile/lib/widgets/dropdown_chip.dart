import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 04 · DropdownChip — h 28, surfaceAlt, radius 999, caption Medium +
/// chevron-down 14. Kart başlığının sağına hizalanır; basınca bottom sheet
/// açar.
class DropdownChip extends StatelessWidget {
  const DropdownChip({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    this.sheetTitle,
  });

  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;

  /// Bottom sheet başlığı; verilmezse başlık gösterilmez.
  final String? sheetTitle;

  Future<void> _openSheet(BuildContext context) async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sheetTitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.cardPadding,
                  AppSpace.cardPadding,
                  AppSpace.cardPadding,
                  AppSpace.titleGap,
                ),
                child: Text(sheetTitle!, style: AppTypography.titleM),
              ),
            for (final option in options)
              ListTile(
                minTileHeight: AppSize.minTouch,
                title: Text(option, style: AppTypography.body),
                selected: option == label,
                selectedColor: AppColors.primary,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (selection != null) onSelected(selection);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: AppRadius.pillR,
      child: InkWell(
        onTap: () => _openSheet(context),
        borderRadius: AppRadius.pillR,
        highlightColor: AppColors.pressedOverlay,
        splashColor: AppColors.pressedOverlay,
        child: Container(
          height: AppSize.dropdownChip,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.dropdownChipPaddingX,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              const Icon(
                AppIcons.chevronDown,
                size: AppIconSize.chevron,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
