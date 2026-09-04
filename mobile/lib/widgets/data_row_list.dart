import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// 19 · DataRowList — sol body etiket, sağ bodyStrong değer; satır yüksekliği
/// 44; satırlar arası 1 pt `border` divider (son satırda yok).
class DataRowList extends StatelessWidget {
  const DataRowList({super.key, required this.rows});

  final List<DataRowItem> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, row) in rows.indexed)
          Container(
            height: AppSize.dataRow,
            decoration: BoxDecoration(
              border: index == rows.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: AppSize.borderWidth,
                      ),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.label,
                    style: AppTypography.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  row.value,
                  style: AppTypography.bodyStrong.copyWith(color: row.color),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

@immutable
class DataRowItem {
  const DataRowItem({
    required this.label,
    required this.value,
    this.color = AppColors.success,
  });

  final String label;
  final String value;

  /// Satılan/artış değerleri success; nötr toplamlar textPrimary.
  final Color color;
}
