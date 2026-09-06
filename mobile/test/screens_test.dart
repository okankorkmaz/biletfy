import 'package:biletfy_mobile/app.dart';
import 'package:biletfy_mobile/core/formatters.dart';
import 'package:biletfy_mobile/data/mock/mock_dashboard_repository.dart';
import 'package:biletfy_mobile/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Tr.locale));

  // Tasarım çerçevesi 390×844.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(390, 844);
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget app({bool failing = false, bool empty = false}) => BiletfyApp(
    initiallyAuthenticated: true,
    repository: MockDashboardRepository(
      latency: const Duration(milliseconds: 10),
      failing: failing,
      empty: empty,
    ),
  );

  /// Kök sekmeye geçer ve yüklemenin bitmesini bekler.
  Future<void> goToTab(WidgetTester tester, RootTab tab) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text(tab.label).last);
    await tester.pumpAndSettle();
  }

  /// 390 pt genişlikte chip'ler yatay olarak taşabilir — önce görünür kılar.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Dikey listede aşağıda kalan içeriği görünür alana getirir.
  Future<void> scrollToVertical(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }

  group('02_Etkinlikler', () {
    testWidgets('liste Toplam Satılan azalan sırada gelir', (tester) async {
      await goToTab(tester, RootTab.events);

      expect(find.text('Çok Güzel Hareketler 2'), findsOneWidget);
      expect(find.text('5.312'), findsOneWidget);
      expect(find.text('%71,2'), findsOneWidget);

      await scrollToVertical(tester, find.text('7 etkinlik'));
      expect(find.text('7 etkinlik'), findsOneWidget);
    });

    testWidgets('durum filtresi listeyi daraltır', (tester) async {
      await goToTab(tester, RootTab.events);

      // Chip satırı 390 pt'ye sığmaz; son chip lazy olduğu için önce kaydır.
      await tester.drag(find.byType(FilterChipRow), const Offset(-200, 0));
      await tester.pumpAndSettle();

      // "Tamamlanan" hem chip'te hem kart durum metninde geçer — chip'i seç.
      await tester.tap(find.widgetWithText(AppFilterChip, 'Tamamlanan'));
      await tester.pumpAndSettle();

      expect(find.text('Gece Yarısı Kabare'), findsOneWidget);
      expect(find.text('Çok Güzel Hareketler 2'), findsNothing);
      expect(find.text('Doğaçlama Gecesi'), findsOneWidget);
    });

    testWidgets('karta dokununca detay açılır ve BottomNav gizlenir', (
      tester,
    ) async {
      await goToTab(tester, RootTab.events);

      await tester.tap(find.text('Çok Güzel Hareketler 2'));
      await tester.pumpAndSettle();

      expect(find.text('Etkinlik Detayı'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);
      expect(find.byType(SegmentedTabs), findsOneWidget);
    });
  });

  group('03_EtkinlikDetayi', () {
    Future<void> openDetail(WidgetTester tester) async {
      await goToTab(tester, RootTab.events);
      await tester.tap(find.text('Çok Güzel Hareketler 2'));
      await tester.pumpAndSettle();
    }

    testWidgets('Genel Bakış sekmesi şartname değerlerini gösterir', (
      tester,
    ) async {
      await openDetail(tester);

      // Kapasite 850 · Satılan 643 · Kalan 207 · Doluluk %75,6
      expect(find.text('850'), findsOneWidget);
      expect(find.text('643'), findsWidgets);
      expect(find.text('207'), findsOneWidget);
      expect(find.text('%75,6'), findsOneWidget);

      expect(find.text('643.000 ₺'), findsOneWidget);
      expect(find.text('1.000 ₺'), findsOneWidget);

      // Bölüm 10/1 düzeltmesi: tarih 15 Mayıs, 15 Eylül değil.
      expect(find.text('15 Mayıs 2026 - 20:30'), findsOneWidget);
      expect(find.text('İstanbul - Zorlu PSM'), findsOneWidget);

      // Firma dağılımı 310 + 220 + 83 + 30 = 643
      expect(find.text('310'), findsOneWidget);
      expect(find.text('%48,2'), findsOneWidget);
    });

    testWidgets('sekmeler arasında geçiş yapılır', (tester) async {
      await openDetail(tester);

      await tester.tap(find.text('Detaylar'));
      await tester.pumpAndSettle();
      expect(find.text('Gösteriler (8)'), findsOneWidget);

      await tester.tap(find.text('Günlük Satış').last);
      await tester.pumpAndSettle();
      expect(find.text('Günlük Satış Rakamları'), findsOneWidget);
    });

    testWidgets(
      'sekiz gösteriyi listeler ve seçilen gösterinin detayını açar',
      (tester) async {
        await openDetail(tester);

        await tester.tap(find.text('Detaylar'));
        await tester.pumpAndSettle();

        expect(find.text('Gösteriler (8)'), findsOneWidget);
        expect(find.text('Zorlu PSM - İstanbul'), findsOneWidget);

        await scrollToVertical(tester, find.text('Congresium Ankara - Ankara'));
        await tester.tap(find.text('Congresium Ankara - Ankara'));
        await tester.pumpAndSettle();

        expect(find.text('Ankara - Congresium Ankara'), findsOneWidget);
        expect(find.text('16 Mayıs 2026 - 20:30'), findsOneWidget);
        expect(find.text('1.000'), findsOneWidget);
        expect(find.text('720'), findsWidgets);
        expect(find.text('%72,0'), findsOneWidget);
      },
    );
  });

  group('04_GunlukSatis', () {
    testWidgets('Ana Sayfa kartından açılır, hero ve tablo dolu', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Günlük Satış Özeti'));
      await tester.pumpAndSettle();

      expect(find.text('Son 7 Gün Toplam'), findsOneWidget);
      expect(find.text('+2.846'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);

      expect(find.text('15 Mayıs 2026'), findsOneWidget);
      expect(find.text('529'), findsWidgets);
    });
  });

  group('05_Raporlar', () {
    testWidgets('Satış sekmesi donut ve aylık trendi gösterir', (tester) async {
      await goToTab(tester, RootTab.reports);

      expect(find.text('Satış Dağılımı (Tüm Etkinlikler)'), findsOneWidget);
      expect(find.text('(%43,9)'), findsOneWidget);

      await scrollToVertical(tester, find.text('Aylık Satış Trendi'));
      expect(find.text('Aylık Satış Trendi'), findsOneWidget);
    });

    testWidgets('Firmalar sekmesi karşılaştırma tablosunu gösterir', (
      tester,
    ) async {
      await goToTab(tester, RootTab.reports);

      await tapVisible(tester, find.text('Firmalar'));
      await tester.pumpAndSettle();

      expect(find.text('Firma Karşılaştırma'), findsOneWidget);
      expect(find.text('Ort. Fiyat'), findsOneWidget);
      expect(find.text('1.050 ₺'), findsOneWidget);
    });

    testWidgets('Doluluk sekmesi sıralamayı gösterir', (tester) async {
      await goToTab(tester, RootTab.reports);

      await tapVisible(tester, find.text('Doluluk'));
      await tester.pumpAndSettle();

      expect(find.text('Etkinliklere Göre Doluluk'), findsOneWidget);
      // En yüksek doluluk Doğaçlama Gecesi %94,2.
      expect(find.text('%94,2'), findsOneWidget);
    });
  });

  group('06_Takvim', () {
    testWidgets('15 Mayıs 2026 Cuma seçili, gösteriler satılan azalan', (
      tester,
    ) async {
      await goToTab(tester, RootTab.calendar);

      expect(find.text('Mayıs 2026'), findsOneWidget);
      expect(find.text('15 Mayıs 2026 Cuma'), findsOneWidget);

      // Hafta pazartesi başlar.
      expect(find.text('Pzt'), findsOneWidget);
      expect(find.text('Paz'), findsOneWidget);

      expect(find.text('20:30'), findsWidgets);
      expect(find.text('643'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
    });

    testWidgets('gösteri satırından detay açılır', (tester) async {
      await goToTab(tester, RootTab.calendar);

      await tester.tap(find.text('Doğu Demirkol'));
      await tester.pumpAndSettle();

      expect(find.text('Etkinlik Detayı'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);
    });

    testWidgets('işaretli gün seçilince o günün gösterileri yüklenir', (
      tester,
    ) async {
      await goToTab(tester, RootTab.calendar);

      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();

      expect(find.text('16 Mayıs 2026 Cumartesi'), findsOneWidget);
      expect(find.text('Çok Güzel Hareketler 2'), findsOneWidget);
      expect(find.text('Congresium Ankara - Ankara'), findsOneWidget);
      expect(find.text('720'), findsOneWidget);
    });

    testWidgets('işaretsiz gün seçilince doğru boş durum gösterilir', (
      tester,
    ) async {
      await goToTab(tester, RootTab.calendar);

      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();

      expect(find.text('14 Mayıs 2026 Perşembe'), findsOneWidget);
      expect(find.text('Bu tarihte etkinlik bulunmuyor.'), findsOneWidget);
    });
  });

  group('07_Ayarlar', () {
    testWidgets('gruplar ve entegrasyon durumları görünür', (tester) async {
      await goToTab(tester, RootTab.settings);

      expect(find.text('Bildirimler'), findsWidgets);
      expect(find.text('Veri kaynakları'), findsOneWidget);
      expect(find.text('Biletix'), findsOneWidget);
      expect(find.text('Bağlı'), findsWidgets);
      expect(find.text('Bağla'), findsOneWidget);

      await scrollToVertical(tester, find.text('Sürüm'));
      expect(find.text('Türk lirası (₺)'), findsOneWidget);
      expect(find.text('Pazartesi'), findsOneWidget);
    });

    testWidgets('hesap satırı profil ekranını açar ve bilgiyi günceller', (
      tester,
    ) async {
      await goToTab(tester, RootTab.settings);

      await tester.tap(find.text('Okan Korkmaz'));
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Hesap bilgileri'), findsOneWidget);
      expect(find.text('okan.korkmaz@biletfy.com'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, 'Okan K.');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('Okan K.'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
    });
  });

  group('08_Bildirimler', () {
    testWidgets('zil ikonundan açılır, tarih gruplu listelenir', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Bildirimler'));
      await tester.pumpAndSettle();

      expect(find.text('Bugün'), findsOneWidget);
      expect(find.text('Dün'), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);
    });
  });

  group('09_Arama', () {
    testWidgets('sorgu eşleşen etkinlikleri getirir', (tester) async {
      await goToTab(tester, RootTab.events);

      await tester.tap(find.byTooltip('Ara'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'doğu');
      await tester.pumpAndSettle();

      expect(find.text('Doğu Demirkol'), findsOneWidget);
      expect(find.text('Çok Güzel Hareketler 2'), findsNothing);
    });

    testWidgets('eşleşme yoksa boş durum gösterilir', (tester) async {
      await goToTab(tester, RootTab.events);

      await tester.tap(find.byTooltip('Ara'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('"zzzz" için sonuç bulunamadı'), findsOneWidget);
    });
  });

  group('10_Drawer', () {
    testWidgets('hamburgerden açılır, sekmeye geçirir', (tester) async {
      await goToTab(tester, RootTab.events);

      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();

      expect(find.text('Okan Korkmaz'), findsOneWidget);
      expect(find.textContaining('Sürüm'), findsOneWidget);

      await tester.tap(find.text('Raporlar').last);
      await tester.pumpAndSettle();

      expect(find.text('Firmalar'), findsOneWidget);
    });
  });

  group('Durumlar', () {
    testWidgets('hata durumu her kök sekmede ErrorState gösterir', (
      tester,
    ) async {
      for (final tab in [RootTab.events, RootTab.reports, RootTab.calendar]) {
        await tester.pumpWidget(app(failing: true));
        await tester.pumpAndSettle();
        await tester.tap(find.text(tab.label).last);
        await tester.pumpAndSettle();

        expect(
          find.byType(ErrorState),
          findsWidgets,
          reason: '${tab.label} sekmesinde hata durumu görünmeli',
        );
      }
    });

    testWidgets('boş veri Etkinlikler ekranında EmptyState gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(app(empty: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Etkinlikler').last);
      await tester.pumpAndSettle();

      expect(find.text('Bu filtreye uyan etkinlik yok'), findsOneWidget);
    });
  });
}
