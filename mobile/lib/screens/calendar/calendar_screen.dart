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

/// 06_Takvim — kök sekme.
///
/// CalendarMonth (Pazartesi başlangıçlı) · seçili günün başlığı ·
/// o günün gösterileri (satılan azalan).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DashboardRepository _repository;

  /// "Bugün" repository'den gelir — cihaz saatinden değil.
  late DateTime _today;
  late DateTime _month;
  late DateTime _selectedDay;

  Future<Set<DateTime>>? _eventDays;
  Future<List<Show>>? _dayShows;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    if (!_initialized) {
      _today = _repository.referenceDate;
      _month = DateTime(_today.year, _today.month);
      _selectedDay = _today;
      _initialized = true;
    }
    _load();
  }

  void _load() {
    setState(() {
      _eventDays = _repository.eventDaysOfMonth(_month);
      _dayShows = _repository.showsOnDay(_selectedDay);
    });
  }

  void _goToToday() {
    setState(() {
      _month = DateTime(_today.year, _today.month);
      _selectedDay = _today;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.root(
        title: 'Takvim',
        onMenuTap: widget.onOpenDrawer,
        action: TopBarAction(
          icon: AppIcons.calendarAction,
          tooltip: 'Bugüne git',
          onTap: _goToToday,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screenX,
            AppSpace.titleGap,
            AppSpace.screenX,
            AppSpace.sectionGap,
          ),
          children: [
            SectionCard(
              child: FutureBuilder<Set<DateTime>>(
                future: _eventDays,
                builder: (context, snapshot) => CalendarMonth(
                  month: _month,
                  selectedDate: _selectedDay,
                  today: _today,
                  eventDays: snapshot.data ?? const {},
                  onSelectDate: (date) {
                    setState(() {
                      _selectedDay = date;
                      // Komşu ay gününe basılırsa o aya geçilir.
                      if (date.month != _month.month) {
                        _month = DateTime(date.year, date.month);
                      }
                    });
                    _load();
                  },
                  onMonthChanged: (month) {
                    setState(() => _month = month);
                    _load();
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            Text(Tr.dateWithWeekday(_selectedDay), style: AppTypography.titleM),
            const SizedBox(height: AppSpace.titleGap),

            AsyncSection<List<Show>>(
              future: _dayShows,
              onRetry: _load,
              isEmpty: (shows) => shows.isEmpty,
              emptyMessage: 'Bu tarihte etkinlik bulunmuyor.',
              skeleton: const AppShimmer(
                child: Column(
                  children: [
                    SkeletonBox(height: 72, radius: AppRadius.card),
                    SizedBox(height: AppSpace.chipGap),
                    SkeletonBox(height: 72, radius: AppRadius.card),
                  ],
                ),
              ),
              builder: (context, shows) => Column(
                children: [
                  for (final (index, show) in shows.indexed) ...[
                    if (index > 0) const SizedBox(height: AppSpace.chipGap),
                    DayEventRow(show: show, onTap: () => _openDetail(show)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(Show show) async {
    final events = await _repository.events(EventFilter.tumu);
    if (!mounted) return;
    final match = events.where((event) => event.id == show.eventId);
    if (match.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EventDetailScreen(event: match.first, initialShowId: show.id),
      ),
    );
  }
}
