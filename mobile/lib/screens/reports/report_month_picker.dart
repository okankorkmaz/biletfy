import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../widgets/widgets.dart';

/// Rapor kartlarının ay/aralık seçici chip'i.
///
/// [asRange] `true` iken etiket "01 Mayıs - 15 Mayıs 2026" biçiminde,
/// aksi hâlde "Mayıs 2026" biçimindedir; seçim her iki durumda da aydır.
class ReportMonthPicker extends StatelessWidget {
  const ReportMonthPicker({
    super.key,
    required this.month,
    required this.onChanged,
    this.asRange = false,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  final bool asRange;

  /// Seçilebilir aylar — mock veri seti Mayıs 2026 merkezli.
  static final List<DateTime> _months = [
    for (var offset = -3; offset <= 1; offset++)
      DateTime(2026, 5 + offset),
  ];

  String _labelFor(DateTime value) {
    if (!asRange) return Tr.monthYear(value);
    final lastDay = DateTime(value.year, value.month + 1, 0);
    // Mayıs 2026'da veri 15'ine kadar; diğer aylarda ay sonu.
    final end = value.year == 2026 && value.month == 5
        ? DateTime(2026, 5, 15)
        : lastDay;
    return Tr.dateRange(DateTime(value.year, value.month), end);
  }

  @override
  Widget build(BuildContext context) {
    final options = [for (final option in _months) _labelFor(option)];
    return DropdownChip(
      label: _labelFor(month),
      sheetTitle: asRange ? 'Tarih aralığı' : 'Ay',
      options: options,
      onSelected: (value) {
        final index = options.indexOf(value);
        if (index >= 0) onChanged(_months[index]);
      },
    );
  }
}
