import 'package:flutter/material.dart' hide DateTimeRange;

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// 01_AnaSayfa — kök sekme.
///
/// Üstten alta: TopBar (logo + zil) · "Genel Bakış" + dönem chip'i ·
/// KPI 2×2 · Satış Dağılımı donut · Günlük Satış Özeti.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenEvents,
    this.onOpenReports,
    this.onOpenDailySales,
    this.onOpenNotifications,
  });

  final VoidCallback? onOpenEvents;
  final VoidCallback? onOpenReports;
  final VoidCallback? onOpenDailySales;
  final VoidCallback? onOpenNotifications;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DashboardRepository _repository;

  OverviewPeriod _period = OverviewPeriod.bugun;
  int _summaryDays = 7;

  Future<Overview>? _overview;
  Future<List<VendorShare>>? _breakdown;
  Future<DailySalesSummary>? _summary;

  DateTimeRange? get _periodRange {
    final today = _repository.referenceDate;
    return switch (_period) {
      OverviewPeriod.bugun => DateTimeRange(start: today, end: today),
      OverviewPeriod.buHafta => DateTimeRange(
        start: today.subtract(const Duration(days: 6)),
        end: today,
      ),
      OverviewPeriod.buAy => DateTimeRange(
        start: DateTime(today.year, today.month),
        end: today,
      ),
      OverviewPeriod.tumu => null,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _overview = _repository.overview(_period);
      _breakdown = _repository.vendorBreakdown(range: _periodRange);
      _summary = _repository.dailySummary(_summaryDays);
    });
  }

  void _selectPeriod(OverviewPeriod period) {
    setState(() {
      _period = period;
      _overview = _repository.overview(period);
      _breakdown = _repository.vendorBreakdown(range: _periodRange);
    });
  }

  void _selectSummaryDays(int days) {
    setState(() {
      _summaryDays = days;
      _summary = _repository.dailySummary(days);
    });
  }

  Future<void> _refresh() async {
    _load();
    await Future.wait([_overview!, _breakdown!, _summary!])
        .catchError((_) => <Object>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.home(
        action: TopBarAction(
          icon: AppIcons.bell,
          tooltip: 'Bildirimler',
          onTap: widget.onOpenNotifications,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screenX,
            AppSpace.titleGap,
            AppSpace.screenX,
            AppSpace.sectionGap,
          ),
          children: [
            _OverviewHeader(
              period: _period,
              onPeriodChanged: _selectPeriod,
              updatedAt: _overview,
            ),
            const SizedBox(height: AppSpace.titleGap),

            // --- KPI 2×2 ---
            AsyncSection<Overview>(
              future: _overview,
              onRetry: _load,
              skeleton: const _KpiSkeleton(),
              builder: (context, overview) => KpiGrid(
                cards: [
                  KpiCard(
                    icon: AppIcons.totalEvents,
                    color: AppColors.primary,
                    label: 'Toplam Etkinlik',
                    value: Tr.number(overview.totalEvents),
                    onTap: widget.onOpenEvents,
                  ),
                  KpiCard(
                    icon: AppIcons.totalSold,
                    color: AppColors.info,
                    label: 'Toplam Satılan',
                    value: Tr.number(overview.totalSold),
                  ),
                  KpiCard(
                    icon: AppIcons.revenue,
                    color: AppColors.success,
                    label: 'Toplam Gelir',
                    value: Tr.currency(overview.totalRevenue),
                  ),
                  KpiCard(
                    icon: AppIcons.occupancy,
                    color: AppColors.purple,
                    label: 'Ortalama Doluluk',
                    value: Tr.percent(overview.avgOccupancy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            // --- Satış Dağılımı donut ---
            SectionCard(
              title: 'Satış Dağılımı (Tüm Etkinlikler)',
              onTap: widget.onOpenReports,
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

            // --- Günlük Satış Özeti ---
            SectionCard(
              title: 'Günlük Satış Özeti',
              trailing: DropdownChip(
                label: '$_summaryDays Gün',
                sheetTitle: 'Aralık',
                options: const ['7 Gün', '30 Gün', '90 Gün'],
                onSelected: (value) =>
                    _selectSummaryDays(int.parse(value.split(' ').first)),
              ),
              onTap: widget.onOpenDailySales,
              child: AsyncSection<DailySalesSummary>(
                future: _summary,
                onRetry: _load,
                skeleton: const _SummarySkeleton(),
                builder: (context, summary) => MiniStatRow(
                  cells: [
                    MiniStatCell(
                      label: 'Dün',
                      icon: AppIcons.clock,
                      value: Tr.signedNumber(summary.yesterday),
                    ),
                    MiniStatCell(
                      label: 'Bugün',
                      value: Tr.signedNumber(summary.today),
                    ),
                    MiniStatCell(
                      label: 'Son $_summaryDays Gün',
                      value: Tr.signedNumber(summary.last7Days),
                    ),
                    MiniStatCell(
                      label: 'Günlük Ort.',
                      value: Tr.signedNumber(summary.dailyAverage),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Genel Bakış" satırı + dönem chip'i; altında son güncelleme damgası.
class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.period,
    required this.onPeriodChanged,
    required this.updatedAt,
  });

  final OverviewPeriod period;
  final ValueChanged<OverviewPeriod> onPeriodChanged;
  final Future<Overview>? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Genel Bakış', style: AppTypography.titleM)),
            DropdownChip(
              label: period.label,
              sheetTitle: 'Dönem',
              options: [
                for (final option in OverviewPeriod.values) option.label,
              ],
              onSelected: (value) => onPeriodChanged(
                OverviewPeriod.values.firstWhere(
                  (option) => option.label == value,
                ),
              ),
            ),
          ],
        ),
        FutureBuilder<Overview>(
          future: updatedAt,
          builder: (context, snapshot) {
            final overview = snapshot.data;
            if (overview == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: Text(
                'Son güncelleme ${Tr.shortStamp(overview.updatedAt)}',
                style: AppTypography.caption,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: CardSkeleton()),
            SizedBox(width: AppSpace.cardGap),
            Expanded(child: CardSkeleton()),
          ],
        ),
        SizedBox(height: AppSpace.cardGap),
        Row(
          children: [
            Expanded(child: CardSkeleton()),
            SizedBox(width: AppSpace.cardGap),
            Expanded(child: CardSkeleton()),
          ],
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            if (index > 0) const SizedBox(width: AppSpace.chipGap),
            const Expanded(child: SkeletonBox(height: 58, radius: 12)),
          ],
        ],
      ),
    );
  }
}
