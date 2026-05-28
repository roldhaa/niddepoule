import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_banner.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_loader.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/features/potholes/presentation/providers/pothole_providers.dart';

class ProofPreviewScreen extends ConsumerWidget {
  const ProofPreviewScreen({super.key, required this.potholeId});

  final String potholeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potholeAsync = ref.watch(potholeByIdProvider(potholeId));

    return CivicScaffold(
      title: 'Dossier de preuve',
      body: potholeAsync.when(
        data: (pothole) {
          if (pothole == null) {
            return const CivicEmptyState(
              title: 'Nid-de-poule introuvable',
              icon: Icons.error_outline,
            );
          }
          final days = DateTime.now().difference(pothole.firstReportedAt).inDays;
          final claimScore = (pothole.reportCount * 15 + pothole.photoUrls.length * 10)
              .clamp(0, 100);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const CivicBanner(
                message:
                    'CivicRoad aide à documenter la situation, mais ne garantit '
                    'aucune compensation ni victoire juridique.',
                type: CivicBannerType.info,
              ),
              AppSpacing.vLg,
              Text('Premier signalement: ${DateFormatter.shortDate(pothole.firstReportedAt)}'),
              Text('Durée documentée: $days jour(s)'),
              Text(
                'GPS: ${pothole.latitude.toStringAsFixed(5)}, '
                '${pothole.longitude.toStringAsFixed(5)}',
              ),
              Text('Signalements liés: ${pothole.reportCount}'),
              Text('Score indicatif: $claimScore / 100'),
              if (pothole.photoUrls.isNotEmpty) ...[
                AppSpacing.vLg,
                Text(
                  'Photos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.vSm,
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pothole.photoUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pothole.photoUrls[i],
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              AppSpacing.vXl,
              CivicButton(
                label: 'Exporter PDF — bientôt',
                onPressed: null,
              ),
            ],
          );
        },
        loading: () => const Center(child: CivicLoader()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
