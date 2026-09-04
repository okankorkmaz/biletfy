import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../widgets/widgets.dart';

/// 03_EtkinlikDetayi_GenelBakis — ilk sekme.
///
/// EventHeader · StatTrio + doluluk barı · KPI ×2 · firma dağılımı.
class DetailOverviewTab extends StatelessWidget {
  const DetailOverviewTab({super.key, required this.show, this.onPickShow});

  final Show show;

  /// Seride birden fazla gösteri varsa tarih satırı seçici olur.
  final VoidCallback? onPickShow;

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
        EventHeader(show: show, onPickShow: onPickShow),
        const SizedBox(height: AppSpace.cardPadding),

        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatTrio(
                items: [
                  StatTrioItem(
                    label: 'Kapasite',
                    value: Tr.number(show.capacity),
                  ),
                  StatTrioItem(
                    label: 'Satılan',
                    value: Tr.number(show.sold),
                    color: AppColors.success,
                  ),
                  StatTrioItem(
                    label: 'Kalan',
                    value: Tr.number(show.remaining),
                    color: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.cardPadding),
              const Divider(),
              const SizedBox(height: AppSpace.cardPadding),
              LabeledProgress(
                label: 'Doluluk Oranı',
                valueText: Tr.percent(show.occupancyPct),
                value: show.occupancyPct,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  icon: AppIcons.revenue,
                  color: AppColors.info,
                  label: 'Brüt Satış',
                  value: Tr.currency(show.grossRevenue),
                ),
              ),
              const SizedBox(width: AppSpace.cardGap),
              Expanded(
                child: KpiCard(
                  icon: AppIcons.avgTicketPrice,
                  color: AppColors.purple,
                  label: 'Ort. Bilet Fiyatı',
                  value: Tr.currency(show.avgTicketPrice),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.sectionGap),

        SectionCard(
          title: 'Biletleme Firmalarına Göre Dağılım',
          child: VendorBarList(shares: show.vendorBreakdown),
        ),
      ],
    );
  }
}
