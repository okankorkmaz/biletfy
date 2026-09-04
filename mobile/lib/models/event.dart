import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'vendor.dart';

/// Etkinlik (gösteri serisi) durumu.
///
/// Devam Eden = seri sürüyor · Yaklaşan = ilk gösteri henüz gerçekleşmedi ·
/// Tamamlanan = tüm gösteriler bitti.
enum EventStatus {
  devamEden('Devam Eden', AppColors.success),
  yaklasan('Yaklaşan', AppColors.warning),
  tamamlanan('Tamamlanan', AppColors.textTertiary);

  const EventStatus(this.label, this.color);

  final String label;

  /// Semantik renk — liste kartında düz metin, detayda tint'li pill.
  final Color color;
}

/// Bir gösteri serisi.
@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.status,
    required this.showCount,
    required this.totalSold,
    required this.occupancyPct,
    this.accentColor,
    this.occupancyDelta,
  });

  final String id;
  final String title;
  final EventStatus status;

  /// Serideki gösteri sayısı.
  final int showCount;

  final int totalSold;

  /// `71.2` → `%71,2`
  final double occupancyPct;

  /// Liste kartındaki progress rengi. Tanımsızsa [AppColors.info].
  final Color? accentColor;

  /// Opsiyonel doluluk değişim rozeti — ya tüm kartlarda ya hiç.
  final int? occupancyDelta;

  /// Afiş yerine kullanılacak baş harfler.
  String get initials {
    final words = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    return words.take(3).map((word) => word[0].toUpperCase()).join();
  }

  Color get effectiveAccentColor => accentColor ?? AppColors.info;
}

/// Serideki tek bir gösteri.
@immutable
class Show {
  const Show({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.dateTime,
    required this.venue,
    required this.city,
    required this.capacity,
    required this.sold,
    required this.grossRevenue,
    required this.avgTicketPrice,
    required this.vendorBreakdown,
    required this.status,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final DateTime dateTime;
  final String venue;
  final String city;
  final int capacity;
  final int sold;
  final int grossRevenue;
  final int avgTicketPrice;
  final List<VendorShare> vendorBreakdown;
  final EventStatus status;

  int get remaining => capacity - sold;

  double get occupancyPct => capacity == 0 ? 0 : sold / capacity * 100;

  /// `İstanbul - Zorlu PSM`
  String get locationLabel => '$city - $venue';

  /// `Zorlu PSM - İstanbul` — takvim satırında kullanılan ters sıra.
  String get venueLabel => '$venue - $city';
}

/// Tek bir günün satış adedi.
@immutable
class DailySales {
  const DailySales({required this.date, required this.sold});

  final DateTime date;
  final int sold;
}

/// Haftalık kova — aylık satış trendi bar grafiği.
@immutable
class SalesBucket {
  const SalesBucket({required this.start, required this.end, this.sold});

  final DateTime start;
  final DateTime end;

  /// Veri yoksa `null` — grafikte değer yerine "–" gösterilir.
  final int? sold;
}

/// Ana Sayfa KPI özeti.
@immutable
class Overview {
  const Overview({
    required this.totalEvents,
    required this.totalSold,
    required this.totalRevenue,
    required this.avgOccupancy,
    required this.updatedAt,
  });

  final int totalEvents;
  final int totalSold;
  final int totalRevenue;
  final double avgOccupancy;
  final DateTime updatedAt;
}

/// Günlük satış özeti hücreleri (Dün / Bugün / Son 7 Gün / Günlük Ort.).
@immutable
class DailySalesSummary {
  const DailySalesSummary({
    required this.yesterday,
    required this.today,
    required this.last7Days,
    required this.dailyAverage,
  });

  final int yesterday;
  final int today;
  final int last7Days;
  final int dailyAverage;
}
