import 'package:flutter/material.dart';

import 'data/dashboard_repository.dart';
import 'data/mock/mock_dashboard_repository.dart';
import 'data/repository_scope.dart';
import 'dev/component_gallery.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

/// Uygulama kökü.
///
/// Veri kaynağı [RepositoryScope] üzerinden verilir; API'ye geçerken burada
/// tek satır değişir, ekranlarda hiçbir değişiklik gerekmez.
class BiletfyApp extends StatelessWidget {
  const BiletfyApp({super.key, this.repository});

  /// Testlerde ve önizlemede başka bir implementasyon takmak için.
  final DashboardRepository? repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryScope(
      repository: repository ?? MockDashboardRepository(),
      child: MaterialApp(
        title: 'Etkinlik & Bilet Satış Takip',
        debugShowCheckedModeBanner: false,
        // Yalnızca koyu tema — açık tema tanımlı değil.
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const RootShell(),
        routes: {
          if (ComponentGalleryScreen.isAvailable)
            ComponentGalleryScreen.routeName: (_) =>
                const ComponentGalleryScreen(),
        },
      ),
    );
  }
}
