import '../../models/event.dart';
import '../../models/reports.dart';
import '../../models/vendor.dart';
import '../../theme/app_colors.dart';

/// Şartname bölüm 5 ve 10'daki mock veri — tek kaynak.
///
/// Referans "bugün" 15 Mayıs 2026'dır; takvim, günlük satış ve aylık trend
/// verilerinin tamamı bu tarihe göre tutarlıdır
/// (1-7 Mayıs 5.124 + 8-15 Mayıs 7.718 = 12.842 toplam).
///
/// Bu dosya `lib/data/mock/` altındadır ve yalnızca repository tarafından
/// okunur; hiçbir ekran doğrudan buraya bakmaz.
abstract final class MockFixtures {
  /// Mock veri setinin "bugün"ü.
  static final DateTime today = DateTime(2026, 5, 15);

  static final Overview overview = Overview(
    totalEvents: 28,
    totalSold: 12842,
    totalRevenue: 12842600,
    avgOccupancy: 68.4,
    updatedAt: DateTime(2026, 5, 15, 20, 31),
  );

  /// Tüm etkinliklerin firma dağılımı — Ana Sayfa ve Raporlar/Satış aynı veri.
  static const List<VendorShare> vendorBreakdown = [
    VendorShare(vendor: Vendor.biletix, sold: 5642, pct: 43.9),
    VendorShare(vendor: Vendor.bubilet, sold: 4128, pct: 32.1),
    VendorShare(vendor: Vendor.biletinial, sold: 2034, pct: 15.8),
    VendorShare(vendor: Vendor.diger, sold: 1038, pct: 8.1),
  ];

  /// Bölüm 10/2 düzeltmesi: Dün +444, Bugün +529 (kolajdaki 368/512 değil).
  static const DailySalesSummary dailySummary = DailySalesSummary(
    yesterday: 444,
    today: 529,
    last7Days: 2846,
    dailyAverage: 407,
  );

  static final List<Event> events = [
    Event(
      id: 'cgh2',
      title: 'Çok Güzel Hareketler 2',
      status: EventStatus.devamEden,
      showCount: 8,
      totalSold: 5312,
      occupancyPct: 71.2,
      accentColor: AppColors.info,
    ),
    Event(
      id: 'dogu-demirkol',
      title: 'Doğu Demirkol',
      status: EventStatus.devamEden,
      showCount: 4,
      totalSold: 2350,
      occupancyPct: 62.7,
      accentColor: AppColors.info,
    ),
    Event(
      id: 'meksika-acmazi',
      title: 'Meksika Açmazı',
      status: EventStatus.yaklasan,
      showCount: 2,
      totalSold: 1124,
      occupancyPct: 55.8,
      accentColor: AppColors.vendorBiletinial,
    ),
    Event(
      id: 'okan-cabalar',
      title: 'Okan Çabalar',
      status: EventStatus.devamEden,
      showCount: 3,
      totalSold: 986,
      occupancyPct: 48.3,
      accentColor: AppColors.purple,
    ),
    Event(
      id: 'tahsin-hasoglu',
      title: 'Tahsin Hasoğlu',
      status: EventStatus.yaklasan,
      showCount: 2,
      totalSold: 742,
      occupancyPct: 41.0,
      accentColor: AppColors.warning,
    ),
    Event(
      id: 'gece-yarisi-kabare',
      title: 'Gece Yarısı Kabare',
      status: EventStatus.tamamlanan,
      showCount: 6,
      totalSold: 3410,
      occupancyPct: 89.5,
      accentColor: AppColors.textTertiary,
    ),
    Event(
      id: 'dogaclama-gecesi',
      title: 'Doğaçlama Gecesi',
      status: EventStatus.tamamlanan,
      showCount: 1,
      totalSold: 640,
      occupancyPct: 94.2,
      accentColor: AppColors.textTertiary,
    ),
  ];

