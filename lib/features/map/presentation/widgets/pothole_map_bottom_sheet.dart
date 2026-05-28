import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_danger_tag.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';

/// Contenu du bottom sheet carte (wrapper [showCivicBottomSheet] côté parent).
class PotholeMapBottomSheet extends StatelessWidget {
  const PotholeMapBottomSheet({
    super.key,
    required this.pothole,
    required this.onConfirmPresent,
  });

  final Pothole pothole;
  final VoidCallback onConfirmPresent;

  @override
  Widget build(BuildContext context) {
    final photo = pothole.photoUrls.isNotEmpty ? pothole.photoUrls.first : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photo != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 100,
                child: Center(child: Text('Photo indisponible')),
              ),
            ),
          ),
        if (photo != null) AppSpacing.vMd,
        CivicDangerTag(level: pothole.dangerLevel),
        AppSpacing.vMd,
        Text(
          '${pothole.reportCount} signalement(s)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'Dernier: ${DateFormatter.shortDate(pothole.lastReportedAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (pothole.city != null)
          Text(pothole.city!, style: Theme.of(context).textTheme.bodySmall),
        AppSpacing.vLg,
        CivicButton(
          label: 'Voir détails',
          icon: Icons.open_in_new,
          onPressed: () {
            Navigator.pop(context);
            context.push('/pothole/${pothole.id}');
          },
        ),
        AppSpacing.vSm,
        CivicButton(
          label: 'Confirmer encore présent',
          variant: CivicButtonVariant.secondary,
          onPressed: onConfirmPresent,
        ),
      ],
    );
  }
}
