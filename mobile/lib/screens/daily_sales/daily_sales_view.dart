import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/widgets.dart';

/// Günlük satış gövdesi — hem 04_GunlukSatis push ekranında hem de
/// 11_EtkinlikDetayi_GunlukSatis sekmesinde aynı gövde kullanılır.
///
/// [eventId] verilirse seri o etkinliğe süzülür.
class DailySalesView extends StatefulWidget {
  const DailySalesView({super.key, this.eventId});

  final String? eventId;

  @override
  State<DailySalesView> createState() => _DailySalesViewState();
}

class _DailySalesViewState extends State<DailySalesView> {
  late DashboardRepository _repository;

  SalesRange _range = SalesRange.gun7;
  Future<List<DailySales>>? _series;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _series = _repository.dailySales(_range, eventId: widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpace.titleGap),
        FilterChipRow(
          labels: [for (final range in SalesRange.values) range.label],
          selectedIndex: SalesRange.values.indexOf(_range),
          onSelected: (index) {
            setState(() => _range = SalesRange.values[index]);
            _load();
          },
        ),
        const SizedBox(height: AppSpace.cardPadding),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _load(),
            child: AsyncSection<List<DailySales>>(
              future: _series,
              onRetry: _load,
              isEmpty: (series) => series.isEmpty,
              emptyMessage: 'Bu aralıkta satış kaydı yok',
              skeleton: const _DailySalesSkeleton(),
              builder: (context, series) => _DailySalesBody(
                series: series,
                range: _range,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailySalesBody extends StatelessWidget {
  const _DailySalesBody({required this.series, required this.range});

  final List<DailySales> series;
  final SalesRange range;

  @override
  Widget build(BuildContext context) {
    final total = series.fold(0, (sum, point) => sum + point.sold);

    // Trend: aralığın ikinci yarısı ile ilk yarısını karşılaştırır.
    final half = series.length ~/ 2;
    final recent = series
        .skip(series.length - half)
        .fold(0, (sum, point) => sum + point.sold);
    final previous = series.take(half).fold(0, (sum, point) => sum + point.sold);
    final trend = previous == 0
        ? 0.0
        : (recent - previous) / previous * 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenX,
        0,
        AppSpace.screenX,
        AppSpace.sectionGap,
      ),
      children: [
        HeroNumber(
          label: range.heroLabel,
          value: total,
          unit: 'bilet',
          trendPct: trend,
          trendNote: range.comparisonNote,
        ),
        const SizedBox(height: AppSpace.cardPadding),
        SectionCard(
          child: SalesLineChart(
            series: series,
            showPointLabels: range.showPointLabels,
          ),
        ),
        const SizedBox(height: AppSpace.sectionGap),
        SectionCard(
          title: 'Günlük Satış Rakamları',
          child: DataRowList(
            rows: [
              // Tarih azalan.
              for (final point in series.reversed.take(30))
                DataRowItem(
                  label: Tr.date(point.date),
                  value: Tr.number(point.sold),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailySalesSkeleton extends StatelessWidget {
  const _DailySalesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenX),
      children: const [
        AppShimmer(
          child: Row(
            children: [
              Expanded(child: SkeletonBox(height: 38)),
              SizedBox(width: AppSpace.sectionGap),
              SkeletonBox(height: 38, width: 80),
            ],
          ),
        ),
        SizedBox(height: AppSpace.cardPadding),
        CardSkeleton(minHeight: 240),
        SizedBox(height: AppSpace.sectionGap),
        CardSkeleton(minHeight: 200),
      ],
    );
  }
}
