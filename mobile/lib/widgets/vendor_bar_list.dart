import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/vendor.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';
import 'app_progress_bar.dart';

/// 14 · VendorBarList — satır: isim (body), sağda değer (bodyStrong) +
/// yüzde (caption, sağa dayalı, 48 pt sabit genişlik); altında 4 pt bar
/// (`vendor.*`). Satır arası 12.
class VendorBarList extends StatelessWidget {
  const VendorBarList({super.key, required this.shares});

  final List<VendorShare> shares;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, share) in shares.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpace.cardGap),
          _VendorBarRow(share: share),
        ],
      ],
    );
  }
}

class _VendorBarRow extends StatelessWidget {
  const _VendorBarRow({required this.share});

  final VendorShare share;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                share.vendor.label,
                style: AppTypography.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpace.chipGap),
            Text(Tr.number(share.sold), style: AppTypography.bodyStrong),
            SizedBox(
              width: AppSize.vendorPctColumn,
              child: Text(
                Tr.percent(share.pct),
                style: AppTypography.caption,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        AppProgressBar(
          value: share.pct,
          color: share.vendor.color,
          thickness: AppSize.progressVendor,
        ),
      ],
    );
  }
}

/// Etkinlik bazlı yatay sıralama — Doluluk raporu için aynı biçim,
/// renk olarak etkinliğin `accentColor` alanını kullanır.
class AccentBarList extends StatelessWidget {
  const AccentBarList({super.key, required this.rows});

  final List<AccentBarRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpace.cardGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTypography.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpace.chipGap),
                  SizedBox(
                    width: AppSize.vendorPctColumn,
                    child: Text(
                      Tr.percent(row.pct),
                      style: AppTypography.bodyStrong,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              AppProgressBar(
                value: row.pct,
                color: row.color,
                thickness: AppSize.progressVendor,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

@immutable
class AccentBarRow {
  const AccentBarRow({
    required this.label,
    required this.pct,
    this.color = AppColors.info,
  });

  final String label;
  final double pct;
  final Color color;
}
