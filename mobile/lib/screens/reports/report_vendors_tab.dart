import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../models/reports.dart';
import '../../models/vendor.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// 15_Raporlar_Firmalar — firma karşılaştırma tablosu (satılan, pay,
/// ortalama fiyat) + 4 renkli çoklu çizgi grafik.
class ReportVendorsTab extends StatefulWidget {
  const ReportVendorsTab({
    super.key,
    required this.range,
    required this.onRangeChanged,
  });

  final SalesRange range;
  final ValueChanged<SalesRange> onRangeChanged;

  @override
  State<ReportVendorsTab> createState() => _ReportVendorsTabState();
}

class _ReportVendorsTabState extends State<ReportVendorsTab> {
  late DashboardRepository _repository;

  Future<List<VendorStat>>? _stats;
  Future<Map<Vendor, List<DailySales>>>? _series;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  @override
  void didUpdateWidget(ReportVendorsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range) _load();
  }

  void _load() {
    setState(() {
      _stats = _repository.vendorStats();
      _series = _repository.vendorSeries(widget.range);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screenX,
          0,
          AppSpace.screenX,
          AppSpace.sectionGap,
        ),
        children: [
          SectionCard(
            title: 'Firma Karşılaştırma',
            child: AsyncSection<List<VendorStat>>(
              future: _stats,
              onRetry: _load,
              isEmpty: (stats) => stats.isEmpty,
              emptyMessage: 'Firma verisi yok',
              skeleton: const AppShimmer(
                child: Column(
                  children: [
                    SkeletonBox(height: 20),
                    SizedBox(height: AppSpace.cardGap),
                    SkeletonBox(height: 20),
                    SizedBox(height: AppSpace.cardGap),
                    SkeletonBox(height: 20),
                  ],
                ),
              ),
              builder: (context, stats) => _VendorTable(stats: stats),
            ),
          ),
          const SizedBox(height: AppSpace.sectionGap),
          SectionCard(
            title: 'Firma Bazlı Günlük Satış',
            trailing: DropdownChip(
              label: widget.range.label,
              sheetTitle: 'Aralık',
              options: [for (final range in SalesRange.values) range.label],
              onSelected: (value) => widget.onRangeChanged(
                SalesRange.values.firstWhere(
                  (range) => range.label == value,
                ),
              ),
            ),
            child: AsyncSection<Map<Vendor, List<DailySales>>>(
              future: _series,
              onRetry: _load,
              isEmpty: (series) => series.isEmpty,
              emptyMessage: 'Bu aralıkta satış kaydı yok',
              skeleton: const CardSkeleton(minHeight: 220),
              builder: (context, series) => VendorLineChart(series: series),
            ),
          ),
        ],
      ),
    );
  }
}

/// Karşılaştırma tablosu — başlık satırı + firma başına bir satır.
class _VendorTable extends StatelessWidget {
  const _VendorTable({required this.stats});

  final List<VendorStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(flex: 4, child: Text('Firma', style: AppTypography.micro)),
            Expanded(
              flex: 3,
              child: Text(
                'Satılan',
                style: AppTypography.micro,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Pay',
                style: AppTypography.micro,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Ort. Fiyat',
                style: AppTypography.micro,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.chipGap),
        const Divider(),
        for (final stat in stats)
          SizedBox(
            height: AppSize.dataRow,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Container(
                        width: AppSize.legendDot,
                        height: AppSize.legendDot,
                        decoration: BoxDecoration(
                          color: stat.vendor.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpace.chipGap),
                      Expanded(
                        child: Text(
                          stat.vendor.label,
                          style: AppTypography.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    Tr.number(stat.sold),
                    style: AppTypography.bodyStrong,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    Tr.percent(stat.pct),
                    style: AppTypography.caption,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    Tr.currency(stat.avgPrice),
                    style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
