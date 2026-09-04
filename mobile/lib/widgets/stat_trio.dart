import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 12 · StatTrio — SectionCard içinde 3 eşit kolon: caption etiket + numM
/// değer. Renkler sırasıyla textPrimary / success / danger.
class StatTrio extends StatelessWidget {
  const StatTrio({super.key, required this.items});

  final List<StatTrioItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const SizedBox(width: AppSpace.cardGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.label, style: AppTypography.caption),
                const SizedBox(height: AppSpace.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: AppTypography.numM.copyWith(color: item.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

@immutable
class StatTrioItem {
  const StatTrioItem({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color color;
}
