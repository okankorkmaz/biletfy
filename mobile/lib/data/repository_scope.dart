import 'package:flutter/widgets.dart';

import 'dashboard_repository.dart';

/// Repository'yi ağaç boyunca taşır.
///
/// Ekranlar `RepositoryScope.of(context)` ile yalnızca [DashboardRepository]
/// arayüzüne erişir; hangi implementasyonun takılı olduğunu bilmezler.
class RepositoryScope extends InheritedWidget {
  const RepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final DashboardRepository repository;

  static DashboardRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'RepositoryScope ağaçta bulunamadı');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) =>
      repository != oldWidget.repository;
}