  /// 15 Mayıs 2026 Cuma'nın gösterileri — satılan azalan.
  ///
  /// İlk gösteri (ÇGH 2) detay ekranının varsayılanıdır:
  /// kapasite 850, satılan 643, kalan 207, doluluk %75,6,
  /// brüt 643.000 ₺, ortalama 1.000 ₺, firma dağılımı 310+220+83+30 = 643.
  static final List<Show> shows = [
    Show(
      id: 'cgh2-15may',
      eventId: 'cgh2',
      eventTitle: 'Çok Güzel Hareketler 2',
      dateTime: DateTime(2026, 5, 15, 20, 30),
      venue: 'Zorlu PSM',
      city: 'İstanbul',
      capacity: 850,
      sold: 643,
      grossRevenue: 643000,
      avgTicketPrice: 1000,
      status: EventStatus.devamEden,
      vendorBreakdown: const [
        VendorShare(vendor: Vendor.biletix, sold: 310, pct: 48.2),
        VendorShare(vendor: Vendor.bubilet, sold: 220, pct: 34.2),
        VendorShare(vendor: Vendor.biletinial, sold: 83, pct: 12.9),
        VendorShare(vendor: Vendor.diger, sold: 30, pct: 4.7),
      ],
    ),
    Show(
      id: 'dogu-15may',
      eventId: 'dogu-demirkol',
      eventTitle: 'Doğu Demirkol',
      dateTime: DateTime(2026, 5, 15, 20, 0),
      venue: 'Maximum Uniq Hall',
      city: 'İstanbul',
      capacity: 700,
      sold: 412,
      grossRevenue: 391400,
      avgTicketPrice: 950,
      status: EventStatus.devamEden,
      vendorBreakdown: const [
        VendorShare(vendor: Vendor.biletix, sold: 198, pct: 48.1),
        VendorShare(vendor: Vendor.bubilet, sold: 132, pct: 32.0),
        VendorShare(vendor: Vendor.biletinial, sold: 61, pct: 14.8),
        VendorShare(vendor: Vendor.diger, sold: 21, pct: 5.1),
      ],
    ),
    Show(
      id: 'okan-15may',
      eventId: 'okan-cabalar',
      eventTitle: 'Okan Çabalar',
      dateTime: DateTime(2026, 5, 15, 20, 30),
      venue: 'Bostancı Gösteri Merkezi',
      city: 'İstanbul',
      capacity: 620,
      sold: 278,
      grossRevenue: 236300,
      avgTicketPrice: 850,
      status: EventStatus.devamEden,
      vendorBreakdown: const [
        VendorShare(vendor: Vendor.biletix, sold: 131, pct: 47.1),
        VendorShare(vendor: Vendor.bubilet, sold: 92, pct: 33.1),
        VendorShare(vendor: Vendor.biletinial, sold: 41, pct: 14.7),
        VendorShare(vendor: Vendor.diger, sold: 14, pct: 5.0),
      ],
    ),
    Show(
      id: 'tahsin-15may',
      eventId: 'tahsin-hasoglu',
      eventTitle: 'Tahsin Hasoğlu',
      dateTime: DateTime(2026, 5, 15, 21, 0),
      venue: 'Caddebostan Kültür Merkezi',
      city: 'İstanbul',
      capacity: 480,
      sold: 156,
      grossRevenue: 124800,
      avgTicketPrice: 800,
      status: EventStatus.yaklasan,
      vendorBreakdown: const [
        VendorShare(vendor: Vendor.biletix, sold: 74, pct: 47.4),
        VendorShare(vendor: Vendor.bubilet, sold: 51, pct: 32.7),
        VendorShare(vendor: Vendor.biletinial, sold: 23, pct: 14.7),
        VendorShare(vendor: Vendor.diger, sold: 8, pct: 5.1),
      ],
    ),
    Show(
      id: 'meksika-15may',
      eventId: 'meksika-acmazi',
      eventTitle: 'Meksika Açmazı',
      dateTime: DateTime(2026, 5, 15, 20, 30),
      venue: 'Trump Sahne',
      city: 'İstanbul',
      capacity: 540,
      sold: 98,
      grossRevenue: 88200,
      avgTicketPrice: 900,
      status: EventStatus.yaklasan,
      vendorBreakdown: const [
        VendorShare(vendor: Vendor.biletix, sold: 46, pct: 46.9),
        VendorShare(vendor: Vendor.bubilet, sold: 32, pct: 32.7),
        VendorShare(vendor: Vendor.biletinial, sold: 15, pct: 15.3),
        VendorShare(vendor: Vendor.diger, sold: 5, pct: 5.1),
      ],
    ),
  ];

  /// 9–15 Mayıs 2026 günlük satış serisi.
  static final List<DailySales> dailySales = [
    DailySales(date: DateTime(2026, 5, 9), sold: 256),
    DailySales(date: DateTime(2026, 5, 10), sold: 312),
    DailySales(date: DateTime(2026, 5, 11), sold: 428),
    DailySales(date: DateTime(2026, 5, 12), sold: 365),
    DailySales(date: DateTime(2026, 5, 13), sold: 512),
    DailySales(date: DateTime(2026, 5, 14), sold: 444),
    DailySales(date: DateTime(2026, 5, 15), sold: 529),
  ];

