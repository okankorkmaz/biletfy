import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/widgets.dart';
import 'report_month_picker.dart';

/// 05_Raporlar_Satis — donut (satış adedi) + aylık satış trendi.
class ReportSalesTab extends StatefulWidget {
  const ReportSalesTab({
    super.key,
    required this.month,
    required this.onMonthChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  State<ReportSalesTab> createState() => _ReportSalesTabState();
}

class _ReportSalesTabState extends State<ReportSalesTab> {
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
  void didUpdateWidget(ReportSalesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) _load();
  }

  void _load() {
    setState(() {
      _breakdown = _repository.vendorBreakdown();
      _buckets = _repository.monthlyBuckets(widget.month);
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
            title: 'Satış Dağılımı (Tüm Etkinlikler)',
            trailing: ReportMonthPicker(
              month: widget.month,
              onChanged: widget.onMonthChanged,
              asRange: true,
            ),
            child: AsyncSection<List<VendorShare>>(
              future: _breakdown,
              onRetry: _load,
              isEmpty: (shares) => shares.isEmpty,
              emptyMessage: 'Bu dönemde satış kaydı yok',
              skeleton: const DonutSkeleton(),
              builder: (context, shares) => VendorDonutChart(
                shares: shares,
                centerValue: shares.fold(
                  0,
                  (total, share) => total + share.sold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sectionGap),
          SectionCard(
            title: 'Aylık Satış Trendi',
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
                  '${Tr.monthYear(widget.month)} için satış verisi yok',
              skeleton: const CardSkeleton(minHeight: 200),
              builder: (context, buckets) => SalesBarChart(buckets: buckets),
            ),
          ),
        ],
      ),
    );
  }
}
