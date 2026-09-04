import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/reports.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

/// 08_Bildirimler — push ekran, BottomNav gizli.
///
/// Tarih gruplu liste ("Bugün", "Dün", tarih); okunmamış satırlarda solda
/// 6 pt primary nokta.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late DashboardRepository _repository;
  Future<List<AppNotification>>? _notifications;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _notifications = _repository.notifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.push(title: 'Bildirimler'),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: AsyncSection<List<AppNotification>>(
          future: _notifications,
          onRetry: _load,
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Henüz bildirim yok',
          skeleton: const _NotificationsSkeleton(),
          builder: (context, items) => _GroupedList(
            items: items,
            today: _repository.referenceDate,
          ),
        ),
      ),
    );
  }
}

/// Bildirimleri güne göre gruplar; başlıklar "Bugün" / "Dün" / tarih.
class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items, required this.today});

  final List<AppNotification> items;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<AppNotification>>{};
    for (final item in items) {
      groups.putIfAbsent(_labelFor(item.time), () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenX,
        AppSpace.cardPadding,
        AppSpace.screenX,
        AppSpace.sectionGap,
      ),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.titleGap),
            child: Text(entry.key, style: AppTypography.caption),
          ),
          for (final (index, item) in entry.value.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpace.chipGap),
            NotificationRow(notification: item, onTap: () {}),
          ],
          const SizedBox(height: AppSpace.sectionGap),
        ],
      ],
    );
  }

  String _labelFor(DateTime time) {
    final day = DateTime(time.year, time.month, time.day);
    final reference = DateTime(today.year, today.month, today.day);
    final difference = reference.difference(day).inDays;
    return switch (difference) {
      0 => 'Bugün',
      1 => 'Dün',
      _ => Tr.date(day),
    };
  }
}

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenX,
        AppSpace.cardPadding,
        AppSpace.screenX,
        AppSpace.sectionGap,
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.chipGap),
      itemBuilder: (_, _) => const AppShimmer(
        child: SkeletonBox(height: 68, radius: AppRadius.card),
      ),
    );
  }
}
