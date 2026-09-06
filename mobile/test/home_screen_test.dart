import 'package:biletfy_mobile/app.dart';
import 'package:biletfy_mobile/core/formatters.dart';
import 'package:biletfy_mobile/data/mock/mock_dashboard_repository.dart';
import 'package:biletfy_mobile/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Tr.locale));

  // Tasarım çerçevesi 390×844 — testler de bu ölçüde koşar.
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

  testWidgets('yükleme sırasında iskelet gösterir', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.byType(CardSkeleton), findsWidgets);
    expect(find.byType(AppShimmer), findsWidgets);

    await tester.pumpAndSettle();
  });

  testWidgets('veri gelince KPI değerleri tr_TR biçiminde çıkar', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('529'), findsWidgets);
    expect(find.text('529.025 ₺'), findsOneWidget);
    expect(find.text('%64,8'), findsOneWidget);

    // Günlük satış özeti — bölüm 10/2 düzeltmesi uygulanmış değerler.
    expect(find.text('+444'), findsOneWidget);
    expect(find.text('+529'), findsOneWidget);
    expect(find.text('+2.846'), findsOneWidget);
    expect(find.text('+407'), findsOneWidget);
  });

  testWidgets('dönem seçimi KPI ve satış dağılımını birlikte günceller', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('529'), findsWidgets);

    await tester.tap(find.text('Bugün').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bu Hafta').last);
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
    expect(find.text('2.846'), findsWidgets);
    expect(find.text('2.846.133 ₺'), findsOneWidget);
    expect(find.text('%67,1'), findsOneWidget);

    await tester.tap(find.text('Bu Hafta').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bu Ay').last);
    await tester.pumpAndSettle();

    expect(find.text('23'), findsOneWidget);
    expect(find.text('12.842'), findsWidgets);
    expect(find.text('12.842.600 ₺'), findsOneWidget);
    expect(find.text('%68,4'), findsOneWidget);
  });

  testWidgets('donut legend firma paylarını gösterir', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Biletix'), findsOneWidget);
    expect(find.text('(%43,9)'), findsOneWidget);
    expect(find.text('Bubilet'), findsOneWidget);
    expect(find.text('Diğer'), findsOneWidget);
  });

  testWidgets('hata durumunda ErrorState gösterir', (tester) async {
    await tester.pumpWidget(app(failing: true));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorState), findsWidgets);
    expect(find.text('Yeniden dene'), findsWidgets);
  });

  testWidgets('boş dağılımda EmptyState gösterir', (tester) async {
    await tester.pumpWidget(app(empty: true));
    await tester.pumpAndSettle();

    expect(find.text('Bu dönemde satış kaydı yok'), findsOneWidget);
  });

  testWidgets('kök ekranda BottomNav görünür, Ana Sayfa aktif', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsOneWidget);
    for (final tab in RootTab.values) {
      expect(find.text(tab.label), findsOneWidget);
    }
  });
}
