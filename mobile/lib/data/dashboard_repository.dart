import '../models/event.dart';
import '../models/reports.dart';
import '../models/vendor.dart';

/// Ekranların veriye tek erişim noktası.
///
/// UI hiçbir yerde mock'a doğrudan bakmaz; yalnızca bu sözleşmeyi bilir.
/// API'ye geçerken bu arayüzün başka bir implementasyonu takılır.
abstract interface class DashboardRepository {
  /// Verinin "bugün"ü — takvim ve dönem hesapları buna göre yapılır.
  ///
  /// Gerçek uygulamada [DateTime.now]; mock'ta sabit bir tarih olduğundan
  /// ekranlar cihaz saatine değil bu değere bakar.
  DateTime get referenceDate;

  /// Ana Sayfa KPI özeti.
  Future<Overview> overview(OverviewPeriod period);

  /// Tüm etkinliklerin firma bazlı satış dağılımı.
  Future<List<VendorShare>> vendorBreakdown({DateTimeRange? range});

  /// Günlük satış özeti hücreleri.
  Future<DailySalesSummary> dailySummary(int days);

  /// Etkinlik listesi, [filter] durumuna göre süzülür.
  Future<List<Event>> events(EventFilter filter);

  /// Tek bir etkinliğin gösterileri, tarih artan.
  Future<List<Show>> showsOfEvent(String eventId);

  /// Tek bir gösteri.
  Future<Show> show(String showId);

  /// Günlük satış serisi. [eventId] verilirse o etkinliğe süzülür.
  Future<List<DailySales>> dailySales(SalesRange range, {String? eventId});

  /// Aylık satış trendi kovaları.
  Future<List<SalesBucket>> monthlyBuckets(DateTime month);

  /// Belirli bir günün gösterileri, satılan azalan.
  Future<List<Show>> showsOnDay(DateTime day);

  /// Ay içinde etkinliği olan günler — takvimde nokta gösterilir.
  Future<Set<DateTime>> eventDaysOfMonth(DateTime month);

  // --- Raporlar ---

  /// Firma bazlı gelir dağılımı — payı ₺ üzerinden hesaplanır.
  Future<List<VendorShare>> revenueBreakdown({DateTimeRange? range});

  /// Haftalık brüt gelir kovaları.
  Future<List<SalesBucket>> revenueBuckets(DateTime month);

  /// Etkinlikler doluluk oranına göre azalan.
  Future<List<Event>> occupancyRanking();

  /// Tüm etkinliklerin ortalama doluluğu.
  Future<double> averageOccupancy();

  /// Firma karşılaştırma tablosu.
  Future<List<VendorStat>> vendorStats();

  /// Firma bazlı günlük satış serileri — çoklu çizgi grafik.
  Future<Map<Vendor, List<DailySales>>> vendorSeries(SalesRange range);

  // --- Etkinlik detayı ---

  /// Bir gösterinin bilet fiyat kademeleri.
  Future<List<PriceTier>> priceTiers(String showId);

  // --- Diğer ---

  /// Bildirimler, yeniden eskiye.
  Future<List<AppNotification>> notifications();

  /// Etkinlik araması — başlık ve mekanda geçer.
  Future<List<Event>> searchEvents(String query);

  /// Biletleme firması entegrasyonlarının bağlantı durumu.
  Future<List<VendorIntegration>> integrations();
}

/// Ana Sayfa dönem filtresi.
enum OverviewPeriod {
  bugun('Bugün'),
  buHafta('Bu Hafta'),
  buAy('Bu Ay'),
  tumu('Tümü');

  const OverviewPeriod(this.label);

  final String label;
}

/// Etkinlik listesi filtresi.
enum EventFilter {
  tumu('Tümü', null),
  devamEden('Devam Eden', EventStatus.devamEden),
  yaklasan('Yaklaşan', EventStatus.yaklasan),
  tamamlanan('Tamamlanan', EventStatus.tamamlanan);

  const EventFilter(this.label, this.status);

  final String label;

  /// `null` ise süzme yapılmaz.
  final EventStatus? status;
}

/// Günlük satış ekranı aralığı.
enum SalesRange {
  gun7('7 Gün', 7),
  gun30('30 Gün', 30),
  gun90('90 Gün', 90),
  tumu('Tümü', 180);

  const SalesRange(this.label, this.days);

  final String label;
  final int days;

  /// Hero başlığı: "Son 7 Gün Toplam".
  String get heroLabel =>
      this == SalesRange.tumu ? 'Toplam' : 'Son $label Toplam';

  /// Trend notu: "(Önceki 7 güne göre)".
  String get comparisonNote => '(Önceki $days güne göre)';

  /// 7 günün dışında nokta etiketleri gizlenir.
  bool get showPointLabels => this == SalesRange.gun7;
}

/// Tarih aralığı (rapor filtreleri).
class DateTimeRange {
  const DateTimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Repository'nin fırlattığı hata — UI bunu ErrorState'e çevirir.
class DashboardException implements Exception {
  const DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
