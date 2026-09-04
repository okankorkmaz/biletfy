import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// 01 · TopBar — h 56 · yatay padding 16 · ikon 24 · başlık titleM ortalı.
///
/// Üç varyant:
/// * [AppTopBar.root] — sol hamburger, ortada başlık, sağda tek aksiyon.
/// * [AppTopBar.home] — başlık yerine sol üstte logo placeholder.
/// * [AppTopBar.push] — sol geri oku; alt navigasyon gizlenir.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Kök sekme: hamburger + ortalı başlık + tek aksiyon.
  const AppTopBar.root({
    super.key,
    required String this.title,
    this.action,
    this.onMenuTap,
  }) : _variant = _TopBarVariant.root,
       subtitle = null,
       onBackTap = null;

  /// Ana Sayfa: sol üstte logo placeholder, sağda tek aksiyon.
  const AppTopBar.home({super.key, this.action})
    : _variant = _TopBarVariant.home,
      title = null,
      subtitle = null,
      onMenuTap = null,
      onBackTap = null;

  /// Push ekran: geri oku + ortalı başlık + opsiyonel aksiyon.
  const AppTopBar.push({
    super.key,
    required String this.title,
    this.subtitle,
    this.action,
    this.onBackTap,
  }) : _variant = _TopBarVariant.push,
       onMenuTap = null;

  final _TopBarVariant _variant;
  final String? title;

  /// Push ekranda başlığın altındaki bağlam satırı (ör. etkinlik adı).
  final String? subtitle;

  final Widget? action;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;

  @override
  Size get preferredSize => const Size.fromHeight(AppSize.appBar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: switch (_variant) {
        _TopBarVariant.root => _TopBarIconButton(
          icon: AppIcons.menu,
          tooltip: 'Menü',
          onTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
        ),
        _TopBarVariant.push => _TopBarIconButton(
          icon: AppIcons.back,
          tooltip: 'Geri',
          onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        _TopBarVariant.home => null,
      },
      leadingWidth: _variant == _TopBarVariant.home
          ? null
          : AppSpace.screenX + AppSize.minTouch,
      title: switch (_variant) {
        _TopBarVariant.home => const Padding(
          padding: EdgeInsets.only(left: AppSpace.screenX),
          child: Align(
            alignment: Alignment.centerLeft,
            child: LogoPlaceholder(),
          ),
        ),
        _ => _Title(title: title!, subtitle: subtitle),
      },
      centerTitle: _variant != _TopBarVariant.home,
      actions: [?action, const SizedBox(width: AppSpace.screenX)],
    );
  }
}

enum _TopBarVariant { root, home, push }

class _Title extends StatelessWidget {
  const _Title({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return Text(title, style: AppTypography.titleM);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.titleM),
        Text(
          subtitle!,
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// App bar aksiyonu — 44×44 dokunma hedefi, 24 pt ikon.
class TopBarAction extends StatelessWidget {
  const TopBarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TopBarIconButton(icon: icon, tooltip: tooltip, onTap: onTap);
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: AppSize.minTouch / 2,
        child: SizedBox(
          width: AppSize.minTouch,
          height: AppSize.minTouch,
          child: Icon(
            icon,
            size: AppIconSize.nav,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Ana Sayfa app bar'ındaki logo placeholder — 64×32, gerçek SVG sonradan.
class LogoPlaceholder extends StatelessWidget {
  const LogoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.logoPlaceholder.width,
      height: AppSize.logoPlaceholder.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpace.sm),
        border: Border.all(
          color: AppColors.border,
          width: AppSize.borderWidth,
        ),
      ),
      child: Text(
        'LOGO',
        style: AppTypography.micro.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
