import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_typography.dart';
import 'package:niddepoule/app/design_system/civic_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.brandOrange,
        onPrimary: Colors.white,
        secondary: AppColors.brandYellow,
        onSecondary: AppColors.brandBlack,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
    );

    final textTheme = AppTypography.textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.brandBlack, // Reactive Color
      extensions: [CivicThemeExtension.light],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.navIndicator,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.brandOrange : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.brandOrange : AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          side: BorderSide(color: AppColors.brandOrange, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.brandOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSection,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        )),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        backgroundColor: AppColors.surfaceElevated,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandOrange,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.brandOrange,
        onPrimary: Colors.white,
        secondary: AppColors.brandYellow,
        onSecondary: AppColors.brandBlack,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
    );

    final textTheme = AppTypography.textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.brandBlack,
      extensions: [CivicThemeExtension.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brandBlack,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.brandBlack,
        indicatorColor: AppColors.navIndicator,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.brandOrange : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.brandOrange : AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          side: BorderSide(color: AppColors.brandOrange, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.brandOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSection,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        )),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        backgroundColor: AppColors.surfaceElevated,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandOrange,
      ),
    );
  }
}
