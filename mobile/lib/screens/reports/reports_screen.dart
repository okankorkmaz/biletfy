import 'package:flutter/material.dart';

import '../../data/dashboard_repository.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../widgets/widgets.dart';
import 'report_occupancy_tab.dart';
import 'report_revenue_tab.dart';
import 'report_sales_tab.dart';
import 'report_vendors_tab.dart';

/// Raporlar sekmeleri — 05 · 13 · 14 · 15.
enum ReportTab {
  satis('Satış'),
  gelir('Gelir'),
  doluluk('Doluluk'),
  firmalar('Firmalar');

  const ReportTab(this.label);

  final String label;
}

/// 05_Raporlar — kök sekme, 4 filtre chip'i.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportTab _tab = ReportTab.satis;

  /// Rapor filtrelerinin ortak dönemi.
  DateTime _month = DateTime(2026, 5);
  SalesRange _range = SalesRange.gun7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.root(
        title: 'Raporlar',
        onMenuTap: widget.onOpenDrawer,
        action: TopBarAction(
          icon: AppIcons.share,
          tooltip: 'Dışa aktar',
          onTap: () {},
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpace.titleGap),
          FilterChipRow(
            labels: [for (final tab in ReportTab.values) tab.label],
            selectedIndex: ReportTab.values.indexOf(_tab),
            onSelected: (index) =>
                setState(() => _tab = ReportTab.values[index]),
          ),
          const SizedBox(height: AppSpace.cardPadding),
          Expanded(
            child: switch (_tab) {
              ReportTab.satis => ReportSalesTab(
                month: _month,
                onMonthChanged: (month) => setState(() => _month = month),
              ),
              ReportTab.gelir => ReportRevenueTab(
                month: _month,
                onMonthChanged: (month) => setState(() => _month = month),
              ),
              ReportTab.doluluk => const ReportOccupancyTab(),
              ReportTab.firmalar => ReportVendorsTab(
                range: _range,
                onRangeChanged: (range) => setState(() => _range = range),
              ),
            },
          ),
        ],
      ),
    );
  }
}
