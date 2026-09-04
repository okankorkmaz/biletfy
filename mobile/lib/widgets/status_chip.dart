import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 10a · StatusText — liste kartlarındaki düz renkli durum metni (caption).
class StatusText extends StatelessWidget {
  const StatusText({super.key, required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      status.label,
      style: AppTypography.caption.copyWith(color: status.color),
    );
  }
}

/// 10b · StatusChip — detay başlığındaki pill: h 24, padding 10, label,
/// tint arka plan.
///
/// "Tamamlanan" tint yerine surfaceAlt kullanır (textTertiary'nin tint'i
/// okunmaz kalırdı).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final isMuted = status == EventStatus.tamamlanan;
    return Container(
      height: AppSize.statusPill,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.statusPillPaddingX,
      ),
      decoration: BoxDecoration(
        color: isMuted ? AppColors.surfaceAlt : AppColors.tint(status.color),
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        status.label,
        style: AppTypography.label.copyWith(color: status.color),
      ),
    );
  }
}

/// Doluluk değişim rozeti — h 20, padding 8. Artış success, azalış danger.
/// Opsiyonel: ya tüm kartlarda gösterilir ya hiçbirinde.
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final isUp = delta >= 0;
    final color = isUp ? AppColors.success : AppColors.danger;
    return Container(
      height: AppSize.deltaBadge,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.deltaBadgePaddingX,
      ),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: AppRadius.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? AppIcons.trendUp : AppIcons.trendDown,
            size: AppSpace.cardGap,
            color: color,
          ),
          const SizedBox(width: AppSpace.xs),
          Text(
            Tr.number(delta.abs()),
            style: AppTypography.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
