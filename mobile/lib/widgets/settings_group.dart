import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Ayarlar bölümü — üstte caption başlık, altında `surface` kart içinde
/// satır grubu, satırlar arası 1 pt divider.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.titleGap),
          child: Text(title, style: AppTypography.caption),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardR,
            border: Border.all(
              color: AppColors.border,
              width: AppSize.borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.cardR,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, row) in rows.indexed) ...[
                  if (index > 0) const Divider(),
                  row,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ayarlar satırı — sol başlık (+ ikincil açıklama), sağda değer/aksiyon.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.detail,
    this.value,
    this.trailing,
    this.leadingColor,
    this.onTap,
    this.labelColor,
  });

  final String label;

  /// Başlığın altındaki ikincil açıklama.
  final String? detail;

  /// Sağdaki değer metni.
  final String? value;

  /// Sağdaki özel bileşen (Switch gibi). [value] ile birlikte kullanılmaz.
  final Widget? trailing;

  /// Verilirse solda bu renkte 8 pt durum noktası çizilir.
  final Color? leadingColor;

  final VoidCallback? onTap;

  /// Yıkıcı eylemler için (`Çıkış`).
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.cardPadding,
        vertical: AppSpace.listCardPadding,
      ),
      child: Row(
        children: [
          if (leadingColor != null) ...[
            Container(
              width: AppSize.legendDot,
              height: AppSize.legendDot,
              decoration: BoxDecoration(
                color: leadingColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpace.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(color: labelColor),
                ),
                if (detail != null) ...[
                  const SizedBox(height: AppSpace.xxs),
                  Text(detail!, style: AppTypography.caption),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: AppSpace.chipGap),
            Text(
              value!,
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          ?trailing,
          if (onTap != null && trailing == null) ...[
            const SizedBox(width: AppSpace.chipGap),
            const Icon(
              AppIcons.chevronRight,
              size: AppIconSize.chip,
              color: AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.pressedOverlay,
        splashColor: AppColors.pressedOverlay,
        child: content,
      ),
    );
  }
}
