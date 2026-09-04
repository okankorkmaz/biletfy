import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'vendor.dart';

/// Firmalar raporundaki karşılaştırma satırı.
@immutable
class VendorStat {
  const VendorStat({
    required this.vendor,
    required this.sold,
    required this.pct,
    required this.avgPrice,
    required this.revenue,
  });

  final Vendor vendor;
  final int sold;

  /// Satış payı yüzdesi.
  final double pct;

  /// Ortalama bilet fiyatı.
  final int avgPrice;

  final int revenue;
}

/// Bilet fiyat kademesi — Etkinlik Detayı / Detaylar sekmesi.
@immutable
class PriceTier {
  const PriceTier({
    required this.name,
    required this.price,
    required this.sold,
  });

  final String name;
  final int price;
  final int sold;
}

/// Bildirim türü — ikon ve tint rengini belirler.
enum NotificationKind {
  satis('Satış', AppColors.success),
  doluluk('Doluluk', AppColors.purple),
  uyari('Uyarı', AppColors.warning),
  sistem('Sistem', AppColors.info);

  const NotificationKind(this.label, this.color);

  final String label;
  final Color color;
}

/// Tek bir bildirim.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.time,
    required this.kind,
    required this.read,
  });

  final String id;
  final String title;
  final String detail;
  final DateTime time;
  final NotificationKind kind;
  final bool read;
}

/// Biletleme firması entegrasyonunun bağlantı durumu — Ayarlar.
@immutable
class VendorIntegration {
  const VendorIntegration({
    required this.vendor,
    required this.connected,
    required this.lastSync,
  });

  final Vendor vendor;
  final bool connected;

  /// Bağlı değilse `null`.
  final DateTime? lastSync;
}
