import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_shadows.dart';

enum CivicCardVariant { elevated, outlined, muted }

class CivicCard extends StatelessWidget {
  const CivicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.variant = CivicCardVariant.elevated,
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final CivicCardVariant variant;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: switch (variant) {
        CivicCardVariant.elevated => AppColors.surface,
        CivicCardVariant.outlined => AppColors.surface,
        CivicCardVariant.muted => AppColors.surfaceSection,
      },
      borderRadius: AppRadius.lgAll,
      border: variant == CivicCardVariant.outlined
          ? Border.all(color: AppColors.border)
          : null,
      boxShadow: variant == CivicCardVariant.elevated ? AppShadows.card : null,
    );

    final content = Padding(padding: padding, child: child);

    final card = Container(
      margin: margin,
      decoration: decoration,
      child: content,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: card,
      ),
    );
  }
}
