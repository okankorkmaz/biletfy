import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Uygulama teması — yalnızca koyu tema.
///
/// `lightTheme` yoktur; [MaterialApp.themeMode] sabit [ThemeMode.dark].
/// Token JSON `theme` bloğu: `brightness: dark`, `lightTheme: false`,
/// `elevation: 0`. Gölge, blur, yükselti yok — tamamen flat.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      textTheme: AppTypography.textTheme,
      primaryTextTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppIconSize.nav,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppSize.borderWidth,
        space: AppSize.borderWidth,
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: AppSize.appBar,
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTypography.titleM,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppIconSize.nav,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppIconSize.nav,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardR,
          side: const BorderSide(
            color: AppColors.border,
            width: AppSize.borderWidth,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: AppTypography.label,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cellR,
          side: const BorderSide(
            color: AppColors.border,
            width: AppSize.borderWidth,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        linearMinHeight: AppSize.progressList,
      ),
      splashFactory: InkSparkle.splashFactory,
      highlightColor: AppColors.pressedOverlay,
      splashColor: AppColors.pressedOverlay,
    );
  }

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.onPrimary,
    tertiary: AppColors.purple,
    onTertiary: AppColors.onPrimary,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: Colors.transparent,
    scrim: Colors.transparent,
  );
}
