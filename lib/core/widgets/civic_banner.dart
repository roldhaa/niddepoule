import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';

enum CivicBannerType { success, error, info }

class CivicBanner extends StatelessWidget {
  const CivicBanner({
    super.key,
    required this.message,
    this.type = CivicBannerType.info,
  });

  final String message;
  final CivicBannerType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (type) {
      CivicBannerType.success => (
          AppColors.successSurface,
          AppColors.success,
          Icons.check_circle_outline,
        ),
      CivicBannerType.error => (
          AppColors.errorSurface,
          AppColors.error,
          Icons.error_outline,
        ),
      CivicBannerType.info => (
          AppColors.surfaceSection,
          AppColors.textPrimary,
          Icons.info_outline,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          AppSpacing.gapH(AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fg, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
