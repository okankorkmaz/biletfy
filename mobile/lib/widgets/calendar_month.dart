import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 20 · CalendarMonth — başlık satırı (chevron-left · "Mayıs 2026" ·
/// chevron-right), Pazartesi başlangıçlı 7 kolon, hücre 40×40.
///
/// Komşu ay günleri textTertiary · seçili gün primary dolu daire ·
/// bugün (seçili değilse) 1,5 pt primary halka · etkinlikli günde 4 pt nokta.
class CalendarMonth extends StatelessWidget {
  const CalendarMonth({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onMonthChanged,
    this.eventDays = const {},
    this.today,
  });

  /// Görüntülenen ay (gün alanı yok sayılır).
  final DateTime month;

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;

  /// Etkinliği olan günler — hücre altında nokta gösterilir.
  final Set<DateTime> eventDays;

  /// "Bugün" halkası için referans; verilmezse [DateTime.now] kullanılır.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month);
    final gridStart = Tr.startOfWeek(firstOfMonth);
    final now = today ?? DateTime.now();
    final todayKey = _key(now);
    final selectedKey = _key(selectedDate);

    // Ayın tamamını kapsayan tam hafta sayısı.
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastOfMonth = DateTime(month.year, month.month, daysInMonth);
    final gridEnd = Tr.startOfWeek(lastOfMonth).add(const Duration(days: 6));
    final weekCount = gridEnd.difference(gridStart).inDays ~/ 7 + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _MonthArrow(
              icon: AppIcons.chevronLeft,
              tooltip: 'Önceki ay',
              onTap: () => onMonthChanged(
                DateTime(month.year, month.month - 1),
              ),
            ),
            Expanded(
              child: Text(
                Tr.monthYear(month),
                style: AppTypography.titleM,
                textAlign: TextAlign.center,
              ),
            ),
            _MonthArrow(
              icon: AppIcons.chevronRight,
              tooltip: 'Sonraki ay',
              onTap: () => onMonthChanged(
                DateTime(month.year, month.month + 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.cardGap),
        Row(
          children: [
            for (final name in Tr.weekdayShorts)
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.chipGap),
        for (var week = 0; week < weekCount; week++)
          Row(
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final date = gridStart.add(
                        Duration(days: week * 7 + weekday),
                      );
                      final key = _key(date);
                      return _DayCell(
                        date: date,
                        isOutside: date.month != month.month,
                        isSelected: key == selectedKey,
                        isToday: key == todayKey,
                        hasEvent: eventDays.map(_key).contains(key),
                        onTap: () => onSelectDate(date),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static DateTime _key(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: AppSize.minTouch / 2,
        child: SizedBox(
          width: AppSize.minTouch,
          height: AppSize.minTouch,
          child: Icon(
            icon,
            size: AppIconSize.inline,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isOutside,
    required this.isSelected,
    required this.isToday,
    required this.hasEvent,
    required this.onTap,
  });

  final DateTime date;
  final bool isOutside;
  final bool isSelected;
  final bool isToday;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? AppColors.onPrimary
        : isOutside
        ? AppColors.textTertiary
        : AppColors.textPrimary;

    return Semantics(
      selected: isSelected,
      button: true,
      label: Tr.dateWithWeekday(date),
      child: InkResponse(
        onTap: onTap,
        radius: AppSize.minTouch / 2,
        // Dokunma hedefi 44, görsel hücre 40.
        child: SizedBox(
          height: AppSize.minTouch,
          child: Center(
            child: Container(
              width: AppSize.calendarCell,
              height: AppSize.calendarCell,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : null,
                border: isToday && !isSelected
                    ? Border.all(
                        color: AppColors.primary,
                        width: AppSize.todayRingWidth,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${date.day}',
                    style: AppTypography.body.copyWith(
                      color: textColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (hasEvent && !isSelected) ...[
                    const SizedBox(height: AppSpace.xxs),
                    Container(
                      width: AppSize.eventDot,
                      height: AppSize.eventDot,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
