import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    final inter = GoogleFonts.plusJakartaSansTextTheme(base);
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -1,
      ),
      displayMedium: inter.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: inter.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.35,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
      ),
    );
  }
}
