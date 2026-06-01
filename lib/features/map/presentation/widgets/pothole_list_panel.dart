import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_danger_tag.dart';
import 'package:niddepoule/core/widgets/civic_section_title.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';

class PotholeListPanel extends StatelessWidget {
  const PotholeListPanel({
    super.key,
    required this.potholes,
    required this.onTap,
  });

  final List<Pothole> potholes;
  final void Function(Pothole) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          child: CivicSectionTitle(title: 'Nids-de-poule signalés'),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: potholes.length,
            itemBuilder: (context, index) {
              final p = potholes[index];
              return CivicCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(p);
                },
                child: Row(
                  children: [
                    CivicDangerTag(level: p.dangerLevel, compact: true),
                    AppSpacing.gapH(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.reportCount} signalement(s)',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            p.city ?? 'Québec',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
