import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 23a · EmptyState — ikon konteyneri + body metin + ikincil buton.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = AppIcons.empty,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateBody(
      icon: icon,
      iconColor: AppColors.textTertiary,
      iconBackground: AppColors.surfaceAlt,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// 23c · ErrorState — danger tint'li ikon + başlık + açıklama + yeniden dene.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message = 'Veriler yüklenemedi',
    this.detail = 'Bağlantını kontrol edip tekrar dene.',
    this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateBody(
      icon: AppIcons.error,
      iconColor: AppColors.danger,
      iconBackground: AppColors.tint(AppColors.danger),
      message: message,
      detail: detail,
      actionLabel: 'Yeniden dene',
      onAction: onRetry,
    );
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.message,
    this.detail,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String message;
  final String? detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.cardPadding,
        vertical: AppSpace.sectionGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.stateIconBox,
            height: AppSize.stateIconBox,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: AppRadius.cellR,
            ),
            child: Icon(icon, size: AppIconSize.state, color: iconColor),
          ),
          const SizedBox(height: AppSpace.cardGap),
          Text(message, style: AppTypography.body, textAlign: TextAlign.center),
          if (detail != null) ...[
            const SizedBox(height: AppSpace.chipGap),
            Text(
              detail!,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpace.cardGap),
            SecondaryButton(label: actionLabel!, onTap: onAction),
          ],
        ],
      ),
    );
  }
}

/// İkincil buton — h 36, 1 pt border, pill.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.pillR,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillR,
        highlightColor: AppColors.pressedOverlay,
        splashColor: AppColors.pressedOverlay,
        child: Container(
          height: AppSize.secondaryButton,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.cardPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillR,
            border: Border.all(
              color: AppColors.border,
              width: AppSize.borderWidth,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// 23d · OfflineBanner — warning tint, ekranın en üstünde (app bar altında).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = 'Çevrimdışısın — son veriler gösteriliyor',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.listCardPadding,
        vertical: AppSpace.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.tint(AppColors.warning),
        borderRadius: AppRadius.cellR,
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.offline,
            size: AppIconSize.chip,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpace.chipGap),
          Expanded(
            child: Text(
              message,
              style: AppTypography.label.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// 23b · Skeleton — kart şekilli shimmer, surfaceAlt üzerinde.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius,
  });

  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.barTop),
      ),
    );
  }
}

/// Shimmer sarmalayıcı — tüm iskeletler bunun içine konur.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.border,
      child: child,
    );
  }
}

/// Liste kartı iskeleti — EventListCard'ın ölçüleriyle birebir.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.listCardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: AppSize.posterList,
              height: AppSize.posterList,
              radius: AppRadius.posterList,
            ),
            const SizedBox(width: AppSpace.listCardPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpace.xs),
                  const SkeletonBox(height: 14, width: 180),
                  const SizedBox(height: AppSpace.chipGap),
                  const SkeletonBox(height: 10, width: 90),
                  const SizedBox(height: AppSpace.sectionGap),
                  SkeletonBox(
                    height: AppSize.progressList,
                    radius: AppRadius.pill,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Donut kartı iskeleti — daire + 4 legend satırı.
class DonutSkeleton extends StatelessWidget {
  const DonutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          Container(
            width: AppSize.donutDiameter,
            height: AppSize.donutDiameter,
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpace.sectionGap),
          Expanded(
            child: Column(
              children: [
                for (var index = 0; index < 4; index++) ...[
                  if (index > 0) const SizedBox(height: AppSpace.cardGap),
                  const SkeletonBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kart iskeleti — SectionCard/KpiCard yerine geçer.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.minHeight = 0});

  /// Taban yükseklik — içerik daha uzunsa kart büyür, kırpılmaz.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: AppShimmer(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(
                width: AppSize.iconBox,
                height: AppSize.iconBox,
                radius: AppRadius.icon,
              ),
              const SizedBox(height: AppSpace.md),
              const SkeletonBox(height: 12, width: 100),
              const SizedBox(height: AppSpace.chipGap),
              const SkeletonBox(height: 20, width: 140),
            ],
          ),
        ),
      ),
    );
  }
}
