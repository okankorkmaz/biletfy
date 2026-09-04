import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';
import '../event_detail/event_detail_screen.dart';
import 'search_screen.dart';

/// 02_Etkinlikler — kök sekme.
///
/// TopBar (hamburger, başlık, arama) · filtre chip'leri ·
/// EventListCard listesi (Toplam Satılan azalan) · sonda toplam sayısı.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late DashboardRepository _repository;

  EventFilter _filter = EventFilter.tumu;
  Future<List<Event>>? _events;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _events = _repository.events(_filter);
    });
  }

  void _selectFilter(int index) {
    setState(() => _filter = EventFilter.values[index]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.root(
        title: 'Etkinlikler',
        onMenuTap: widget.onOpenDrawer,
        action: TopBarAction(
          icon: AppIcons.search,
          tooltip: 'Ara',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpace.titleGap),
          FilterChipRow(
            labels: [for (final filter in EventFilter.values) filter.label],
            selectedIndex: EventFilter.values.indexOf(_filter),
            onSelected: _selectFilter,
          ),
          const SizedBox(height: AppSpace.cardPadding),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _load(),
              child: AsyncSection<List<Event>>(
                future: _events,
                onRetry: _load,
                isEmpty: (events) => events.isEmpty,
                emptyMessage: 'Bu filtreye uyan etkinlik yok',
                emptyActionLabel: _filter == EventFilter.tumu
                    ? null
                    : 'Filtreyi temizle',
                onEmptyAction: () => _selectFilter(0),
                skeleton: const _EventListSkeleton(),
                builder: (context, events) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.screenX,
                    0,
                    AppSpace.screenX,
                    AppSpace.sectionGap,
                  ),
                  itemCount: events.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpace.cardGap),
                  itemBuilder: (context, index) {
                    if (index == events.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpace.titleGap),
                        child: Text(
                          '${Tr.number(events.length)} etkinlik',
                          style: AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final event = events[index];
                    return EventListCard(
                      event: event,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListSkeleton extends StatelessWidget {
  const _EventListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenX),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.cardGap),
      itemBuilder: (_, _) => const EventCardSkeleton(),
    );
  }
}
