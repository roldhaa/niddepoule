import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack ?? () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textOnDark,
                  ),
                )
              else
                const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandYellow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.add_road_rounded,
                            color: AppColors.brandBlack,
                            size: 28,
                          ),
                        ),
                        AppSpacing.gapH(AppSpacing.md),
                        Text(
                          'CivicRoad',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    AppSpacing.vLg,
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.vSm,
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textOnDarkMuted,
                          ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vXl,
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sheet),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      child: body,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
