import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 16 · HeroNumber — üstte caption etiket; displayNum success değer +
/// yanında micro birim; sağda trend rozeti (ikon + label SemiBold) ve
/// altında micro karşılaştırma notu.
class HeroNumber extends StatelessWidget {
  const HeroNumber({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.trendPct,
    required this.trendNote,
  });

  final String label;

  /// Ham değer — `+2.846` biçimine burada çevrilir.
  final int value;

  /// Değerin yanındaki birim (ör. `bilet`).
  final String unit;

  /// Önceki döneme göre değişim (`18.6` → `%18,6`).
  final double trendPct;

  /// Rozetin altındaki açıklama (ör. `(Önceki 7 güne göre)`).
  final String trendNote;

  @override
  Widget build(BuildContext context) {
    final isUp = trendPct >= 0;
    final trendColor = isUp ? AppColors.success : AppColors.danger;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: AppSpace.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Tr.signedNumber(value),
                        style: AppTypography.displayNum.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(unit, style: AppTypography.micro),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.cardGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? AppIcons.trendUp : AppIcons.trendDown,
                  size: AppIconSize.chevron,
                  color: trendColor,
                ),
                const SizedBox(width: AppSpace.xs),
                Text(
                  Tr.signedPercent(trendPct),
                  style: AppTypography.labelStrong.copyWith(color: trendColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xxs),
            Text(trendNote, style: AppTypography.micro),
          ],
        ),
      ],
    );
  }
}
