import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';

enum CivicButtonVariant { primary, secondary, accent, ghost, danger }

enum CivicButtonSize { medium, large }

class CivicButton extends StatelessWidget {
  const CivicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CivicButtonVariant.primary,
    this.size = CivicButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CivicButtonVariant variant;
  final CivicButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final height = size == CivicButtonSize.large ? 52.0 : 44.0;
    final (bg, fg, border) = _colors();

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: fg,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: size == CivicButtonSize.large ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          );

    final button = Material(
      color: bg,
      elevation: variant == CivicButtonVariant.accent ? 4 : 0,
      shadowColor: AppColors.brandYellow.withValues(alpha: 0.4),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadius.mdAll,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: expand ? 20 : 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: border,
          ),
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  (Color bg, Color fg, Border? border) _colors() {
    return switch (variant) {
      CivicButtonVariant.primary => (
          AppColors.brandOrange,
          Colors.white,
          null,
        ),
      CivicButtonVariant.secondary => (
          AppColors.surface,
          AppColors.textPrimary,
          Border.all(color: AppColors.border, width: 1.5),
        ),
      CivicButtonVariant.accent => (
          AppColors.brandYellow,
          const Color(0xFF0B0C0F),
          null,
        ),
      CivicButtonVariant.ghost => (
          Colors.transparent,
          AppColors.textPrimary,
          Border.all(color: AppColors.border, width: 1.5),
        ),
      CivicButtonVariant.danger => (
          AppColors.error,
          Colors.white,
          null,
        ),
    };
  }
}
