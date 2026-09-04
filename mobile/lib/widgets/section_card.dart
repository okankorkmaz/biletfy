import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 06 · SectionCard — surface bg, radius 16, padding 16, 1 pt border.
/// Opsiyonel başlık satırı: titleM sol + trailing (genelde DropdownChip) sağ.
///
/// Gölge yok, elevation yok — tamamen flat.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.cardPadding),
  });

  final Widget child;

  /// Kart başlığı — verilmezse başlık satırı çizilmez.
  final String? title;

  /// Başlığın sağındaki bileşen (ör. DropdownChip).
  final Widget? trailing;

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                // Uzun başlık ve geniş dropdown chip birlikte taşmasın:
                // ikisi de daralabilir, chip önce kısalır.
                Flexible(
                  child: Text(
                    title!,
                    style: AppTypography.titleM,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpace.chipGap),
                  Flexible(child: trailing!),
                ],
              ],
            ),
            const SizedBox(height: AppSpace.cardPadding),
          ],
          child,
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              borderRadius: AppRadius.cardR,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.cardR,
                highlightColor: AppColors.pressedOverlay,
                splashColor: AppColors.pressedOverlay,
                child: content,
              ),
            ),
    );
  }
}
