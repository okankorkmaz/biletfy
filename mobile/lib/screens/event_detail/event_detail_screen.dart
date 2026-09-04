import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';
import '../daily_sales/daily_sales_view.dart';
import 'detail_overview_tab.dart';
import 'detail_shows_tab.dart';

/// 03 · 11 · 12 — Etkinlik Detayı, üç sekme.
///
/// Push edilen ekran olduğu için BottomNav gizlidir; sekmeler kolaja sadık
/// olarak ekranın altındadır.
///
/// Detay seçili **gösteriye** aittir; varsayılan olarak en yakın tarihli
/// gösteri açılır ve tarih satırından değiştirilebilir.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event, this.initialShowId});

  final Event event;

  /// Takvimden gelindiğinde ilgili gösteri seçili açılır.
  final String? initialShowId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late DashboardRepository _repository;

  int _tabIndex = 0;
  Future<List<Show>>? _shows;
  Show? _selectedShow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
    _load();
  }

  void _load() {
    setState(() {
      _shows = _repository.showsOfEvent(widget.event.id);
    });
    // Hata AsyncSection tarafından gösterilir; burada yalnızca seçim yapılır.
    _shows!
        .then((shows) {
          if (!mounted || shows.isEmpty) return;
          setState(() {
            _selectedShow = shows.firstWhere(
              (show) => show.id == widget.initialShowId,
              orElse: () => shows.first,
            );
          });
        })
        .onError((_, _) {});
  }

  Future<void> _pickShow(List<Show> shows) async {
    final picked = await showModalBottomSheet<Show>(
      context: context,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.cardPadding,
                AppSpace.cardPadding,
                AppSpace.cardPadding,
                AppSpace.titleGap,
              ),
              child: Text('Gösteri seç', style: AppTypography.titleM),
            ),
            for (final show in shows)
              ListTile(
                minTileHeight: AppSize.minTouch,
                title: Text(Tr.dateTime(show.dateTime), style: AppTypography.body),
                subtitle: Text(show.venueLabel, style: AppTypography.caption),
                selected: show.id == _selectedShow?.id,
                selectedColor: AppColors.primary,
                onTap: () => Navigator.of(context).pop(show),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _selectedShow = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.push(
        title: 'Etkinlik Detayı',
        action: TopBarAction(
          icon: AppIcons.share,
          tooltip: 'Paylaş',
          onTap: () {},
        ),
      ),
      body: AsyncSection<List<Show>>(
        future: _shows,
        onRetry: _load,
        isEmpty: (shows) => shows.isEmpty,
        emptyMessage: 'Bu etkinliğe ait gösteri yok',
        skeleton: const _DetailSkeleton(),
        builder: (context, shows) {
          final show = _selectedShow ?? shows.first;
          return switch (_tabIndex) {
            0 => DetailOverviewTab(
              show: show,
              onPickShow: shows.length > 1 ? () => _pickShow(shows) : null,
            ),
            1 => DailySalesView(eventId: widget.event.id),
            _ => DetailShowsTab(
              shows: shows,
              selectedShow: show,
              onSelectShow: (picked) => setState(() => _selectedShow = picked),
            ),
          };
        },
      ),
      // BottomNav yok — kolaja sadık olarak sekmeler altta.
      bottomNavigationBar: SegmentedTabs(
        labels: const ['Genel Bakış', 'Günlük Satış', 'Detaylar'],
        selectedIndex: _tabIndex,
        onSelected: (index) => setState(() => _tabIndex = index),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenX,
        AppSpace.cardPadding,
        AppSpace.screenX,
        AppSpace.sectionGap,
      ),
      children: const [
        AppShimmer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: AppSize.posterDetail,
                height: AppSize.posterDetail,
                radius: AppRadius.posterDetail,
              ),
              SizedBox(width: AppSpace.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonBox(height: 22),
                    SizedBox(height: AppSpace.md),
                    SkeletonBox(height: 15),
                    SizedBox(height: AppSpace.chipGap),
                    SkeletonBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpace.cardPadding),
        CardSkeleton(minHeight: 140),
        SizedBox(height: AppSpace.cardGap),
        CardSkeleton(minHeight: 180),
      ],
    );
  }
}
