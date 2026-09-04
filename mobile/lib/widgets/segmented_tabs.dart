import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 15 · SegmentedTabs (underline) — eşit genişlikte sekmeler; aktif: primary
/// metin + 2 pt primary alt çizgi, pasif: textSecondary.
///
/// Kolaja sadık varsayılan konum ekranın **altı** ([SegmentedTabsPlacement.bottom]);
/// alternatif konum header altıdır.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.placement = SegmentedTabsPlacement.bottom,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final SegmentedTabsPlacement placement;

  @override
  Widget build(BuildContext context) {
    final tabs = SizedBox(
      height: AppSize.segmentedTabs,
      child: Row(
        children: [
          for (final (index, label) in labels.indexed)
            Expanded(
              child: _Tab(
                label: label,
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: placement == SegmentedTabsPlacement.bottom
              ? const BorderSide(
                  color: AppColors.border,
                  width: AppSize.borderWidth,
                )
              : BorderSide.none,
          bottom: placement == SegmentedTabsPlacement.underHeader
              ? const BorderSide(
                  color: AppColors.border,
                  width: AppSize.borderWidth,
                )
              : BorderSide.none,
        ),
      ),
      child: placement == SegmentedTabsPlacement.bottom
          ? SafeArea(top: false, child: tabs)
          : tabs,
    );
  }
}

enum SegmentedTabsPlacement {
  /// Kolaja sadık — ekranın altında.
  bottom,

  /// Alternatif — header'ın hemen altında.
  underHeader,
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.pressedOverlay,
        splashColor: AppColors.pressedOverlay,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: selected
                      ? AppTypography.bodyStrong.copyWith(color: color)
                      : AppTypography.body.copyWith(color: color),
                ),
              ),
            ),
            Container(
              height: AppSize.tabUnderline,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
