import 'package:biletfy_mobile/app.dart';
import 'package:biletfy_mobile/core/formatters.dart';
import 'package:biletfy_mobile/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Tr.locale));

  testWidgets('uygulama giriş ekranıyla açılır ve demo oturumu başlatır', (
    tester,
  ) async {
    await tester.pumpWidget(const BiletfyApp());

    expect(find.text('Biletfy’ye Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsNWidgets(2));
    expect(find.text('Kayıt Ol'), findsOneWidget);
    expect(find.text('Beni Hatırla'), findsOneWidget);
    expect(find.textContaining('Demo:'), findsNothing);
    expect(find.text('Güvenli Oturum Altyapısı'), findsNothing);
    expect(find.byType(AppBottomNav), findsNothing);

    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Face ID ile Hızlı Giriş'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Apple'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Google'))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'demo@biletfy.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Biletfy123');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.text('Biletfy’ye Hoş Geldiniz'), findsNothing);
  });

  testWidgets('şifremi unuttum diyaloğu geri bildirim verir', (tester) async {
    await tester.pumpWidget(const BiletfyApp());

    await tester.tap(find.text('Şifremi Unuttum?'));
    await tester.pumpAndSettle();
    expect(find.text('Şifremi Unuttum'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'demo@biletfy.com');
    await tester.tap(find.text('Bağlantı Gönder'));
    await tester.pumpAndSettle();

    expect(
      find.text('Şifre yenileme bağlantısı demo@biletfy.com için hazırlandı.'),
      findsOneWidget,
    );
  });
}
