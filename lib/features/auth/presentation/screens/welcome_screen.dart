import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.welcomeGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.brandYellow,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandYellow.withValues(alpha: 0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_road_rounded,
                      size: 56,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  AppSpacing.vXl,
                  Text(
                    'CivicRoad',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.textOnDark,
                        ),
                  ),
                  AppSpacing.vMd,
                  Text(
                    'Signalez les nids-de-poule au Québec.\nProtégez votre communauté, une route à la fois.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                  ),
                  AppSpacing.vXl,
                  const _FeatureRow(
                    icon: Icons.map_outlined,
                    label: 'Carte interactive des dangers',
                  ),
                  AppSpacing.vMd,
                  const _FeatureRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Signalement rapide avec photo',
                  ),
                  AppSpacing.vMd,
                  const _FeatureRow(
                    icon: Icons.groups_outlined,
                    label: 'Communauté civique et badges',
                  ),
                  const SizedBox(height: 40),
                  CivicButton(
                    label: 'Créer un compte',
                    icon: Icons.person_add_outlined,
                    variant: CivicButtonVariant.accent,
                    onPressed: () => context.go('/register'),
                  ),
                  AppSpacing.vMd,
                  CivicButton(
                    label: 'J\'ai déjà un compte',
                    variant: CivicButtonVariant.ghost,
                    onPressed: () => context.go('/login'),
                  ),
                  AppSpacing.vLg,
                  Text(
                    'En continuant, vous acceptez nos conditions d\'utilisation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textOnDark.withValues(alpha: 0.45),
                        ),
                  ),
                  AppSpacing.vXl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.brandYellow, size: 22),
        ),
        AppSpacing.gapH(14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnDark.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
