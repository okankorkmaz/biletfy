import 'package:flutter/material.dart';

import '../../data/dashboard_repository.dart';
import '../../data/repository_scope.dart';
import '../../models/event.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/widgets.dart';
import '../event_detail/event_detail_screen.dart';

/// 09_Arama — push ekran (BottomNav gizli).
///
/// Üstte arama alanı, altında EventListCard sonuçları; sorgu boşken ipucu,
/// eşleşme yokken boş durum.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late DashboardRepository _repository;

  String _query = '';
  Future<List<Event>>? _results;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = RepositoryScope.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _query = query.trim();
      _results = _query.isEmpty ? null : _repository.searchEvents(_query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.push(title: 'Arama'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screenX,
              AppSpace.titleGap,
              AppSpace.screenX,
              AppSpace.cardPadding,
            ),
            child: SearchField(
              controller: _controller,
              onChanged: _search,
              autofocus: true,
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const EmptyState(
                    message: 'Etkinlik adı ya da mekan yazarak ara',
                  )
                : AsyncSection<List<Event>>(
                    future: _results,
                    onRetry: () => _search(_query),
                    isEmpty: (events) => events.isEmpty,
                    emptyMessage: '"$_query" için sonuç bulunamadı',
                    skeleton: const _SearchSkeleton(),
                    builder: (context, events) => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.screenX,
                        0,
                        AppSpace.screenX,
                        AppSpace.sectionGap,
                      ),
                      itemCount: events.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpace.cardGap),
                      itemBuilder: (context, index) => EventListCard(
                        event: events[index],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EventDetailScreen(event: events[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenX),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.cardGap),
      itemBuilder: (_, _) => const EventCardSkeleton(),
    );
  }
}
