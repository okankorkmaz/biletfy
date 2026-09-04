import 'package:flutter/material.dart';

import '../../theme/app_icons.dart';
import '../../widgets/widgets.dart';
import 'daily_sales_view.dart';

/// 04_GunlukSatis — push ekran, BottomNav gizli.
///
/// Ana Sayfa'daki "Günlük Satış Özeti" kartından açılır. Etkinlik Detayı'ndan
/// açıldığında başlığın altında etkinlik adı görünür.
class DailySalesScreen extends StatelessWidget {
  const DailySalesScreen({super.key, this.eventId, this.eventTitle});

  final String? eventId;
  final String? eventTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.push(
        title: 'Günlük Satış',
        subtitle: eventTitle,
        action: TopBarAction(
          icon: AppIcons.calendarAction,
          tooltip: 'Tarih aralığı seç',
          onTap: () => _pickRange(context),
        ),
      ),
      body: DailySalesView(eventId: eventId),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027, 12, 31),
      locale: const Locale('tr', 'TR'),
    );
  }
}
