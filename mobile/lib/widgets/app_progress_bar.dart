import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Ortak progress barı — radius 999, track `border`.
///
/// Kalınlıklar token'dan: liste kartı 4 · detay doluluk 6 · firma barı 4.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.thickness = AppSize.progressList,
  });

  /// Doluluk yüzdesi (`0`–`100`).
  final double value;

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.pillR,
      child: LinearProgressIndicator(
        value: (value / 100).clamp(0.0, 1.0),
        minHeight: thickness,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
