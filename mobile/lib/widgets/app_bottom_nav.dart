import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Kök sekmeler. Sıra kolajla birebir.
enum RootTab {
  home('Ana Sayfa', AppIcons.navHome),
  events('Etkinlikler', AppIcons.navEvents),
  reports('Raporlar', AppIcons.navReports),
  calendar('Takvim', AppIcons.navCalendar),
  settings('Ayarlar', AppIcons.navSettings);

  const RootTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// 02 · BottomNav — h 56 + alt safe area · ikon 24 + navLabel ·
/// üst 1 pt border · aktif primary, pasif textSecondary.
///
/// Push edilen ekranlarda gösterilmez.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final RootTab current;
  final ValueChanged<RootTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppSize.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSize.bottomNav,
          child: Row(
            children: [
              for (final tab in RootTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    selected: tab == current,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final RootTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: AppIconSize.nav, color: color),
            SizedBox(height: AppSpace.xs),
            Text(tab.label, style: AppTypography.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
