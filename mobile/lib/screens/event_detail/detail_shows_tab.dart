import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../models/reports.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// 12_EtkinlikDetayi_Detaylar — üçüncü sekme.
///
/// Serinin gösteri listesi (tarih-saat / mekan / kapasite / satılan / doluluk
/// mini progress) ve seçili gösterinin bilet fiyat kademeleri.
class DetailShowsTab extends StatefulWidget {
  const DetailShowsTab({
    super.key,
    required this.shows,
    required this.selectedShow,
    required this.onSelectShow,
  });

  final List<Show> shows;
  final Show selectedShow;
  final ValueChanged<Show> onSelectShow;

  @override
  State<DetailShowsTab> createState() => _DetailShowsTabState();
}

class _DetailShowsTabState extends State<DetailShowsTab> {
  late DashboardRepository _repository;
  Future<List<PriceTier>>? _tiers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  @override
  void didUpdateWidget(DetailShowsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedShow.id != widget.selectedShow.id) _load();
  }

  void _load() {
    setState(() {
      _tiers = _repository.priceTiers(widget.selectedShow.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenX,
        AppSpace.cardPadding,
        AppSpace.screenX,
        AppSpace.sectionGap,
      ),
      children: [
        Text(
          'Gösteriler (${Tr.number(widget.shows.length)})',
          style: AppTypography.titleM,
        ),
        const SizedBox(height: AppSpace.titleGap),
        for (final show in widget.shows) ...[
          _ShowRow(
            show: show,
            selected: show.id == widget.selectedShow.id,
            onTap: () => widget.onSelectShow(show),
          ),
          const SizedBox(height: AppSpace.cardGap),
        ],
        const SizedBox(height: AppSpace.titleGap),

        SectionCard(
          title: 'Bilet Fiyat Kademeleri',
          child: AsyncSection<List<PriceTier>>(
            future: _tiers,
            onRetry: _load,
            isEmpty: (tiers) => tiers.isEmpty,
            emptyMessage: 'Bu gösteri için fiyat kademesi tanımlı değil',
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
            builder: (context, tiers) => DataRowList(
              rows: [
                for (final tier in tiers)
                  DataRowItem(
                    label: '${tier.name} · ${Tr.currency(tier.price)}',
                    value: Tr.number(tier.sold),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Seri içindeki tek gösteri — seçili olan primary kenarlıkla işaretlenir.
class _ShowRow extends StatelessWidget {
  const _ShowRow({
    required this.show,
    required this.selected,
    required this.onTap,
  });

  final Show show;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardR,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardR,
          highlightColor: AppColors.pressedOverlay,
          splashColor: AppColors.pressedOverlay,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.listCardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Tr.dateTime(show.dateTime),
                        style: AppTypography.bodyStrong,
                      ),
                    ),
                    StatusText(status: show.status),
                  ],
                ),
                const SizedBox(height: AppSpace.xxs),
                Text(
                  show.venueLabel,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpace.md),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Kapasite',
                        value: Tr.number(show.capacity),
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Satılan',
                        value: Tr.number(show.sold),
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Doluluk',
                        value: Tr.percent(show.occupancyPct),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                AppProgressBar(
                  value: show.occupancyPct,
                  color: AppColors.success,
                  thickness: AppSize.progressList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpace.xxs),
        Text(value, style: AppTypography.bodyStrong.copyWith(color: color)),
      ],
    );
  }
}