  /// Mayıs 2026 haftalık kovaları — 16 Mayıs sonrası veri yok.
  static final List<SalesBucket> mayBuckets = [
    SalesBucket(
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 7),
      sold: 5124,
    ),
    SalesBucket(
      start: DateTime(2026, 5, 8),
      end: DateTime(2026, 5, 15),
      sold: 7718,
    ),
    SalesBucket(
      start: DateTime(2026, 5, 16),
      end: DateTime(2026, 5, 23),
      sold: null,
    ),
    SalesBucket(
      start: DateTime(2026, 5, 24),
      end: DateTime(2026, 5, 31),
      sold: null,
    ),
  ];

  /// Firma bazlı gelir dağılımı — Biletix'in ortalama fiyatı daha yüksek
  /// olduğundan gelir payı satış payından farklıdır.
  static const List<VendorShare> revenueBreakdown = [
    VendorShare(vendor: Vendor.biletix, sold: 5924100, pct: 46.1),
    VendorShare(vendor: Vendor.bubilet, sold: 3980000, pct: 31.0),
    VendorShare(vendor: Vendor.biletinial, sold: 2010600, pct: 15.7),
    VendorShare(vendor: Vendor.diger, sold: 927900, pct: 7.2),
  ];

  /// Haftalık brüt gelir kovaları — satış kovalarıyla tutarlı.
  static final List<SalesBucket> mayRevenueBuckets = [
    SalesBucket(
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 7),
      sold: 5124000,
    ),
    SalesBucket(
      start: DateTime(2026, 5, 8),
      end: DateTime(2026, 5, 15),
      sold: 7718600,
    ),
    SalesBucket(start: DateTime(2026, 5, 16), end: DateTime(2026, 5, 23)),
    SalesBucket(start: DateTime(2026, 5, 24), end: DateTime(2026, 5, 31)),
  ];

  /// Firma karşılaştırma tablosu.
  static const List<VendorStat> vendorStats = [
    VendorStat(
      vendor: Vendor.biletix,
      sold: 5642,
      pct: 43.9,
      avgPrice: 1050,
      revenue: 5924100,
    ),
    VendorStat(
      vendor: Vendor.bubilet,
      sold: 4128,
      pct: 32.1,
      avgPrice: 964,
      revenue: 3980000,
    ),
    VendorStat(
      vendor: Vendor.biletinial,
      sold: 2034,
      pct: 15.8,
      avgPrice: 988,
      revenue: 2010600,
    ),
    VendorStat(
      vendor: Vendor.diger,
      sold: 1038,
      pct: 8.1,
      avgPrice: 894,
      revenue: 927900,
    ),
  ];

  /// ÇGH 2 · 15 Mayıs gösterisinin fiyat kademeleri (toplam 643).
  static const List<PriceTier> priceTiers = [
    PriceTier(name: 'Tam', price: 1200, sold: 384),
    PriceTier(name: 'Öğrenci', price: 750, sold: 168),
    PriceTier(name: 'Erken Rezervasyon', price: 900, sold: 68),
    PriceTier(name: 'Davetiye', price: 0, sold: 23),
  ];

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'Çok Güzel Hareketler 2 · %75,6 doluluk',
      detail: 'Doluluk eşiğini (%75) geçti.',
      time: DateTime(2026, 5, 15, 20, 12),
      kind: NotificationKind.doluluk,
      read: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'Bugün 529 bilet satıldı',
      detail: 'Önceki güne göre +85 bilet.',
      time: DateTime(2026, 5, 15, 19, 0),
      kind: NotificationKind.satis,
      read: false,
    ),
    AppNotification(
      id: 'n3',
      title: 'Biletinial senkronizasyonu gecikti',
      detail: 'Son veri 3 saat önce alındı.',
      time: DateTime(2026, 5, 15, 14, 30),
      kind: NotificationKind.uyari,
      read: true,
    ),
    AppNotification(
      id: 'n4',
      title: 'Meksika Açmazı biletleri satışta',
      detail: 'İlk gösteri 22 Mayıs 2026.',
      time: DateTime(2026, 5, 14, 11, 5),
      kind: NotificationKind.sistem,
      read: true,
    ),
    AppNotification(
      id: 'n5',
      title: 'Dün 444 bilet satıldı',
      detail: 'Günlük ortalamanın üzerinde.',
      time: DateTime(2026, 5, 14, 9, 0),
      kind: NotificationKind.satis,
      read: true,
    ),
  ];

  static final List<VendorIntegration> integrations = [
    VendorIntegration(
      vendor: Vendor.biletix,
      connected: true,
      lastSync: DateTime(2026, 5, 15, 20, 31),
    ),
    VendorIntegration(
      vendor: Vendor.bubilet,
      connected: true,
      lastSync: DateTime(2026, 5, 15, 20, 28),
    ),
    VendorIntegration(
      vendor: Vendor.biletinial,
      connected: true,
      lastSync: DateTime(2026, 5, 15, 17, 14),
    ),
    const VendorIntegration(
      vendor: Vendor.diger,
      connected: false,
      lastSync: null,
    ),
  ];

  /// Mayıs 2026'da etkinliği olan günler — takvim noktaları.
  static final Set<DateTime> mayEventDays = {
    DateTime(2026, 5, 1),
    DateTime(2026, 5, 6),
    DateTime(2026, 5, 8),
    DateTime(2026, 5, 14),
    DateTime(2026, 5, 15),
    DateTime(2026, 5, 21),
    DateTime(2026, 5, 29),
  };
}
