import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.brandBlack.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.brandBlack.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get fab => [
        BoxShadow(
          color: AppColors.brandYellow.withValues(alpha: 0.45),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
