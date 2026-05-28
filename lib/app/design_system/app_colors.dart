import 'package:flutter/material.dart';

/// Tokens couleurs CivicRoad — source unique.
abstract final class AppColors {
  static const brandBlack = Color(0xFF171717);
  static const brandBlackSoft = Color(0xFF2A2A2A);
  static const brandYellow = Color(0xFFF4C430);
  static const brandYellowMuted = Color(0xFFFFE082);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEDEDED);
  static const surfaceElevated = Color(0xFFF7F7F7);
  static const surfaceSection = Color(0xFFF2F2F2);

  static const textPrimary = Color(0xFF171717);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xB3FFFFFF);

  static const border = Color(0xFFE0E0E0);
  static const borderLight = Color(0xFFF0F0F0);

  static const success = Color(0xFF2E7D32);
  static const successSurface = Color(0xFFE8F5E9);
  static const error = Color(0xFFC62828);
  static const errorSurface = Color(0xFFFFEBEE);

  static const dangerLow = Color(0xFF43A047);
  static const dangerMedium = Color(0xFFFB8C00);
  static const dangerHigh = Color(0xFFE53935);

  static const navIndicator = Color(0x33F4C430);

  static const welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandBlack, Color(0xFF1F1F1F), Color(0xFF2D2A1A)],
  );

  static const authGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandBlack, Color(0xFF252525), brandBlackSoft],
  );

  static const profileHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandBlack, brandBlackSoft],
  );
}
