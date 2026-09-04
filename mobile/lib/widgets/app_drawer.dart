import 'package:flutter/material.dart';

import '../dev/component_gallery.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import 'app_bottom_nav.dart';
import 'app_top_bar.dart';
import 'kpi_card.dart';

/// 10_Drawer — hamburgerden açılır.
///
/// Kullanıcı adı/rol · 5 kök sekmeye kısayol · Ayarlar · sürüm etiketi.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.current,
    required this.onSelect,
    required this.version,
    this.userName = 'Okan Korkmaz',
    this.userRole = 'Prodüksiyon · BKM Mutfak',
  });

  final RootTab current;
  final ValueChanged<RootTab> onSelect;
  final String version;
  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.screenX),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoPlaceholder(),
                  const SizedBox(height: AppSpace.cardPadding),
                  Row(
                    children: [
                      const TintedIconBox(
                        icon: AppIcons.user,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpace.listCardPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(userName, style: AppTypography.bodyStrong),
                            const SizedBox(height: AppSpace.xxs),
                            Text(userRole, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpace.titleGap,
                ),
                children: [
                  for (final tab in RootTab.values)
                    _DrawerItem(
                      tab: tab,
                      selected: tab == current,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelect(tab);
                      },
                    ),
                ],
              ),
            ),
            const Divider(),
            if (ComponentGalleryScreen.isAvailable)
              _PlainDrawerItem(
                icon: AppIcons.integrations,
                label: 'Bileşen Kütüphanesi',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    ComponentGalleryScreen.routeName,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.screenX),
              child: Text('Sürüm $version', style: AppTypography.caption),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final RootTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: _PlainDrawerItem(
        icon: tab.icon,
        label: tab.label,
        onTap: onTap,
        color: selected ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }
}

class _PlainDrawerItem extends StatelessWidget {
  const _PlainDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.pressedOverlay,
      splashColor: AppColors.pressedOverlay,
      child: Container(
        height: AppSize.minTouch + AppSpace.chipGap,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenX),
        child: Row(
          children: [
            Icon(icon, size: AppIconSize.nav, color: color),
            const SizedBox(width: AppSpace.cardPadding),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
