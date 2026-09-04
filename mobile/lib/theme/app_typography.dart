import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi token'ları — `design/Tasarim Sistemi.dc.html` · Token JSON `type`
/// bloğunun birebir karşılığı. Tek aile: Inter.
///
/// `tabular: true` işaretli her token'da [FontFeature.tabularFigures] zorunlu —
/// sağa dayalı sayı kolonları ancak böyle hizalanır.
///
/// Kural: hiçbir widget'ta hardcoded font size bulunmaz; her stil buradan gelir.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle _inter({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    bool tabular = false,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color,
      fontFeatures: tabular ? _tabular : null,
    );
  }

  /// 32 / 38 · Bold · tabular — "+2.846" hero sayısı.
  static TextStyle get displayNum => _inter(
    size: 32,
    lineHeight: 38,
    weight: FontWeight.w700,
    tabular: true,
  );

  /// 24 / 28 · Bold · tabular — KPI değerleri.
  static TextStyle get numL =>
      _inter(size: 24, lineHeight: 28, weight: FontWeight.w700, tabular: true);

  /// 20 / 24 · SemiBold · tabular — Kapasite/Satılan/Kalan, donut merkezi.
  static TextStyle get numM =>
      _inter(size: 20, lineHeight: 24, weight: FontWeight.w600, tabular: true);

  /// 22 / 28 · Bold — etkinlik detay başlığı.
  static TextStyle get titleL =>
      _inter(size: 22, lineHeight: 28, weight: FontWeight.w700);

  /// 17 / 22 · SemiBold — app bar başlığı, kart başlıkları, etkinlik adı.
  static TextStyle get titleM =>
      _inter(size: 17, lineHeight: 22, weight: FontWeight.w600);

  /// 15 / 20 · Regular · tabular — liste satırları.
  static TextStyle get body =>
      _inter(size: 15, lineHeight: 20, weight: FontWeight.w400, tabular: true);

  /// 15 / 20 · SemiBold · tabular — liste satırlarındaki değerler.
  static TextStyle get bodyStrong =>
      _inter(size: 15, lineHeight: 20, weight: FontWeight.w600, tabular: true);

  /// 13 / 18 · Medium · tabular — chip metni, legend, trend rozeti.
  static TextStyle get label =>
      _inter(size: 13, lineHeight: 18, weight: FontWeight.w500, tabular: true);

  /// 13 / 18 · SemiBold · tabular — legend ve saat kutusu değerleri.
  static TextStyle get labelStrong =>
      _inter(size: 13, lineHeight: 18, weight: FontWeight.w600, tabular: true);

  /// 12 / 16 · Regular — etiketler, durum metni, mekan.
  static TextStyle get caption => _inter(
    size: 12,
    lineHeight: 16,
    weight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 11 / 14 · Regular · tabular — eksen etiketleri, "Gösteri", "satılan".
  static TextStyle get micro => _inter(
    size: 11,
    lineHeight: 14,
    weight: FontWeight.w400,
    tabular: true,
    color: AppColors.textSecondary,
  );

  /// 10 / 12 · Medium — alt navigasyon etiketleri.
  static TextStyle get navLabel =>
      _inter(size: 10, lineHeight: 12, weight: FontWeight.w500);

  /// [ThemeData.textTheme] eşlemesi — Material 3 rolleri proje token'larına
  /// bağlanır, böylece tema üzerinden okunan stiller de token'dan gelir.
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayNum,
    headlineLarge: numL,
    headlineMedium: numM,
    titleLarge: titleL,
    titleMedium: titleM,
    bodyLarge: body,
    bodyMedium: label,
    bodySmall: caption,
    labelSmall: micro,
    labelMedium: navLabel,
  );
}
