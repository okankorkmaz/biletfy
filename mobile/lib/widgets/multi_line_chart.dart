import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../models/vendor.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Firma bazlı çoklu çizgi grafik — 17 numaralı LineChart'ın 4 seriyle
/// çalışan varyantı. Her seri `vendor.*` rengini kullanır; nokta etiketi yok.
class VendorLineChart extends StatelessWidget {
  const VendorLineChart({
    super.key,
    required this.series,
    this.height = 220,
  });

  final Map<Vendor, List<DailySales>> series;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return SizedBox(height: height);

    final length = series.values.first.length;
    final maxSold = series.values
        .expand((points) => points)
        .map((point) => point.sold)
        .reduce((a, b) => a > b ? a : b);
    final step = _niceStep(maxSold);
    final maxY = (maxSold / step).ceil() * step + step * 0.25;
    final dates = series.values.first;
    final labelStride = (length / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY.toDouble(),
              minX: 0,
              maxX: (length - 1).toDouble(),
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
              lineTouchData: const LineTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: step.toDouble(),
                    reservedSize: 38,
                    getTitlesWidget: (value, _) {
                      // Tepedeki paylı maxY için etiket basma.
                      if (value % step != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpace.chipGap,
                        ),
                        child: Text(
                          Tr.number(value),
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
                    reservedSize: 34,
                    getTitlesWidget: (value, _) {
                      final index = value.round();
                      if (index < 0 || index >= dates.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % labelStride != 0 &&
                          index != dates.length - 1) {
                        return const SizedBox.shrink();
                      }
                      final date = dates[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${date.day}', style: AppTypography.micro),
                            Text(
                              DateFormat('MMMM', Tr.locale).format(date),
                              style: AppTypography.micro,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                for (final entry in series.entries)
                  LineChartBarData(
                    spots: [
                      for (final (index, point) in entry.value.indexed)
                        FlSpot(index.toDouble(), point.sold.toDouble()),
                    ],
                    isCurved: false,
                    color: entry.key.color,
                    barWidth: AppSize.chartLine,
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.cardPadding),
        Wrap(
          spacing: AppSpace.cardPadding,
          runSpacing: AppSpace.chipGap,
          children: [
            for (final vendor in series.keys)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSize.legendDot,
                    height: AppSize.legendDot,
                    decoration: BoxDecoration(
                      color: vendor.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(vendor.label, style: AppTypography.label),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static int _niceStep(int maxValue) {
    const candidates = [25, 50, 100, 200, 500, 1000, 2000];
    for (final candidate in candidates) {
      if (maxValue / candidate <= 5) return candidate;
    }
    return candidates.last;
  }
}
