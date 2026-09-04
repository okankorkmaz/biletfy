import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 22 · PosterPlaceholder — nötr koyu gradient (surfaceAlt → border) +
/// ortada etkinlik baş harfleri. Gerçek afiş/fotoğraf yok.
///
/// Ölçüler: liste 76 (radius 10) · detay 96 (radius 12).
class PosterPlaceholder extends StatelessWidget {
  /// Liste kartındaki 76×76 afiş.
  const PosterPlaceholder.list({super.key, required this.initials})
    : size = AppSize.posterList,
      radius = AppRadius.posterList;

  /// Detay ekranındaki 96×96 afiş.
  const PosterPlaceholder.detail({super.key, required this.initials})
    : size = AppSize.posterDetail,
      radius = AppRadius.posterDetail;

  final String initials;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceAlt, AppColors.border],
        ),
      ),
      child: Text(
        initials,
        style: AppTypography.titleM.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
