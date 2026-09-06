import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import 'poster_placeholder.dart';
import 'status_chip.dart';

/// 11 · EventHeader — 96×96 afiş + titleL başlık + pin/mekan +
/// takvim/tarih-saat + StatusChip.
///
/// Tarih satırı aynı zamanda gösteri seçicidir (chevron-down).
class EventHeader extends StatelessWidget {
  const EventHeader({
    super.key,
    required this.show,
    this.imageAsset,
    this.onPickShow,
  });

  final Show show;
  final String? imageAsset;

  /// Tarih satırına dokununca serinin diğer gösterilerini seçtirir.
  final VoidCallback? onPickShow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterPlaceholder.detail(
              initials: _initialsOf(show.eventTitle),
              imageAsset: imageAsset,
            ),
            const SizedBox(width: AppSpace.cardPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(show.eventTitle, style: AppTypography.titleL),
                  const SizedBox(height: AppSpace.chipGap),
                  _MetaRow(icon: AppIcons.mapPin, text: show.locationLabel),
                  const SizedBox(height: AppSpace.chipGap),
                  _MetaRow(
                    icon: AppIcons.calendar,
                    text: Tr.dateTime(show.dateTime),
                    onTap: onPickShow,
                    showChevron: onPickShow != null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.cardGap),
        StatusChip(status: show.status),
      ],
    );
  }

  static String _initialsOf(String title) {
    final words = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    return words.take(3).map((word) => word[0].toUpperCase()).join();
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
    this.onTap,
    this.showChevron = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.chip, color: AppColors.textSecondary),
        const SizedBox(width: AppSpace.sm),
        Flexible(
          child: Text(
            text,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: AppSpace.xs),
          const Icon(
            AppIcons.chevronDown,
            size: AppIconSize.chevron,
            color: AppColors.textSecondary,
          ),
        ],
      ],
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillR,
      highlightColor: AppColors.pressedOverlay,
      splashColor: AppColors.pressedOverlay,
      child: row,
    );
  }
}
