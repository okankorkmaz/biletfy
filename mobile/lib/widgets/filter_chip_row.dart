import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 03 · FilterChipRow — yatay kaydırılabilir pill'ler, h 32, padding 14,
/// gap 8. Aktif: primary bg + onPrimary · pasif: surfaceAlt + textSecondary.
///
/// Durumlar: default · pressed (%8 beyaz overlay, ölçek yok) · disabled (%40).
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.disabledIndexes = const {},
    this.padding,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Devre dışı bırakılacak chip indeksleri.
  final Set<int> disabledIndexes;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.filterChip,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: AppSpace.screenX),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.chipGap),
        itemBuilder: (context, index) => AppFilterChip(
          label: labels[index],
          selected: index == selectedIndex,
          enabled: !disabledIndexes.contains(index),
          onTap: () => onSelected(index),
        ),
      ),
    );
  }
}

/// Tek bir filtre chip'i — galeride tek tek de kullanılır.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: AppSize.filterChip,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.filterChipPaddingX,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceAlt,
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
      ),
    );

    if (!enabled) {
      return Opacity(opacity: AppColors.disabledOpacity, child: chip);
    }

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.pillR,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pillR,
          highlightColor: AppColors.pressedOverlay,
          splashColor: AppColors.pressedOverlay,
          child: chip,
        ),
      ),
    );
  }
}
