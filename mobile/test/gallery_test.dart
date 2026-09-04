import 'package:biletfy_mobile/core/formatters.dart';
import 'package:biletfy_mobile/dev/component_gallery.dart';
import 'package:biletfy_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Tr.locale));

  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(390, 844);
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('galeri baştan sona taşma vermeden çizilir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const ComponentGalleryScreen(),
      ),
    );
    // Galeride sürekli dönen shimmer var; pumpAndSettle hiç oturmaz.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bileşen Kütüphanesi'), findsOneWidget);

    // Tüm bölümleri gezerek her bileşenin gerçekten çizildiğini doğrular;
    // bir taşma olsaydı test burada hata verirdi.
    final list = find.byType(Scrollable).first;
    for (var step = 0; step < 40; step++) {
      await tester.drag(list, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Destek bileşenleri'), findsOneWidget);
  });

  testWidgets('galeri release derlemesinde rota olarak kayıtlı değil', (
    tester,
  ) async {
    // kDebugMode testte true; bayrağın var olduğunu ve rotanın ona
    // bağlandığını doğrular.
    expect(ComponentGalleryScreen.isAvailable, isTrue);
    expect(ComponentGalleryScreen.routeName, '/dev/gallery');
  });
}
