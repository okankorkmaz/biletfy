import 'package:intl/intl.dart';

/// tr_TR biçim kuralları — şartname bölüm 8.
///
/// Binlik ayırıcı nokta, ondalık virgül, yüzde işareti önde, para değerden
/// sonra boşluklu `₺`, hafta pazartesi başlar.
abstract final class Tr {
  static const String locale = 'tr_TR';

  static final NumberFormat _integer = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = 0;

  static final NumberFormat _oneDecimal = NumberFormat('#,##0.0', locale);

  /// `12842` → `12.842`
  static String number(num value) => _integer.format(value);

  /// `2846` → `+2.846` · `-12` → `−12` (gerçek eksi işareti).
  ///
  /// Sıfır işaretsiz döner.
  static String signedNumber(num value) {
    if (value > 0) return '+${number(value)}';
    if (value < 0) return '−${number(value.abs())}';
    return number(value);
  }

  /// `68.4` → `%68,4` — yüzde işareti önde, tek ondalık.
  static String percent(num value) => '%${_oneDecimal.format(value)}';

  /// `18.6` → `%18,6` · `-4.2` → `−%4,2`
  static String signedPercent(num value) {
    if (value < 0) return '−${percent(value.abs())}';
    return percent(value);
  }

  /// `12842600` → `12.842.600 ₺` — değer + boşluk + ₺.
  static String currency(num value) => '${number(value)} ₺';

  /// Eksen kısaltması: `2000` → `2K`, `500` → `500`.
  static String axisCompact(num value) {
    if (value.abs() >= 1000) {
      final thousands = value / 1000;
      final text = thousands == thousands.roundToDouble()
          ? thousands.round().toString()
          : _oneDecimal.format(thousands);
      return '${text}K';
    }
    return number(value);
  }

  /// `15 Mayıs 2026`
  static String date(DateTime value) =>
      DateFormat('d MMMM y', locale).format(value);

  /// `15 Mayıs 2026 Cuma`
  static String dateWithWeekday(DateTime value) =>
      DateFormat('d MMMM y EEEE', locale).format(value);

  /// `20:30` — 24 saat.
  static String time(DateTime value) => DateFormat('HH:mm', locale).format(value);

  /// `15 Mayıs 2026 - 20:30`
  static String dateTime(DateTime value) => '${date(value)} - ${time(value)}';

  /// `Mayıs 2026`
  static String monthYear(DateTime value) =>
      DateFormat('MMMM y', locale).format(value);

  /// `15 May 20:31` — "son güncelleme" damgası.
  static String shortStamp(DateTime value) =>
      DateFormat('d MMM HH:mm', locale).format(value);

  /// `01 Mayıs - 15 Mayıs 2026`
  static String dateRange(DateTime start, DateTime end) {
    final startText = DateFormat('dd MMMM', locale).format(start);
    final endText = DateFormat('dd MMMM y', locale).format(end);
    return '$startText - $endText';
  }

  /// `1-7 Mayıs` — haftalık kova etiketi.
  static String dayRange(DateTime start, DateTime end) {
    final month = DateFormat('MMMM', locale).format(end);
    return '${start.day}-${end.day} $month';
  }

  /// Pazartesi başlangıçlı gün kısaltmaları.
  static const List<String> weekdayShorts = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Verilen tarihin ait olduğu pazartesi (haftanın ilk günü).
  static DateTime startOfWeek(DateTime value) {
    final day = DateTime(value.year, value.month, value.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
