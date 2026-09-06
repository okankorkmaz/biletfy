import 'package:biletfy_mobile/data/mock/mock_fixtures.dart';
import 'package:biletfy_mobile/services/event_share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('tr_TR'));

  test('paylaşım metni seçili gösterinin tarih ve mekanını içerir', () {
    final event = MockFixtures.events.first;
    final show = MockFixtures.shows.first;

    final message = EventShareService.message(event: event, show: show);

    expect(message, contains(event.title));
    expect(message, contains('15 Mayıs 2026 - 20:30'));
    expect(message, contains('İstanbul - Zorlu PSM'));
    expect(message, contains('Durum: Devam Eden'));
  });
}
