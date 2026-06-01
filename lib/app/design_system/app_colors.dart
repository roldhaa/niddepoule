import 'package:flutter/material.dart';

/// Tokens couleurs CivicRoad — source unique supportant le mode clair/sombre.
abstract final class AppColors {
  static bool isDarkMode = false;

  static Color get brandBlack => isDarkMode ? const Color(0xFF0B0C0F) : const Color(0xFFF5F6F9);
  static Color get brandBlackSoft => isDarkMode ? const Color(0xFF14161D) : const Color(0xFFFFFFFF);
  static const brandOrange = Color(0xFFFF5500);
  static const brandYellow = Color(0xFFFFB300);
  static const brandYellowMuted = Color(0xFFFFE082);

  static Color get surface => isDarkMode ? const Color(0xFF181A24) : const Color(0xFFFFFFFF);
  static Color get surfaceMuted => isDarkMode ? const Color(0xFF0B0C0F) : const Color(0xFFF5F6F9);
  static Color get surfaceElevated => isDarkMode ? const Color(0xFF202330) : const Color(0xFFFFFFFF);
  static Color get surfaceSection => isDarkMode ? const Color(0xFF1B1D28) : const Color(0xFFF5F6F9);

  static Color get textPrimary => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF17171C);
  static const textSecondary = Color(0xFF8E9099);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xB3FFFFFF);

  static Color get border => isDarkMode ? const Color(0xFF2D3142) : const Color(0xFFE2E4E8);
  static Color get borderLight => isDarkMode ? const Color(0xFF1F222F) : const Color(0xFFF1F2F6);

  static const success = Color(0xFF4CAF50);
  static const successSurface = Color(0x1A4CAF50);
  static const error = Color(0xFFF44336);
  static const errorSurface = Color(0x1AF44336);

  static const dangerLow = Color(0xFF4CAF50);
  static const dangerMedium = Color(0xFFFF9800);
  static const dangerHigh = Color(0xFFF44336);

  static const navIndicator = Color(0x26FF5500);

  static LinearGradient get welcomeGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDarkMode 
        ? [const Color(0xFF0B0C0F), const Color(0xFF0B0C0F)]
        : [const Color(0xFFFFFFFF), const Color(0xFFF5F6F9), const Color(0xFFFFE5D9)],
  );

  static LinearGradient get authGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDarkMode
        ? [const Color(0xFF0B0C0F), const Color(0xFF0B0C0F)]
        : [const Color(0xFFFFFFFF), const Color(0xFFEBEFF5), const Color(0xFFFFFFFF)],
  );

  static LinearGradient get profileHeroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDarkMode
        ? [const Color(0xFF0B0C0F), const Color(0xFF0B0C0F)]
        : [const Color(0xFFFFE5D9), const Color(0xFFFFFFFF)],
  );
}
