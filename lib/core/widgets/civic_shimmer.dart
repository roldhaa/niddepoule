import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

class CivicShimmer extends StatelessWidget {
  const CivicShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: child,
    );
  }
}

class CivicFeedCardShimmer extends StatelessWidget {
  const CivicFeedCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CivicShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.lgAll,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: AppColors.border),
                  AppSpacing.vSm,
                  Container(height: 12, width: double.infinity, color: AppColors.border),
                  AppSpacing.vSm,
                  Container(height: 12, width: 200, color: AppColors.border),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CivicListShimmer extends StatelessWidget {
  const CivicListShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: itemCount,
      itemBuilder: (_, __) => const CivicFeedCardShimmer(),
    );
  }
}
