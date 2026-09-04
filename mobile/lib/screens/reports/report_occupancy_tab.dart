import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// 14_Raporlar_Doluluk — etkinlik bazlı yatay bar sıralaması ve
/// ortalama doluluk çizgisi.
class ReportOccupancyTab extends StatefulWidget {
  const ReportOccupancyTab({super.key});

  @override
  State<ReportOccupancyTab> createState() => _ReportOccupancyTabState();
}

class _ReportOccupancyTabState extends State<ReportOccupancyTab> {
  late DashboardRepository _repository;

  Future<List<Event>>? _ranking;
  Future<double>? _average;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _ranking = _repository.occupancyRanking();
      _average = _repository.averageOccupancy();
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
          AsyncSection<double>(
            future: _average,
            onRetry: _load,
            skeleton: const CardSkeleton(minHeight: 88),
            builder: (context, average) => KpiCard(
              icon: AppIcons.occupancy,
              color: AppColors.purple,
              label: 'Ortalama Doluluk (Tüm Etkinlikler)',
              value: Tr.percent(average),
            ),
          ),
          const SizedBox(height: AppSpace.sectionGap),
          SectionCard(
            title: 'Etkinliklere Göre Doluluk',
            child: AsyncSection<List<Event>>(
              future: _ranking,
              onRetry: _load,
              isEmpty: (events) => events.isEmpty,
              emptyMessage: 'Doluluk verisi yok',
              skeleton: const AppShimmer(
                child: Column(
                  children: [
                    SkeletonBox(height: 34),
                    SizedBox(height: AppSpace.cardGap),
                    SkeletonBox(height: 34),
                    SizedBox(height: AppSpace.cardGap),
                    SkeletonBox(height: 34),
                  ],
                ),
              ),
              builder: (context, events) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AccentBarList(
                    rows: [
                      for (final event in events)
                        AccentBarRow(
                          label: event.title,
                          pct: event.occupancyPct,
                          color: event.effectiveAccentColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.cardPadding),
                  const Divider(),
                  const SizedBox(height: AppSpace.md),
                  FutureBuilder<double>(
                    future: _average,
                    builder: (context, snapshot) {
                      final average = snapshot.data;
                      if (average == null) return const SizedBox.shrink();
                      return Row(
                        children: [
                          Container(
                            width: AppSpace.sectionGap,
                            height: AppSize.borderWidth * 2,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpace.chipGap),
                          Expanded(
                            child: Text(
                              'Ortalama doluluk çizgisi',
                              style: AppTypography.caption,
                            ),
                          ),
                          Text(
                            Tr.percent(average),
                            style: AppTypography.labelStrong,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
