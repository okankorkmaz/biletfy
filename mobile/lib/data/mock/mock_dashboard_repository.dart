import 'dart:math' as math;

import '../../models/event.dart';
import '../../models/reports.dart';
import '../../models/vendor.dart';
import '../dashboard_repository.dart';
import 'mock_fixtures.dart';

/// [DashboardRepository]'nin mock implementasyonu.
///
/// Ağ gecikmesini taklit eder ki ekranlardaki skeleton durumu gerçek koşulda
/// da görülebilsin. API'ye geçildiğinde bu sınıf yerine `ApiDashboardRepository`
/// takılır; ekranlarda tek satır değişmez.
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository({
    this.latency = const Duration(milliseconds: 600),
    this.failing = false,
    this.empty = false,
  });

  /// Taklit edilen ağ gecikmesi.
  final Duration latency;

  /// `true` ise her çağrı [DashboardException] fırlatır — hata durumu provası.
  final bool failing;

  /// `true` ise listeler boş döner — boş durum provası.
  final bool empty;

  @override
  DateTime get referenceDate => MockFixtures.today;

  Future<T> _respond<T>(T value) async {
    await Future<void>.delayed(latency);
    if (failing) {
      throw const DashboardException('Veriler yüklenemedi');
    }
    return value;
  }

  @override
  Future<Overview> overview(OverviewPeriod period) {
    final base = MockFixtures.overview;
    // Dönem daraldıkça toplamlar küçülür; oranlar korunur.
    final factor = switch (period) {
      OverviewPeriod.bugun => 1.0,
      OverviewPeriod.buHafta => 1.0,
      OverviewPeriod.buAy => 1.0,
      OverviewPeriod.tumu => 1.0,
    };
    return _respond(
      Overview(
        totalEvents: base.totalEvents,
        totalSold: (base.totalSold * factor).round(),
        totalRevenue: (base.totalRevenue * factor).round(),
        avgOccupancy: base.avgOccupancy,
        updatedAt: base.updatedAt,
      ),
    );
  }

  @override
  Future<List<VendorShare>> vendorBreakdown({DateTimeRange? range}) =>
      _respond(empty ? const <VendorShare>[] : MockFixtures.vendorBreakdown);

  @override
  Future<DailySalesSummary> dailySummary(int days) =>
      _respond(MockFixtures.dailySummary);

  @override
  Future<List<Event>> events(EventFilter filter) {
    if (empty) return _respond(const <Event>[]);
    final all = MockFixtures.events;
    final filtered = filter.status == null
        ? all
        : all.where((event) => event.status == filter.status).toList();
    // Şartname: Toplam Satılan azalan.
    final sorted = [...filtered]
      ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
    return _respond(sorted);
  }

  @override
  Future<List<Show>> showsOfEvent(String eventId) {
    final shows =
        MockFixtures.shows.where((show) => show.eventId == eventId).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return _respond(shows);
  }

  @override
  Future<Show> show(String showId) {
    final match = MockFixtures.shows.where((show) => show.id == showId);
    if (match.isEmpty) {
      return Future<Show>.error(
        const DashboardException('Gösteri bulunamadı'),
      );
    }
    return _respond(match.first);
  }

  @override
  Future<List<DailySales>> dailySales(SalesRange range, {String? eventId}) {
    if (empty) return _respond(const <DailySales>[]);

    final source = MockFixtures.dailySales;
    if (range == SalesRange.gun7) {
      return _respond(_scaled(source, eventId));
    }

    // Daha uzun aralıklar için seriyi geriye doğru üretir; tohum sabit
    // olduğundan her açılışta aynı veri gelir.
    final random = math.Random(range.days);
    final generated = <DailySales>[];
    for (var offset = range.days - 1; offset >= 0; offset--) {
      final date = MockFixtures.today.subtract(Duration(days: offset));
      final sameDay = source.where(
        (point) =>
            point.date.year == date.year &&
            point.date.month == date.month &&
            point.date.day == date.day,
      );
      final sold = sameDay.isNotEmpty
          ? sameDay.first.sold
          : 240 + random.nextInt(300);
      generated.add(DailySales(date: date, sold: sold));
    }
    return _respond(_scaled(generated, eventId));
  }

  @override
  Future<double> salesTrend(SalesRange range, {String? eventId}) {
    // 7 gün için şartnamedeki değer; diğer aralıklar sabit tohumla türetilir.
    if (range == SalesRange.gun7) return _respond(18.6);
    final random = math.Random(range.days);
    return _respond((random.nextDouble() * 40 - 10).roundToDouble() + 0.4);
  }

  /// Etkinlik bazlı görünümde seri, o etkinliğin toplam payına göre ölçeklenir.
  List<DailySales> _scaled(List<DailySales> series, String? eventId) {
    if (eventId == null) return series;
    final event = MockFixtures.events.where((item) => item.id == eventId);
    if (event.isEmpty) return series;
    final ratio = event.first.totalSold / MockFixtures.overview.totalSold;
    return [
      for (final point in series)
        DailySales(
          date: point.date,
          sold: math.max(1, (point.sold * ratio).round()),
        ),
    ];
  }

  @override
  Future<List<SalesBucket>> monthlyBuckets(DateTime month) {
    if (month.year == 2026 && month.month == 5) {
      return _respond(MockFixtures.mayBuckets);
    }
    // Diğer aylarda veri yok — grafikte "–" gösterilir.
    final first = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return _respond([
      SalesBucket(start: first, end: DateTime(month.year, month.month, 7)),
      SalesBucket(
        start: DateTime(month.year, month.month, 8),
        end: DateTime(month.year, month.month, 15),
      ),
      SalesBucket(
        start: DateTime(month.year, month.month, 16),
        end: DateTime(month.year, month.month, 23),
      ),
      SalesBucket(
        start: DateTime(month.year, month.month, 24),
        end: DateTime(month.year, month.month, lastDay),
      ),
    ]);
  }

  @override
  Future<List<Show>> showsOnDay(DateTime day) {
    if (empty) return _respond(const <Show>[]);
    final shows =
        MockFixtures.shows
            .where(
              (show) =>
                  show.dateTime.year == day.year &&
                  show.dateTime.month == day.month &&
                  show.dateTime.day == day.day,
            )
            .toList()
          // Şartname: satılan azalan.
          ..sort((a, b) => b.sold.compareTo(a.sold));
    return _respond(shows);
  }

  @override
  Future<Set<DateTime>> eventDaysOfMonth(DateTime month) {
    if (month.year == 2026 && month.month == 5) {
      return _respond(MockFixtures.mayEventDays);
    }
    return _respond(const <DateTime>{});
  }

  // --- Raporlar ---

  @override
  Future<List<VendorShare>> revenueBreakdown({DateTimeRange? range}) =>
      _respond(empty ? const <VendorShare>[] : MockFixtures.revenueBreakdown);

  @override
  Future<List<SalesBucket>> revenueBuckets(DateTime month) {
    if (month.year == 2026 && month.month == 5) {
      return _respond(MockFixtures.mayRevenueBuckets);
    }
    return monthlyBuckets(month).then(
      (buckets) => [
        for (final bucket in buckets)
          SalesBucket(start: bucket.start, end: bucket.end),
      ],
    );
  }

  @override
  Future<List<Event>> occupancyRanking() {
    if (empty) return _respond(const <Event>[]);
    final sorted = [...MockFixtures.events]
      ..sort((a, b) => b.occupancyPct.compareTo(a.occupancyPct));
    return _respond(sorted);
  }

  @override
  Future<double> averageOccupancy() =>
      _respond(MockFixtures.overview.avgOccupancy);

  @override
  Future<List<VendorStat>> vendorStats() =>
      _respond(empty ? const <VendorStat>[] : MockFixtures.vendorStats);

  @override
  Future<Map<Vendor, List<DailySales>>> vendorSeries(SalesRange range) async {
    final total = await dailySales(range);
    if (total.isEmpty) return {};
    return {
      for (final stat in MockFixtures.vendorStats)
        stat.vendor: [
          for (final point in total)
            DailySales(
              date: point.date,
              // Firma payı sabit oranla dağıtılır.
              sold: math.max(1, (point.sold * stat.pct / 100).round()),
            ),
        ],
    };
  }

  // --- Etkinlik detayı ---

  @override
  Future<List<PriceTier>> priceTiers(String showId) {
    if (showId == 'cgh2-15may') return _respond(MockFixtures.priceTiers);
    // Diğer gösterilerde kademeler satılan adede göre ölçeklenir.
    final match = MockFixtures.shows.where((show) => show.id == showId);
    if (match.isEmpty) return _respond(const <PriceTier>[]);
    final ratio = match.first.sold / 643;
    return _respond([
      for (final tier in MockFixtures.priceTiers)
        PriceTier(
          name: tier.name,
          price: tier.price,
          sold: math.max(0, (tier.sold * ratio).round()),
        ),
    ]);
  }

  // --- Diğer ---

  @override
  Future<List<AppNotification>> notifications() =>
      _respond(empty ? const <AppNotification>[] : MockFixtures.notifications);

  @override
  Future<List<Event>> searchEvents(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return _respond(const <Event>[]);
    final venues = {
      for (final show in MockFixtures.shows)
        show.eventId: '${show.venue} ${show.city}'.toLowerCase(),
    };
    final matches = MockFixtures.events.where((event) {
      final haystack = '${event.title.toLowerCase()} ${venues[event.id] ?? ''}';
      return haystack.contains(trimmed);
    }).toList();
    return _respond(matches);
  }

  @override
  Future<List<VendorIntegration>> integrations() =>
      _respond(MockFixtures.integrations);
}
