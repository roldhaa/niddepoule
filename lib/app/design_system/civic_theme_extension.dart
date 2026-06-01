import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

class CivicThemeExtension extends ThemeExtension<CivicThemeExtension> {
  const CivicThemeExtension({
    required this.brandYellow,
    required this.brandBlack,
    required this.surfaceMuted,
    required this.dangerLow,
    required this.dangerMedium,
    required this.dangerHigh,
  });

  final Color brandYellow;
  final Color brandBlack;
  final Color surfaceMuted;
  final Color dangerLow;
  final Color dangerMedium;
  final Color dangerHigh;

  static final light = CivicThemeExtension(
    brandYellow: AppColors.brandYellow,
    brandBlack: AppColors.brandBlack,
    surfaceMuted: AppColors.surfaceMuted,
    dangerLow: AppColors.dangerLow,
    dangerMedium: AppColors.dangerMedium,
    dangerHigh: AppColors.dangerHigh,
  );

  static final dark = CivicThemeExtension(
    brandYellow: AppColors.brandYellow,
    brandBlack: AppColors.brandBlack,
    surfaceMuted: AppColors.surfaceMuted,
    dangerLow: AppColors.dangerLow,
    dangerMedium: AppColors.dangerMedium,
    dangerHigh: AppColors.dangerHigh,
  );

  @override
  CivicThemeExtension copyWith({
    Color? brandYellow,
    Color? brandBlack,
    Color? surfaceMuted,
    Color? dangerLow,
    Color? dangerMedium,
    Color? dangerHigh,
  }) {
    return CivicThemeExtension(
      brandYellow: brandYellow ?? this.brandYellow,
      brandBlack: brandBlack ?? this.brandBlack,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      dangerLow: dangerLow ?? this.dangerLow,
      dangerMedium: dangerMedium ?? this.dangerMedium,
      dangerHigh: dangerHigh ?? this.dangerHigh,
    );
  }

  @override
  CivicThemeExtension lerp(CivicThemeExtension? other, double t) => this;
}

extension CivicThemeContext on BuildContext {
  CivicThemeExtension get civicTheme =>
      Theme.of(this).extension<CivicThemeExtension>() ?? CivicThemeExtension.light;
}
