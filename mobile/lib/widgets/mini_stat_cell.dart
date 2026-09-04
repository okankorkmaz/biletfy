import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 08 · MiniStatCell — surfaceAlt, radius 12, padding 10.
/// Üstte micro etiket (opsiyonel 12 pt ikon), altta 17 SemiBold success değer.
class MiniStatCell extends StatelessWidget {
  const MiniStatCell({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor = AppColors.success,
  });

  final String label;
  final String value;

  /// Etiketin solundaki küçük ikon (ör. "Dün" hücresindeki saat).
  final IconData? icon;

  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.cellR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppIconSize.chevron,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpace.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.micro,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.titleM.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4'lü eşit yatay grid, gap 8.
class MiniStatRow extends StatelessWidget {
  const MiniStatRow({super.key, required this.cells});

  final List<MiniStatCell> cells;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, cell) in cells.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpace.chipGap),
            Expanded(child: cell),
          ],
        ],
      ),
    );
  }
}
