import 'package:flutter/material.dart';

/// Renk token'ları — `design/Tasarim Sistemi.dc.html` · Token JSON `color`
/// bloğunun birebir karşılığı. Yalnızca koyu tema.
///
/// Kural: hiçbir widget'ta hardcoded hex bulunmaz; her renk buradan gelir.
/// Tabloda olmayan bir renge ihtiyaç duyulursa [surfaceAlt] veya
/// [textSecondary] ile çözülür — yeni renk icat edilmez.
abstract final class AppColors {
  // --- Yüzey ve metin ---

  /// Ekran arka planı (OLED siyah).
  static const Color bg = Color(0xFF000000);

  /// Kartlar.
  static const Color surface = Color(0xFF151517);

  /// Kart içi hücre, pasif chip, saat kutusu, dropdown chip.
  static const Color surfaceAlt = Color(0xFF202024);

  /// 1 pt kart kenarlığı, divider, grafik grid çizgileri, progress track.
  static const Color border = Color(0xFF2A2A2E);

  /// Değerler, başlıklar.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Etiketler, ikincil metin, pasif nav.
  static const Color textSecondary = Color(0xFFA1A1AA);

  /// Komşu ay günleri, en düşük öncelikli metin.
  static const Color textTertiary = Color(0xFF6B6B72);

  // --- Marka ve semantik ---

  /// BKM kırmızısı — yalnızca "aktif/seçili" anlamı taşır.
  /// Veri rengi olarak KULLANILMAZ ("Kalan" için [danger] vardır).
  static const Color primary = Color(0xFFE5233D);

  /// [primary] üzerindeki metin/ikon.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Artış, satılan, "Devam Eden", günlük satış çizgisi.
  static const Color success = Color(0xFF22C55E);

  /// "Yaklaşan".
  static const Color warning = Color(0xFFF59E0B);

  /// "Kalan", azalış.
  static const Color danger = Color(0xFFEF4444);

  /// Birincil bar grafik, "Toplam Satılan" ikonu, varsayılan accentColor.
  static const Color info = Color(0xFF3B82F6);

  /// "Ortalama Doluluk" ve "Ortalama Bilet Fiyatı" ikonları.
  static const Color purple = Color(0xFF8B5CF6);

  // --- Biletleme firmaları (sabit ve global) ---

  static const Color vendorBiletix = Color(0xFF3B82F6);
  static const Color vendorBubilet = Color(0xFF14B8A6);
  static const Color vendorBiletinial = Color(0xFFF97316);
  static const Color vendorDiger = Color(0xFF6B7280);

  // --- Tint kuralı ---

  /// İkon konteynerleri ve durum pill arka planları bu opaklıkta boyanır;
  /// ikon/metin rengin kendisidir.
  static const double tintOpacity = 0.15;

  /// [tintOpacity] uygulanmış tint arka planı.
  static Color tint(Color color) => color.withValues(alpha: tintOpacity);

  /// Basılı durum örtüsü — %8 beyaz, ölçek değişimi yok.
  static const Color pressedOverlay = Color(0x14FFFFFF);

  /// Devre dışı bileşen opaklığı.
  static const double disabledOpacity = 0.4;
}
