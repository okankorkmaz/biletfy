import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 17 · LineChart — çizgi 2 pt success; noktalar 6 pt (dolu success,
/// 2 pt bg kenar); nokta üstünde micro değer; yatay kesikli grid `border`;
/// x etiketleri iki satır (gün numarası + ay adı).
///
/// [showPointLabels] 30/90 gün varyantlarında kapatılır.
class SalesLineChart extends StatelessWidget {
  const SalesLineChart({
    super.key,
    required this.series,
    this.showPointLabels = true,
    this.height = 220,
  });

  final List<DailySales> series;

  /// Nokta üstü değer etiketleri — seyrek veri setlerinde gizlenir.
  final bool showPointLabels;

  final double height;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return SizedBox(height: height);

    final maxSold = series.map((point) => point.sold).reduce(
      (a, b) => a > b ? a : b,
    );
    final step = _niceStep(maxSold);
    final maxY = (maxSold / step).ceil() * step + step * 0.35;

    // Etiketler seyrek veri setinde kalabalıklaşmasın diye aralıklanır.
    final labelStride = (series.length / 7).ceil();

    final barData = LineChartBarData(
      spots: [
        for (final (index, point) in series.indexed)
          FlSpot(index.toDouble(), point.sold.toDouble()),
      ],
      isCurved: false,
      color: AppColors.success,
      barWidth: AppSize.chartLine,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: AppSize.chartDot / 2,
          color: AppColors.success,
          strokeWidth: AppSize.chartLine,
          strokeColor: AppColors.bg,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.success.withValues(alpha: 0.08),
      ),
    );

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY.toDouble(),
          minX: 0,
          maxX: (series.length - 1).toDouble(),
          clipData: const FlClipData.none(),
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
          lineTouchData: LineTouchData(
            enabled: false,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: AppSpace.xs,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    Tr.number(spot.y),
                    AppTypography.micro.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step.toDouble(),
                reservedSize: 42,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(right: AppSpace.chipGap),
                  child: Text(
                    Tr.number(value),
                    style: AppTypography.micro,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 34,
                getTitlesWidget: (value, _) {
                  final index = value.round();
                  if (index < 0 || index >= series.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % labelStride != 0 && index != series.length - 1) {
                    return const SizedBox.shrink();
                  }
                  final date = series[index].date;
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
          lineBarsData: [barData],
          showingTooltipIndicators: showPointLabels
              ? [
                  for (var index = 0; index < series.length; index++)
                    ShowingTooltipIndicators([
                      LineBarSpot(
                        barData,
                        0,
                        FlSpot(
                          index.toDouble(),
                          series[index].sold.toDouble(),
                        ),
                      ),
                    ]),
                ]
              : const [],
        ),
      ),
    );
  }

  /// Y ekseni adımını verinin büyüklüğüne göre seçer (200 · 500 · 1000 …).
  static int _niceStep(int maxValue) {
    const candidates = [50, 100, 200, 500, 1000, 2000, 5000, 10000];
    for (final candidate in candidates) {
      if (maxValue / candidate <= 5) return candidate;
    }
    return candidates.last;
  }
}
