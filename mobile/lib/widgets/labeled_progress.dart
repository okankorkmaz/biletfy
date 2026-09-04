import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';
import 'app_progress_bar.dart';

/// 13 · LabeledProgress — sol caption etiket, sağ label değer,
/// altında 6 pt bar.
class LabeledProgress extends StatelessWidget {
  const LabeledProgress({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    this.color = AppColors.success,
    this.thickness = AppSize.progressDetail,
  });

  final String label;

  /// Sağdaki biçimlenmiş değer (ör. `%75,6`).
  final String valueText;

  /// Doluluk yüzdesi (`0`–`100`).
  final double value;

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.caption)),
            Text(valueText, style: AppTypography.label),
          ],
        ),
        const SizedBox(height: AppSpace.chipGap),
        AppProgressBar(value: value, color: color, thickness: thickness),
      ],
    );
  }
}
