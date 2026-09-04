import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// İkon konteyneri — 32×32, radius 10, tint arka plan, 18 pt ikon.
/// Tint kuralı: arka plan rengin %15'i, ikon rengin kendisi.
class TintedIconBox extends StatelessWidget {
  const TintedIconBox({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.iconBox,
      height: AppSize.iconBox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: AppRadius.iconR,
      ),
      child: Icon(icon, size: AppIconSize.kpi, color: color),
    );
  }
}

/// 05 · KpiCard — h ~88 · sol üstte 32×32 tint'li ikon konteyneri, sağında
/// caption etiket, altta numL değer.
///
/// Renk varyantları: primary / info / success / purple.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;

  /// İkon konteynerinin tint rengi.
  final Color color;

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppSpace.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TintedIconBox(icon: icon, color: color),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTypography.numL),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              borderRadius: AppRadius.cardR,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.cardR,
                highlightColor: AppColors.pressedOverlay,
                splashColor: AppColors.pressedOverlay,
                child: content,
              ),
            ),
    );
  }
}

/// KPI kartlarının 2×2 yerleşimi — gap 12.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.cards});

  final List<KpiCard> cards;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < cards.length; index += 2) {
      final left = cards[index];
      final right = index + 1 < cards.length ? cards[index + 1] : null;
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: AppSpace.cardGap));
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: AppSpace.cardGap),
              Expanded(child: right ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}
