import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/reports.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import 'kpi_card.dart';

/// Bildirim satırı — tint'li ikon konteyneri + başlık + açıklama + saat.
/// Okunmamış satırda solda 6 pt primary nokta.
class NotificationRow extends StatelessWidget {
  const NotificationRow({super.key, required this.notification, this.onTap});

  final AppNotification notification;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSize.unreadDot,
                  child: notification.read
                      ? null
                      : Container(
                          width: AppSize.unreadDot,
                          height: AppSize.unreadDot,
                          margin: const EdgeInsets.only(top: AppSpace.md),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpace.md),
                TintedIconBox(
                  icon: _iconFor(notification.kind),
                  color: notification.kind.color,
                ),
                const SizedBox(width: AppSpace.listCardPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        style: AppTypography.body.copyWith(
                          fontWeight: notification.read
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xxs),
                      Text(notification.detail, style: AppTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.chipGap),
                Text(
                  Tr.time(notification.time),
                  style: AppTypography.micro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(NotificationKind kind) => switch (kind) {
    NotificationKind.satis => AppIcons.totalSold,
    NotificationKind.doluluk => AppIcons.occupancy,
    NotificationKind.uyari => AppIcons.error,
    NotificationKind.sistem => AppIcons.about,
  };
}
