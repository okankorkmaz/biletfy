import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'calendar/calendar_screen.dart';
import 'daily_sales/daily_sales_screen.dart';
import 'events/events_screen.dart';
import 'home/home_screen.dart';
import 'notifications/notifications_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

/// Kök kabuk — 5 sekmeli BottomNav yalnızca burada görünür.
///
/// Push edilen ekranlar (Etkinlik Detayı, Günlük Satış, Arama, Bildirimler)
/// bu kabuğun üstüne itilir; kabuk arkada kaldığı için alt navigasyon
/// otomatik olarak gizlenir.
class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialTab = RootTab.home});

  final RootTab initialTab;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late RootTab _current = widget.initialTab;

  void _select(RootTab tab) => setState(() => _current = tab);

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _push(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        current: _current,
        onSelect: _select,
        version: kAppVersion,
      ),
      body: IndexedStack(
        index: RootTab.values.indexOf(_current),
        children: [
          HomeScreen(
            onOpenEvents: () => _select(RootTab.events),
            onOpenReports: () => _select(RootTab.reports),
            onOpenDailySales: () => _push(const DailySalesScreen()),
            onOpenNotifications: () => _push(const NotificationsScreen()),
          ),
          EventsScreen(onOpenDrawer: _openDrawer),
          ReportsScreen(onOpenDrawer: _openDrawer),
          CalendarScreen(onOpenDrawer: _openDrawer),
          SettingsScreen(onOpenDrawer: _openDrawer),
        ],
      ),
      bottomNavigationBar: AppBottomNav(current: _current, onSelected: _select),
    );
  }
}
