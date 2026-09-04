import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';
import 'report_month_picker.dart';

/// 13_Raporlar_Gelir — ₺ bazlı donut (firma payı gelir olarak) +
/// haftalık brüt gelir bar grafiği.
class ReportRevenueTab extends StatefulWidget {
  const ReportRevenueTab({
    super.key,
    required this.month,
    required this.onMonthChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  State<ReportRevenueTab> createState() => _ReportRevenueTabState();
}

class _ReportRevenueTabState extends State<ReportRevenueTab> {
  late DashboardRepository _repository;

  Future<List<VendorShare>>? _breakdown;
  Future<List<SalesBucket>>? _buckets;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  @override
  void didUpdateWidget(ReportRevenueTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) _load();
  }

  void _load() {
    setState(() {
      _breakdown = _repository.revenueBreakdown();
      _buckets = _repository.revenueBuckets(widget.month);
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
            title: 'Gelir Dağılımı (Tüm Etkinlikler)',
            trailing: ReportMonthPicker(
              month: widget.month,
              onChanged: widget.onMonthChanged,
              asRange: true,
            ),
            child: AsyncSection<List<VendorShare>>(
              future: _breakdown,
              onRetry: _load,
              isEmpty: (shares) => shares.isEmpty,
              emptyMessage: 'Bu dönemde gelir kaydı yok',
              skeleton: const DonutSkeleton(),
              builder: (context, shares) => _RevenueDonut(shares: shares),
            ),
          ),
          const SizedBox(height: AppSpace.sectionGap),
          SectionCard(
            title: 'Haftalık Brüt Gelir',
            trailing: ReportMonthPicker(
              month: widget.month,
              onChanged: widget.onMonthChanged,
            ),
            child: AsyncSection<List<SalesBucket>>(
              future: _buckets,
              onRetry: _load,
              isEmpty: (buckets) =>
                  buckets.every((bucket) => bucket.sold == null),
              emptyMessage:
                  '${Tr.monthYear(widget.month)} için gelir verisi yok',
              skeleton: const CardSkeleton(minHeight: 200),
              builder: (context, buckets) => SalesBarChart(
                buckets: buckets,
                barColor: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gelir donut'u — merkezde toplam ₺, legend değerleri de ₺ biçiminde.
class _RevenueDonut extends StatelessWidget {
  const _RevenueDonut({required this.shares});

  final List<VendorShare> shares;

  @override
  Widget build(BuildContext context) {
    final total = shares.fold(0, (sum, share) => sum + share.sold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: AppSize.donutDiameter,
            height: AppSize.donutDiameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VendorDonutChart(
                  shares: shares,
                  centerValue: 0,
                  legendVisible: false,
                  centerVisible: false,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        Tr.currency(total),
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text('Brüt Gelir', style: AppTypography.micro),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.cardPadding),
        for (final (index, share) in shares.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpace.cardGap),
          Row(
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
                child: Text(share.vendor.label, style: AppTypography.label),
              ),
              Text(
                Tr.currency(share.sold),
                style: AppTypography.labelStrong,
              ),
              SizedBox(
                width: AppSize.legendPctColumn,
                child: Text(
                  '(${Tr.percent(share.pct)})',
                  style: AppTypography.micro,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
