import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/vendor.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 07 · DonutChart — çap 120, kalınlık 24, segmentler arası 2 pt boşluk,
/// `vendor.*` renkleri. Merkezde numM değer + micro etiket.
///
/// Sağda legend: 8 pt renkli nokta + isim + değer + "(%…)".
class VendorDonutChart extends StatelessWidget {
  const VendorDonutChart({
    super.key,
    required this.shares,
    required this.centerValue,
    this.centerLabel = 'Toplam Bilet',
    this.legendVisible = true,
    this.centerVisible = true,
  });

  final List<VendorShare> shares;

  /// Merkezdeki toplam.
  final int centerValue;

  final String centerLabel;

  /// Sağdaki legend kolonu — merkez metni kendi çizilecekse kapatılır.
  final bool legendVisible;

  /// Halkanın ortasındaki değer + etiket.
  final bool centerVisible;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: AppSize.donutDiameter,
          height: AppSize.donutDiameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: AppSize.borderWidth * 2,
                  centerSpaceRadius:
                      AppSize.donutDiameter / 2 - AppSize.donutThickness,
                  startDegreeOffset: -90,
                  borderData: FlBorderData(show: false),
                  pieTouchData: PieTouchData(enabled: false),
                  sections: [
                    for (final share in shares)
                      PieChartSectionData(
                        value: share.pct,
                        color: share.vendor.color,
                        radius: AppSize.donutThickness,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              if (centerVisible)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Tr.number(centerValue), style: AppTypography.numM),
                    Text(centerLabel, style: AppTypography.micro),
                  ],
                ),
            ],
          ),
        ),
        if (legendVisible) ...[
          const SizedBox(width: AppSpace.sectionGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, share) in shares.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpace.cardGap),
                  _LegendRow(share: share),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.share});

  final VendorShare share;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSize.legendDot,
          height: AppSize.legendDot,
          decoration: BoxDecoration(
            color: share.vendor.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpace.chipGap),
        Expanded(
          child: Text(
            share.vendor.label,
            style: AppTypography.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(Tr.number(share.sold), style: AppTypography.labelStrong),
        SizedBox(
          width: AppSize.legendPctColumn,
          child: Text(
            '(${Tr.percent(share.pct)})',
            style: AppTypography.micro,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
