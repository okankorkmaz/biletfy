import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';
import 'status_chip.dart';

/// 21 · DayEventRow — sol saat kutusu 52×32 (surfaceAlt, radius 8,
/// label SemiBold); orta: bodyStrong başlık, caption mekan, renkli durum;
/// sağ: bodyStrong satılan + micro "satılan".
///
/// Satır arası 8; tıklanabilir → Etkinlik Detayı (ilgili gösteri seçili).
class DayEventRow extends StatelessWidget {
  const DayEventRow({super.key, required this.show, this.onTap});

  final Show show;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: AppColors.border,
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
            child: Row(
              children: [
                Container(
                  width: AppSize.timeBox.width,
                  height: AppSize.timeBox.height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: AppRadius.timeBoxR,
                  ),
                  child: Text(
                    Tr.time(show.dateTime),
                    style: AppTypography.labelStrong,
                  ),
                ),
                const SizedBox(width: AppSpace.listCardPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        show.eventTitle,
                        style: AppTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpace.xxs),
                      Text(
                        show.venueLabel,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpace.xxs),
                      StatusText(status: show.status),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.chipGap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Tr.number(show.sold),
                      style: AppTypography.bodyStrong,
                    ),
                    Text('satılan', style: AppTypography.micro),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
