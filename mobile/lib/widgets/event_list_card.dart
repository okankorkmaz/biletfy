import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';
import 'app_progress_bar.dart';
import 'poster_placeholder.dart';
import 'status_chip.dart';

/// 09 · EventListCard — surface, radius 16, padding 12.
///
/// Sol 76×76 afiş · sağ başlık (max 2 satır) + durum metni · sağ üst köşede
/// gösteri sayısı + "Gösteri" · alt satırda Toplam Satılan / Doluluk ·
/// en altta tam genişlik 4 pt progress (accentColor, track border).
///
/// Tüm kart tıklanabilir → Etkinlik Detayı.
class EventListCard extends StatelessWidget {
  const EventListCard({
    super.key,
    required this.event,
    this.onTap,
    this.showDelta = false,
  });

  final Event event;
  final VoidCallback? onTap;

  /// Doluluk değişim rozetini göster — ya tüm kartlarda ya hiç.
  final bool showDelta;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(color: AppColors.border, width: AppSize.borderWidth),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PosterPlaceholder.list(
                      initials: event.initials,
                      imageAsset: event.imageAsset,
                    ),
                    const SizedBox(width: AppSpace.listCardPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.title,
                            style: AppTypography.titleM,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpace.xs),
                          StatusText(status: event.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.chipGap),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Tr.number(event.showCount),
                          style: AppTypography.titleM,
                        ),
                        Text('Gösteri', style: AppTypography.micro),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.listCardPadding),
                Row(
                  children: [
                    Expanded(
                      child: _MetricColumn(
                        label: 'Toplam Satılan',
                        value: Tr.number(event.totalSold),
                      ),
                    ),
                    Expanded(
                      child: _MetricColumn(
                        label: 'Doluluk',
                        value: Tr.percent(event.occupancyPct),
                        trailing: showDelta && event.occupancyDelta != null
                            ? DeltaBadge(delta: event.occupancyDelta!)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.listCardPadding),
                AppProgressBar(
                  value: event.occupancyPct,
                  color: event.effectiveAccentColor,
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

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpace.xxs),
        Row(
          children: [
            Text(value, style: AppTypography.bodyStrong),
            if (trailing != null) ...[
              const SizedBox(width: AppSpace.chipGap),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}
