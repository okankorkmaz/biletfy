import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 18 · BarChart — haftalık kovalar; bar genişliği 32, üst radius 4, `info`.
/// Üstte micro değer; veri olmayan kovada değer yerine "–".
/// Y ekseni `2K / 4K / 6K` biçiminde kısaltılır.
class SalesBarChart extends StatelessWidget {
  const SalesBarChart({
    super.key,
    required this.buckets,
    this.barColor = AppColors.info,
    this.height = 200,
  });

  final List<SalesBucket> buckets;
  final Color barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return SizedBox(height: height);

    final values = buckets
        .map((bucket) => bucket.sold ?? 0)
        .toList(growable: false);
    final maxSold = values.reduce((a, b) => a > b ? a : b);
    final step = _niceStep(maxSold);
    final maxY = (maxSold / step).ceil() * step + step * 0.3;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
              minY: 0,
              maxY: maxY.toDouble(),
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: AppSpace.xs,
                  getTooltipItem: (group, _, _, _) {
                    final bucket = buckets[group.x];
                    final sold = bucket.sold;
                    return BarTooltipItem(
                      sold == null ? '–' : Tr.number(sold),
                      AppTypography.micro.copyWith(
                        color: sold == null
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: step.toDouble(),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.border,
                  strokeWidth: AppSize.borderWidth,
                  dashArray: const [3, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: step.toDouble(),
                    reservedSize: 34,
                    getTitlesWidget: (value, _) {
                      // Tepedeki paylı maxY için etiket basma.
                      if (value % step != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpace.chipGap,
                        ),
                        child: Text(
                          Tr.axisCompact(value),
                          style: AppTypography.micro,
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, _) {
                      final index = value.round();
                      if (index < 0 || index >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      final bucket = buckets[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpace.chipGap),
                        child: Text(
                          Tr.dayRange(bucket.start, bucket.end),
                          style: AppTypography.micro,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (final (index, bucket) in buckets.indexed)
                  BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: const [0],
                    barRods: [
                      BarChartRodData(
                        toY: (bucket.sold ?? 0).toDouble(),
                        width: AppSize.chartBar,
                        color: barColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.barTop),
                        ),
                      ),
                    ],
                  ),
              ],
        ),
      ),
    );
  }

  static int _niceStep(int maxValue) {
    const candidates = [500, 1000, 2000, 5000, 10000, 20000, 50000];
    for (final candidate in candidates) {
      if (maxValue / candidate <= 5) return candidate;
    }
    return candidates.last;
  }
}
