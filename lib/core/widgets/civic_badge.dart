import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';

class CivicBadge extends StatelessWidget {
  const CivicBadge({
    super.key,
    required this.label,
    this.icon,
    this.highlight = false,
  });

  final String label;
  final IconData? icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.brandYellow.withValues(alpha: 0.2)
            : AppColors.surfaceSection,
        borderRadius: AppRadius.mdAll,
        border: highlight
            ? Border.all(color: AppColors.brandYellow.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: highlight ? AppColors.brandBlack : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.brandBlack : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
