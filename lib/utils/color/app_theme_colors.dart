import 'package:flutter/material.dart';

import 'app_colors.dart';

/// semantic, theme-aware colours. screens read these, never [AppColors]
/// directly, so dark mode is a single place to change.
class AppThemeColors {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primarySoft,
    required this.error,
    required this.success,
    required this.warning,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primarySoft;
  final Color error;
  final Color success;
  final Color warning;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const AppThemeColors light = AppThemeColors(
    background: AppColors.white,
    surface: AppColors.white,
    surfaceAlt: AppColors.lightGrey,
    border: AppColors.boulder,
    textPrimary: AppColors.ink,
    textSecondary: AppColors.inkSecondary,
    textMuted: AppColors.greyLight,
    primary: AppColors.primary,
    primarySoft: AppColors.pinkLight,
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    shimmerBase: AppColors.gray200,
    shimmerHighlight: AppColors.gray100,
  );

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1E),
    surfaceAlt: Color(0xFF2C2C2E),
    border: Color(0xFF3A3A3C),
    textPrimary: AppColors.white,
    textSecondary: Color(0xFFB0B0B5),
    textMuted: Color(0xFF8E8E93),
    primary: Color(0xFFE5484D),
    primarySoft: Color(0xFF3A1F21),
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    shimmerBase: Color(0xFF2C2C2E),
    shimmerHighlight: Color(0xFF3A3A3C),
  );

  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
